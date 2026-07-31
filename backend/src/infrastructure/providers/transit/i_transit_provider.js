import { IJourneyProvider } from '../registry/i_journey_provider.js';

/**
 * ITransitProvider
 * Base contract for live and timetable transit status providers
 */
export class ITransitProvider extends IJourneyProvider {
  constructor(options = {}) {
    super({
      id: options.id || 'transit_provider',
      priority: options.priority || 'recommended',
      dependencies: options.dependencies || ['route'],
      timeoutMs: options.timeoutMs || 3000,
      cacheTtlSeconds: options.cacheTtlSeconds || 30,
      version: options.version || '1.0.0',
    });
  }

  /**
   * Fetches transit status and ETAs for given origin/destination coordinates
   * @param {Object} context JourneyContext
   * @returns {Promise<Object>} Transit status object
   */
  async getTransitStatus(context) {
    throw new Error('Method getTransitStatus() must be implemented by subclass.');
  }
}

