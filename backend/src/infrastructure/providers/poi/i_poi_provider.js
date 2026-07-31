import { IJourneyProvider } from '../registry/i_journey_provider.js';

export class IPoiProvider extends IJourneyProvider {
  constructor(metadata = {}) {
    super({
      id: 'poi_provider',
      name: 'Point of Interest Landmark Provider',
      priority: 'optional',
      dependencies: [], // Independent lookup
      timeoutMs: 2500,
      cacheTtlSeconds: 7200, // 2-hour TTL
      version: '1.0.0',
      ...metadata,
    });
  }

  /**
   * Retrieves prominent local landmark near coordinates
   * @param {number} lat Latitude
   * @param {number} lng Longitude
   * @param {number} radiusMeters Contextual radius
   * @returns {Promise<Object|null>} Structured landmark object or null
   */
  async getNearbyLandmark(_lat, _lng, _radiusMeters = 100) {
    throw new Error('Method getNearbyLandmark() must be implemented.');
  }

  async execute(context) {
    if (!context || context.originLat == null || context.originLng == null) {
      return null;
    }
    const radius = context.radiusMeters || 120;
    return this.getNearbyLandmark(context.originLat, context.originLng, radius);
  }
}
