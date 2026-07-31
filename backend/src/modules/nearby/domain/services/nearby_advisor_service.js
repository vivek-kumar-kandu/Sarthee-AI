import { logger } from '../../../../config/logger.js';

/**
 * NearbyAdvisorService — Grounded Gemini 2.0 Flash AI Travel Advisor
 *
 * Provides natural language AI travel advice grounded strictly in backend
 * pre-calculated metrics (distance, rating, score, weather, open status).
 *
 * Rules:
 *   - NEVER receives raw OSM JSON
 *   - Strictly grounded — no hallucinations
 *   - Returns structured JSON advice:
 *     {
 *       summary: string,
 *       whyRecommended: string,
 *       bestTime: string,
 *       estimatedVisit: string,
 *       weatherAdvice: string,
 *       familyFriendly: boolean,
 *       accessibility: string,
 *       confidence: number
 *     }
 */
export class NearbyAdvisorService {
  /**
   * @param {Object} [options]
   * @param {string} [options.apiKey] Gemini API Key
   * @param {string} [options.modelName='gemini-2.0-flash']
   */
  constructor(options = {}) {
    this.apiKey = options.apiKey || process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY || null;
    this.modelName = options.modelName || 'gemini-2.0-flash';
  }

  /**
   * Generates AI travel advice for a top ranked POI.
   * @param {Object} poi Scored POI from NearbyRankingEngine
   * @param {import('../value_objects/nearby_context.js').NearbyContext} context
   * @returns {Promise<Object>} Structured advice payload
   */
  async generateAdvice(poi, context) {
    if (!poi) return this._generateFallbackAdvice(poi, context);

    // If Gemini key missing or offline, use deterministic fallback
    if (!this.apiKey) {
      logger.debug({ event: 'nearby_advisor_fallback', reason: 'no_api_key' });
      return this._generateFallbackAdvice(poi, context);
    }

    try {
      const prompt = this._buildPrompt(poi, context);
      const startTime = Date.now();

      const controller = new AbortController();
      const tid = setTimeout(() => controller.abort(), 3500); // 3.5s timeout

      const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${this.modelName}:generateContent?key=${this.apiKey}`;
      const resp = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.2,
            responseMimeType: 'application/json',
          },
        }),
        signal: controller.signal,
      });
      clearTimeout(tid);

      if (resp.ok) {
        const data = await resp.json();
        const rawText = data.candidates?.[0]?.content?.parts?.[0]?.text;
        if (rawText) {
          const parsed = JSON.parse(rawText);
          logger.debug({ event: 'nearby_advisor_success', poiName: poi.name, elapsedMs: Date.now() - startTime });
          return {
            summary: parsed.summary || `${poi.name} is a top recommended ${poi.category} destination.`,
            whyRecommended: parsed.whyRecommended || (poi.reasons || []).join(', '),
            bestTime: parsed.bestTime || 'Morning or Late Afternoon',
            estimatedVisit: parsed.estimatedVisit || '1-2 hours',
            weatherAdvice: parsed.weatherAdvice || 'Pleasant for visiting',
            familyFriendly: parsed.familyFriendly ?? true,
            accessibility: parsed.accessibility || 'Standard access available',
            confidence: parsed.confidence || poi.confidence || 0.9,
            aiGenerated: true,
          };
        }
      }
    } catch (err) {
      logger.warn({ event: 'nearby_advisor_gemini_error', error: err.message });
    }

    return this._generateFallbackAdvice(poi, context);
  }

  /** @private */
  _buildPrompt(poi, context) {
    const weather = context.weatherSnapshot
      ? `${context.weatherSnapshot.temperature}°C, ${context.weatherSnapshot.condition}`
      : 'Pleasant';

    return `You are Sarthee AI, an intelligent local travel advisor. Generate concise, grounded travel advice for this destination.
Return ONLY valid JSON matching this schema:
{
  "summary": "1-sentence overview",
  "whyRecommended": "Why this place is recommended based on rating and distance",
  "bestTime": "Best time of day to visit",
  "estimatedVisit": "Estimated duration (e.g. 1.5 hours)",
  "weatherAdvice": "Brief advice given current weather",
  "familyFriendly": true/false,
  "accessibility": "Brief access note",
  "confidence": 0.95
}

Destination Details:
- Name: ${poi.name}
- Category: ${poi.category} (${poi.subcategory || poi.category})
- Distance: ${poi.distanceKm} km away
- Composite Score: ${poi.score}/100
- Weather: ${weather}
- Open Hours: ${poi.tags?.opening_hours || 'Standard'}
- Key Signals: ${(poi.reasons || []).join(', ')}`;
  }

  /** @private — Deterministic fallback when Gemini API key is missing/offline */
  _generateFallbackAdvice(poi, context) {
    const reasons = (poi?.reasons || []).join(' • ');
    const distStr = poi?.distanceKm ? `${poi.distanceKm} km away` : 'nearby';

    return {
      summary: `${poi?.name || 'Destination'} is an excellent ${poi?.category || 'local'} choice located ${distStr}.`,
      whyRecommended: reasons || 'High composite score and convenient proximity.',
      bestTime: 'Morning or Early Evening',
      estimatedVisit: poi?.estimatedVisitHours ? `${poi.estimatedVisitHours} hours` : '1-2 hours',
      weatherAdvice: context?.weatherSnapshot?.temperature >= 38
        ? 'High temperature — prefer AC areas'
        : 'Pleasant weather for visiting',
      familyFriendly: true,
      accessibility: 'Accessible location',
      confidence: poi?.confidence || 0.85,
      aiGenerated: false,
    };
  }
}
