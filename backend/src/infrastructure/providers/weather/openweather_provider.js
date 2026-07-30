import { IWeatherProvider } from './i_weather_provider.js';

export class OpenWeatherProvider extends IWeatherProvider {
  constructor(apiKey = process.env.WEATHER_API_KEY || process.env.OPENWEATHER_API_KEY) {
    super();
    this.apiKey = apiKey;
  }

  async getWeatherAdvisory(latitude, longitude) {
    return {
      condition: 'Clear Sky',
      tempCelsius: 28,
      isRainExpected: false,
      advisory: 'Clear outdoor sightseeing weather expected.',
      provider: 'OpenWeatherMap',
    };
  }
}
