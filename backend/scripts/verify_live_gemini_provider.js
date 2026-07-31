import { GeminiAiProvider } from '../src/infrastructure/providers/ai/gemini_ai_provider.js';

async function verifyGeminiProvider() {
  const apiKey = process.env.GEMINI_API_KEY || 'dummy_gemini_key';
  const provider = new GeminiAiProvider(apiKey);

  const preComputedData = {
    origin: 'Ghaziabad Junction',
    destination: 'Connaught Place, Delhi',
    timeMinutes: 51,
    cost: 70,
    safetyScore: 90,
    safetyLabel: 'High Safety',
    weather: 'Current weather in Ghaziabad: 29°C, overcast clouds.',
  };

  console.log('==================================================');
  console.log('🤖 EXECUTING GROUNDED GEMINI AI PROVIDER TEST');
  console.log('==================================================');
  console.log('Pre-Computed Facts Passed to Gemini:');
  console.log(JSON.stringify(preComputedData, null, 2));

  const startTime = Date.now();
  const result = await provider.generateRationale(preComputedData);
  const elapsedMs = Date.now() - startTime;

  console.log('\n==================================================');
  console.log('✅ GEMINI AI RATIONALE RETURNED');
  console.log('==================================================');
  console.log(`Model Used        : ${result.model}`);
  console.log(`Response Time     : ${elapsedMs} ms`);
  console.log(`Generated Rationale:\n"${result.rationale}"`);
}

verifyGeminiProvider();
