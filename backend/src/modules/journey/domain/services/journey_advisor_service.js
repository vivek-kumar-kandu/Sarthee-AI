import { GeminiAiProvider } from '../../../../infrastructure/providers/ai/gemini_ai_provider.js';
import { logger } from '../../../../config/logger.js';

export class JourneyAdvisorService {
  constructor(aiProvider = new GeminiAiProvider()) {
    this.aiProvider = aiProvider;
  }

  /**
   * Generates grounded natural language explanation rationale from immutable JourneyContext
   * @param {JourneyContext} context 
   * @returns {Promise<String>} Grounded travel rationale
   */
  async generateAdvice(context) {
    if (!context) {
      return 'Sarthee AI Journey Assistant: Safe travels on your multi-modal route.';
    }

    const primaryPlan = context.getPrimaryPlan();
    if (!primaryPlan) {
      return 'Sarthee AI Journey Assistant: Multi-modal route options available.';
    }

    const landmarkInfo = context.originLandmark?.landmarkTip || context.destLandmark?.landmarkTip || null;
    const weatherInfo = context.weather?.advisory || null;

    try {
      const startTime = Date.now();
      const rawAdvice = await this.aiProvider.generateRationale({
        mode: primaryPlan.mode,
        origin: context.originName,
        originName: context.originName,
        destination: context.destinationName,
        destinationName: context.destinationName,
        timeMinutes: primaryPlan.totalDurationMinutes,
        durationMinutes: primaryPlan.totalDurationMinutes,
        cost: primaryPlan.totalCost,
        totalCost: primaryPlan.totalCost,
        safetyScore: primaryPlan.compositeSafetyScore,
        weather: weatherInfo || 'Clear weather expected',
        weatherAdvisory: weatherInfo,
        landmarkTip: landmarkInfo,
      });

      const advice = (typeof rawAdvice === 'object' && rawAdvice?.rationale) ? rawAdvice.rationale : String(rawAdvice || '');

      const latencyMs = Date.now() - startTime;
      logger.debug({ event: 'advisor_rationale_generated', latencyMs, mode: primaryPlan.mode });

      return advice;
    } catch (err) {
      logger.warn({ event: 'advisor_rationale_fallback', reason: err.message });
      // Structured Fallback Rationale
      const landmarkText = landmarkInfo ? ` ${landmarkInfo}.` : '';
      return `Sarthee Suggests: Travel from ${context.originName} to ${context.destinationName} takes ~${primaryPlan.totalDurationMinutes} mins for ₹${primaryPlan.totalCost}.${landmarkText} Safety: ${primaryPlan.compositeSafetyScore}/100.`;
    }
  }
}

