/**
 * Maps JourneyContext & Advisor Rationale into clean API response JSON payload
 */
export class JourneyResponseMapper {
  static toResponseDTO(context, aiRationale) {
    if (!context) {
      return { plans: {} };
    }

    const plans = { ...context.plans };
    const primaryMode = context.preferredMode || 'balanced';

    if (plans[primaryMode] && aiRationale) {
      plans[primaryMode] = {
        ...plans[primaryMode],
        aiRationale,
      };
    }

    return {
      plans,
      weatherSummary: context.weather ? { advisory: context.weather.advisory } : null,
      originLandmark: context.originLandmark ? { name: context.originLandmark.name, landmarkTip: context.originLandmark.landmarkTip } : null,
    };
  }
}
