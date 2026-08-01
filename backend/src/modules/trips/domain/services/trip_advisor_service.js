import { logger } from '../../../../config/logger.js';

/**
 * TripAdvisorService — Grounded Gemini 2.0 Flash AI Trip Explanation Service
 *
 * Explains backend pre-calculated itineraries in natural, inspiring language.
 *
 * Core Rule:
 *   - NEVER calculates distances, fares, or timings.
 *   - ONLY explains pre-calculated facts (opening hours, weather, OSRM times, tourism fees).
 *   - Zero hallucination.
 */
export class TripAdvisorService {
  constructor(options = {}) {
    this.apiKey = options.apiKey || process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY || null;
    this.modelName = options.modelName || 'gemini-2.0-flash';
  }

  /**
   * Generates grounded natural language trip explanation.
   *
   * @param {import('../entities/trip_entity.js').TripEntity} trip
   * @param {import('../value_objects/trip_context.js').TripContext} context
   * @returns {Promise<{ summary: string, itineraryExplanation: string, packingTips: string[], aiGenerated: boolean }>}
   */
  async generateTripAdvice(trip, context) {
    if (!this.apiKey) {
      logger.debug({ event: 'trip_advisor_fallback', reason: 'no_api_key' });
      return this._generateFallbackAdvice(trip, context);
    }

    try {
      const prompt = this._buildPrompt(trip, context);
      const controller = new AbortController();
      const tid = setTimeout(() => controller.abort(), 4000);

      const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${this.modelName}:generateContent?key=${this.apiKey}`;
      const resp = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: { temperature: 0.2, responseMimeType: 'application/json' },
        }),
        signal: controller.signal,
      });
      clearTimeout(tid);

      if (resp.ok) {
        const data = await resp.json();
        const rawText = data.candidates?.[0]?.content?.parts?.[0]?.text;
        if (rawText) {
          const parsed = JSON.parse(rawText);
          return {
            summary: parsed.summary || `Custom ${trip.city} ${trip.persona} Tour`,
            itineraryExplanation: parsed.itineraryExplanation || 'Optimized visiting sequence based on weather and travel times.',
            packingTips: Array.isArray(parsed.packingTips) ? parsed.packingTips : ['Water bottle', 'Comfortable walking shoes', 'Sun hat'],
            aiGenerated: true,
          };
        }
      }
    } catch (err) {
      logger.warn({ event: 'trip_advisor_gemini_error', error: err.message });
    }

    return this._generateFallbackAdvice(trip, context);
  }

  /** @private */
  _buildPrompt(trip, context) {
    const stopsList = (trip.days[0]?.stops || []).map((s) => `- ${s.name} (${s.timeline?.reachTime}): ${s.whyRecommended?.join(', ')}`).join('\n');

    return `You are Sarthee AI, an expert travel advisor. Explain this pre-calculated trip itinerary in natural language.
Return ONLY valid JSON matching this schema:
{
  "summary": "1-sentence inspiring overview of the trip",
  "itineraryExplanation": "1-2 paragraph explanation of why this sequence was chosen (e.g. cooler morning weather, proximity, opening hours)",
  "packingTips": ["Tip 1", "Tip 2", "Tip 3"]
}

Trip Data:
- City: ${trip.city}
- Persona: ${trip.persona}
- Budget: ₹${trip.costBreakdown?.total}
- Weather: ${context.weatherSnapshot ? `${context.weatherSnapshot.temperature}°C, ${context.weatherSnapshot.condition}` : 'Pleasant'}
- Stops:
${stopsList}`;
  }

  /** @private */
  _generateFallbackAdvice(trip, context) {
    const city = trip?.city || 'Jaipur';
    const persona = trip?.persona || 'Family';

    return {
      summary: `An optimized ${persona} exploration of ${city} crafted around weather, opening hours, and travel proximity.`,
      itineraryExplanation: `Your itinerary starts with major monuments in the morning to beat the peak afternoon heat and crowd, followed by indoor cultural stops, and finishes with vibrant local markets in the evening.`,
      packingTips: [
        'Comfortable walking shoes & sunscreen',
        'Refillable water bottle',
        'Camera or smartphone for photos',
        'Small cash for local entry fees and snacks',
      ],
      aiGenerated: false,
    };
  }
}
