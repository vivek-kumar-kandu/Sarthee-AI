/**
 * Abstract Weather Provider Interface
 */
export class IWeatherProvider {
  /**
   * Fetches weather advisory for location coordinates
   * @param {number} latitude
   * @param {number} longitude
   * @returns {Promise<{condition: string, tempCelsius: number, isRainExpected: boolean, advisory: string, provider: string}>}
   */
  async getWeatherAdvisory(latitude, longitude) {
    throw new Error('IWeatherProvider.getWeatherAdvisory must be implemented by subclass.');
  }
}

