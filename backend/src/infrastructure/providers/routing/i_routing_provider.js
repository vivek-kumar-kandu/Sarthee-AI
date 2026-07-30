/**
 * Abstract Routing Provider Interface
 */
export class IRoutingProvider {
  /**
   * Calculates route distance, duration, and geometry polyline
   * @param {number} originLat
   * @param {number} originLng
   * @param {number} destLat
   * @param {number} destLng
   * @param {string} mode - 'walk' | 'driving' | 'transit'
   * @returns {Promise<{distanceMeters: number, durationMinutes: number, polyline: string, provider: string}>}
   */
  async calculateRoute(originLat, originLng, destLat, destLng, mode = 'driving') {
    throw new Error('IRoutingProvider.calculateRoute must be implemented by subclass.');
  }
}
