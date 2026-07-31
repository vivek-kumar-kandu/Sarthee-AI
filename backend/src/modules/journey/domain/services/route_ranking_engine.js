/**
 * RouteRankingEngine
 * Configurable, weighted route ranking engine for travel recommendations
 */
export class RouteRankingEngine {
  static DEFAULT_CONFIG = {
    heatThreshold: 38,
    maxWalkRainMeters: 250,
    maxWalkHeatMeters: 300,
    rainWalkPenalty: 0.4,
    erickshawRainPenalty: 0.3,
    weights: {
      time: 0.40,
      cost: 0.20,
      weather: 0.20,
      safety: 0.15,
      walking: 0.05,
    },
  };

  constructor(config = {}) {
    this.config = {
      ...RouteRankingEngine.DEFAULT_CONFIG,
      ...config,
      weights: {
        ...RouteRankingEngine.DEFAULT_CONFIG.weights,
        ...(config.weights || {}),
      },
    };
  }

  /**
   * Calculates a composite recommendation score for a given journey plan
   * @param {Object} plan Journey plan object
   * @param {Object|null} weather Weather advisory object
   * @param {number} hourOfDay Current hour of day
   * @param {Object|null} traffic Traffic status object
   * @param {Array} incidents Active incidents list
   * @returns {number} Score from 0 to 100
   */
  calculateRouteScore(plan, weather = null, hourOfDay = new Date().getHours(), traffic = null, incidents = []) {
    if (!plan) return 0;

    const isRain = weather?.isRainExpected || weather?.condition?.toLowerCase()?.includes('rain') || false;
    const tempCelsius = weather?.tempCelsius ?? 28;
    const isFog = weather?.condition?.toLowerCase()?.includes('fog') || weather?.condition?.toLowerCase()?.includes('mist') || false;

    // 1. Time Score (Normalized: 60 mins = 50 pts, 20 mins = 100 pts)
    let timeMins = plan.totalDurationMinutes || 40;
    const isRoadPlan = plan.mode === 'fastest' || (plan.steps || []).some((s) => s.type === 'cab' || s.type === 'auto');

    // Add live traffic delay if road plan
    if (isRoadPlan && traffic?.status === 'LIVE' && traffic?.delayMinutes > 0) {
      timeMins += traffic.delayMinutes;
    }

    const timeScore = Math.max(10, Math.min(100, 100 - (timeMins - 20) * 1.5));

    // 2. Cost Score (Normalized: ₹500 = 20 pts, ₹50 = 100 pts)
    const cost = plan.totalCost || 100;
    const costScore = Math.max(10, Math.min(100, 100 - (cost - 50) * 0.18));

    // 3. Safety Score (Direct 0-100 value)
    const safetyScore = plan.compositeSafetyScore || 85;

    // 4. Walking Score (Normalized: 1500m = 10 pts, 100m = 100 pts)
    const walkMeters = plan.totalWalkingDistanceMeters || 300;
    let walkScore = Math.max(10, Math.min(100, 100 - (walkMeters - 100) * 0.06));

    // 5. Weather & Incident Comfort Score
    let weatherScore = 90;
    if (isRain) {
      if (walkMeters > this.config.maxWalkRainMeters) {
        weatherScore -= 30 * this.config.rainWalkPenalty;
      }
      const hasOpenRickshaw = (plan.steps || []).some((s) => s.type === 'eRickshaw' || s.type === 'auto');
      if (hasOpenRickshaw) {
        weatherScore -= 20 * this.config.erickshawRainPenalty;
      }
    }

    if (tempCelsius >= this.config.heatThreshold && walkMeters > this.config.maxWalkHeatMeters) {
      weatherScore -= 25;
    }

    if (isFog) {
      weatherScore -= 15;
    }

    // Heavy traffic or road closed incident penalty for road plans
    if (isRoadPlan && Array.isArray(incidents) && incidents.some((i) => i.type === 'ROAD_CLOSED')) {
      weatherScore -= 40;
    }

    // Weighted Formula
    const totalScore =
      timeScore * this.config.weights.time +
      costScore * this.config.weights.cost +
      weatherScore * this.config.weights.weather +
      safetyScore * this.config.weights.safety +
      walkScore * this.config.weights.walking;

    return parseFloat(totalScore.toFixed(1));
  }

  /**
   * Re-ranks plans based on weighted scoring formula and returns optimal recommendations
   * @param {Object} plans Keyed map of journey plans
   * @param {Object|null} weather Weather advisory object
   * @param {number} hourOfDay Current hour of day
   * @param {Object|null} traffic Traffic status object
   * @param {Array} incidents Active incidents list
   * @returns {Object} Re-ranked journey plans
   */
  reRankPlans(plans = {}, weather = null, hourOfDay = new Date().getHours(), traffic = null, incidents = []) {
    if (!plans || Object.keys(plans).length === 0) {
      return plans;
    }

    const updatedPlans = { ...plans };
    let bestPlanKey = null;
    let highestScore = -1;

    for (const [key, plan] of Object.entries(updatedPlans)) {
      const score = this.calculateRouteScore(plan, weather, hourOfDay, traffic, incidents);
      plan.recommendationScore = score;

      if (score > highestScore) {
        highestScore = score;
        bestPlanKey = key;
      }
    }

    if (bestPlanKey && updatedPlans[bestPlanKey]) {
      const topPlan = updatedPlans[bestPlanKey];
      const isRain = weather?.isRainExpected || weather?.condition?.toLowerCase()?.includes('rain') || false;
      const tempCelsius = weather?.tempCelsius ?? 28;

      let rationale = topPlan.aiRationale || '';
      if (traffic?.status === 'LIVE' && traffic?.delayMinutes > 10) {
        rationale += ` 🚦 Heavy Traffic Alert (+${traffic.delayMinutes} min delay): Metro Rail promoted to bypass road congestion.`;
      } else if (isRain) {
        rationale += ` ☔ Weather Advisory: Ranked #1 optimal plan (Score: ${highestScore}/100) prioritizing weather protection.`;
      } else if (tempCelsius >= this.config.heatThreshold) {
        rationale += ` ☀️ Heat Warning (${tempCelsius}°C): Ranked #1 optimal plan (Score: ${highestScore}/100) minimizing high temperature outdoor exposure.`;
      }

      updatedPlans.recommended = {
        ...topPlan,
        id: `plan_rec_ranked_${topPlan.mode}`,
        mode: 'recommended',
        aiRationale: rationale.trim(),
      };
    }

    return updatedPlans;
  }
}
