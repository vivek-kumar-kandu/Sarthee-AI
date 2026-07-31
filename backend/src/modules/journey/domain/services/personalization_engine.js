/**
 * PersonalizationEngine
 * Re-ranks route scores based on user profile preferences
 */
export class PersonalizationEngine {
  /**
   * Applies user profile preferences to journey plan scores
   * @param {Object} plans Keyed map of journey plans
   * @param {Object} preferences User preferences ({ avoidWalking, preferCheapest, wheelchairAccessible, avoidCrowds })
   * @returns {Object} Personalization-adjusted journey plans
   */
  static applyUserPreferences(plans = {}, preferences = {}) {
    if (!plans || Object.keys(plans).length === 0 || !preferences || Object.keys(preferences).length === 0) {
      return plans;
    }

    const updatedPlans = { ...plans };
    let bestPlanKey = null;
    let highestScore = -1;

    for (const [key, plan] of Object.entries(updatedPlans)) {
      let score = plan.recommendationScore || 75;

      if (preferences.avoidWalking && (plan.totalWalkingDistanceMeters || 0) <= 300) {
        score += 20;
      }

      if (preferences.preferCheapest && plan.mode === 'cheapest') {
        score += 25;
      }

      if (preferences.wheelchairAccessible && plan.mode === 'accessible') {
        score += 30;
      }

      if (preferences.avoidCrowds && (plan.compositeSafetyScore || 0) >= 90) {
        score += 15;
      }

      plan.personalizedScore = parseFloat(score.toFixed(1));

      if (score > highestScore) {
        highestScore = score;
        bestPlanKey = key;
      }
    }

    if (bestPlanKey && updatedPlans[bestPlanKey]) {
      const topPlan = updatedPlans[bestPlanKey];
      updatedPlans.recommended = {
        ...topPlan,
        id: `plan_rec_user_pref_${topPlan.mode}`,
        mode: 'recommended',
        aiRationale: `${topPlan.aiRationale || ''} 🎯 Personalized for your travel preferences (${Object.keys(preferences).filter((k) => preferences[k]).join(', ')}).`,
      };
    }

    return updatedPlans;
  }
}
