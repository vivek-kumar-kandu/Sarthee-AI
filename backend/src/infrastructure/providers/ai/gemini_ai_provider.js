import { IAIProvider } from './i_ai_provider.js';

export class GeminiAiProvider extends IAIProvider {
  constructor(apiKey = process.env.GEMINI_API_KEY) {
    super();
    this.apiKey = apiKey;
  }

  async generateRationale(promptContext) {
    const { origin, destination, timeMinutes, cost } = promptContext;
    return {
      rationale: `Sarthee Suggests: Travel from ${origin} to ${destination} takes ~${timeMinutes} mins for ₹${cost}. Metro avoids major traffic delays along GT Road.`,
      model: 'gemini-2.0-flash',
    };
  }
}
