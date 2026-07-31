import { OpenWeatherProvider } from '../src/infrastructure/providers/weather/openweather_provider.js';

async function verifyLiveWeather() {
  const apiKey = process.env.OPENWEATHER_API_KEY || 'dummy_openweather_key';
  const provider = new OpenWeatherProvider(apiKey);

  console.log('==================================================');
  console.log('🌐 EXECUTING LIVE OPENWEATHER API TEST');
  console.log('==================================================');
  console.log('Coordinates : 28.6715, 77.4121 (Ghaziabad)');
  console.log(`API Key     : ${apiKey.substring(0, 8)}...`);

  const startTime = Date.now();
  const result = await provider.getWeatherAdvisory(28.6715, 77.4121);
  const elapsedMs = Date.now() - startTime;

  console.log('\n==================================================');
  console.log('✅ LIVE OPENWEATHER RESULT RETURNED');
  console.log('==================================================');
  console.log(`Provider          : ${result.provider}`);
  console.log(`Response Time     : ${elapsedMs} ms`);
  console.log(`Condition         : ${result.condition}`);
  console.log(`Temperature       : ${result.tempCelsius}°C`);
  console.log(`Rain Expected     : ${result.isRainExpected}`);
  console.log(`Live Advisory     : ${result.advisory}`);
}

verifyLiveWeather();
