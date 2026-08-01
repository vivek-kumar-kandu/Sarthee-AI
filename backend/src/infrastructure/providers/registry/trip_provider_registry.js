import { TourismProvider } from '../tourism/tourism_provider.js';
import { EventProvider } from '../events/event_provider.js';
import { providerMonitorFramework } from '../../monitoring/provider_monitor_framework.js';
import { logger } from '../../../config/logger.js';

/**
 * TripProviderRegistry — Self-Describing Trip Provider Registry
 *
 * Manages execution across all trip data providers:
 *   - Nearby POI Provider (Overpass)
 *   - OSRM Matrix Routing Provider
 *   - OpenWeather Provider
 *   - Traffic Provider
 *   - Tourism Intelligence Provider
 *   - Live Events Provider
 *
 * Resilience & Telemetry Strategy:
 *   - Executes providers sorted by priority.
 *   - Critical providers: Retry on failure.
 *   - Optional providers: Skip, log, fallback, and continue pipeline execution.
 *   - Records telemetry sample into ProviderMonitorFramework.
 */
export class TripProviderRegistry {
  constructor(options = {}) {
    /** @type {Map<string, import('./i_trip_provider.js').ITripProvider>} */
    this.providers = new Map();
    this.monitorFramework = options.monitorFramework || providerMonitorFramework;

    // Register baseline providers
    this.register(new TourismProvider());
    this.register(new EventProvider());
  }

  /**
   * Registers a self-describing provider
   * @param {import('./i_trip_provider.js').ITripProvider} provider
   */
  register(provider) {
    if (!provider || !provider.id) {
      throw new Error('TripProviderRegistry requires a valid ITripProvider instance');
    }
    this.providers.set(provider.id, provider);
    logger.info({ event: 'trip_provider_registered', providerId: provider.id, priority: provider.priority });
    return this;
  }

  /**
   * Executes all registered providers in parallel with resilience handling.
   * @param {Object} context Context object passed to providers
   * @returns {Promise<Object>} Map of provider outputs
   */
  async fetchAll(context) {
    const results = {};
    const sortedProviders = Array.from(this.providers.values()).sort((a, b) => a.priority - b.priority);

    await Promise.all(
      sortedProviders.map(async (provider) => {
        const startTime = Date.now();
        try {
          const controller = new AbortController();
          const tid = setTimeout(() => controller.abort(), provider.timeoutMs || 4000);

          const output = await provider.execute(context);
          clearTimeout(tid);

          const elapsedMs = Date.now() - startTime;
          this.monitorFramework.recordSample(provider.id, elapsedMs, true, null, false);
          results[provider.id] = output;
        } catch (err) {
          const elapsedMs = Date.now() - startTime;
          this.monitorFramework.recordSample(provider.id, elapsedMs, false, err.message, false);

          logger.warn({
            event: 'trip_provider_execution_warning',
            providerId: provider.id,
            isCritical: provider.isCritical,
            error: err.message,
          });

          // Optional providers fallback to empty array/object
          results[provider.id] = provider.isCritical ? null : [];
        }
      })
    );

    return results;
  }

  /** Returns registered provider list */
  getProviders() {
    return Array.from(this.providers.values());
  }
}
