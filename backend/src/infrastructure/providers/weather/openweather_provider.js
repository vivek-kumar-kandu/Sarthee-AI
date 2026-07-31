import { IWeatherProvider } from './i_weather_provider.js';

export class OpenWeatherProvider extends IWeatherProvider {
  constructor(apiKey = process.env.OPENWEATHER_API_KEY || process.env.WEATHER_API_KEY) {
    super();
    this.apiKey = apiKey;
  }

  async getWeatherAdvisory(latitude, longitude) {
    if (this.apiKey) {
      const url = `https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=${this.apiKey}&units=metric`;

      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 3500); // 3.5s timeout guardrail

        const response = await fetch(url, { signal: controller.signal });
        clearTimeout(timeoutId);

        if (response.ok) {
          const data = await response.json();
          const mainCondition = data.weather?.[0]?.main || 'Clear';
          const description = data.weather?.[0]?.description || 'clear sky';
          const temp = Math.round(data.main?.temp ?? 28);
          const isRain = mainCondition.toLowerCase().includes('rain') || mainCondition.toLowerCase().includes('drizzle');

          let advisory = `Current weather in ${data.name || 'area'}: ${temp}°C, ${description}.`;
          if (isRain) {
            advisory += ' Light rain expected. Metro or covered transit recommended.';
          } else {
            advisory += ' Pleasant weather for outdoor walking and sightseeing.';
          }

          return {
            condition: mainCondition,
            tempCelsius: temp,
            isRainExpected: isRain,
            advisory,
            provider: 'OpenWeatherMap (Live API)',
          };
        }
      } catch (error) {
        // Fall back gracefully if offline or key limit reached
      }
    }

    // Offline / Mock Fallback
    return {
      condition: 'Clear',
      tempCelsius: 28,
      isRainExpected: false,
      advisory: 'Clear outdoor sightseeing weather expected.',
      provider: 'OpenWeatherMap (Fallback)',
    };
  }
}
