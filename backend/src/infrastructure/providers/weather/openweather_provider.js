import { IWeatherProvider } from './i_weather_provider.js';

export class OpenWeatherProvider extends IWeatherProvider {
  constructor(apiKey = process.env.OPENWEATHER_API_KEY || process.env.WEATHER_API_KEY, options = {}) {
    super();
    this.id = 'openweather';
    this.name = 'OpenWeatherMap Provider';
    this.priority = 'optional';
    this.dependencies = [];
    this.timeoutMs = 3500;
    this.cacheTtlSeconds = 3600;
    this.version = '1.0.0';
    this.isEnabled = options.isEnabled ?? (process.env.ENABLE_WEATHER !== 'false');
    this.apiKey = apiKey;
  }

  async execute(context) {
    if (!context || context.originLat == null || context.originLng == null) {
      return this.getWeatherAdvisory(28.6139, 77.2090);
    }
    return this.getWeatherAdvisory(context.originLat, context.originLng);
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
