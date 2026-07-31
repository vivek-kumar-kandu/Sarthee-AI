import { IAIProvider } from './i_ai_provider.js';

export class GeminiAiProvider extends IAIProvider {
  constructor(apiKey = process.env.GEMINI_API_KEY) {
    super();
    this.apiKey = apiKey;
  }

  async generateRationale(promptContext) {
    const {
      origin,
      destination,
      timeMinutes,
      cost,
      safetyScore = 90,
      safetyLabel = 'High Safety',
      weather = 'Clear weather expected',
    } = promptContext;

    if (this.apiKey) {
      const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${this.apiKey}`;
      const systemPrompt = `You are Sarthee AI, an intelligent travel advisor for India. Explain the following PRE-COMPUTED journey metrics in 1-2 clear, helpful sentences.

STRICT GROUNDING RULES:
1. Do NOT invent new travel times, fares, weather conditions, or safety scores. Use ONLY the pre-computed facts provided below.
2. Do NOT claim "heavy live traffic" or unverified congestion delays.
3. Be encouraging, concise, and helpful.

PRE-COMPUTED DATA FACTS:
- Route: ${origin} to ${destination}
- Duration: ${timeMinutes} minutes
- Total Cost: ₹${cost}
- Safety Score: ${safetyScore}/100 (${safetyLabel})
- Weather Advisory: ${weather}`;

      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 4000); // 4.0s timeout guardrail

        const response = await fetch(url, {
          method: 'POST',
          signal: controller.signal,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [
              {
                parts: [{ text: systemPrompt }],
              },
            ],
          }),
        });
        clearTimeout(timeoutId);

        if (response.ok) {
          const data = await response.json();
          const candidateText = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim();

          if (candidateText) {
            return {
              rationale: candidateText,
              model: 'gemini-2.0-flash (Grounded Explanation)',
            };
          }
        }
      } catch (error) {
        // Fall back gracefully if offline or timeout occurs
      }
    }

    // Template Fallback
    return {
      rationale: `Sarthee Suggests: Travel from ${origin} to ${destination} takes ~${timeMinutes} mins for ₹${cost}. Safety: ${safetyScore}/100 (${safetyLabel}). ${weather}`,
      model: 'gemini-2.0-flash (Fallback Explanation)',
    };
  }
}
