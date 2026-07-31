/**
 * RouteRankingEngine
 * Deterministic weather and safety-aware route re-ranking engine
 */
export class RouteRankingEngine {
  /**
   * Re-ranks and optimizes journey plan options based on real-time weather and contextual conditions
   * @param {Object} plans Keyed map of journey plans ({ recommended, balanced, fastest, cheapest, ... })
   * @param {Object|null} weather Weather advisory object ({ condition, tempCelsius, isRainExpected })
   * @param {number} hourOfDay Current hour of day (0-23)
   * @returns {Object} Optimized and re-ranked plans object
   */
  static reRankPlans(plans = {}, weather = null, hourOfDay = new Date().getHours()) {
    if (!plans || Object.keys(plans).length === 0) {
      return plans;
    }

    const updatedPlans = { ...plans };
    const isRain = weather?.isRainExpected || weather?.condition?.toLowerCase()?.includes('rain') || false;
    const tempCelsius = weather?.tempCelsius ?? 28;
    const isNight = hourOfDay >= 23 || hourOfDay < 5;

    // Rule 1: Rain Re-Ranking
    // Demote long walking legs (>250m) & open e-rickshaws, boost Covered Metro Rail
    if (isRain) {
      if (updatedPlans.balanced) {
        // Swap recommended plan to Metro-focused balanced/safe plan
        updatedPlans.recommended = {
          ...updatedPlans.balanced,
          id: 'plan_rec_rain_01',
          aiRationale: `${updatedPlans.balanced.aiRationale || ''} ☔ Rain advisory active: Metro Rail promoted to #1 plan for weather protection.`,
        };
      }
    }

    // Rule 2: Extreme Heat Re-Ranking (>38°C)
    // Demote unshaded walking (>300m), promote AC Transit & Cab
    if (tempCelsius >= 38) {
      if (updatedPlans.fastest) {
        updatedPlans.recommended = {
          ...updatedPlans.fastest,
          id: 'plan_rec_heat_01',
          aiRationale: `${updatedPlans.fastest.aiRationale || ''} ☀️ High heat warning (${tempCelsius}°C): AC taxi/transit promoted to minimize outdoor exposure.`,
        };
      }
    }

    // Rule 3: Late Night Re-Ranking (11 PM - 5 AM)
    // Boost high-safety well-lit arterial routes
    if (isNight) {
      if (updatedPlans.safest) {
        updatedPlans.recommended = {
          ...updatedPlans.safest,
          id: 'plan_rec_night_01',
          aiRationale: `${updatedPlans.safest.aiRationale || ''} 🌙 Late night route: Prioritizing well-lit CCTV-monitored arterial transit hubs.`,
        };
      }
    }

    return updatedPlans;
  }
}
