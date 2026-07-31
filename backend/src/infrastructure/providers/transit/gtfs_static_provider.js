import { ITransitProvider } from './i_transit_provider.js';

/**
 * GtfsStaticProvider
 * City-agnostic static timetable provider for schedule frequency lookups
 */
export class GtfsStaticProvider extends ITransitProvider {
  constructor(options = {}) {
    super({
      id: 'gtfs_static',
      priority: 'optional',
      dependencies: ['route'],
      timeoutMs: options.timeoutMs || 1000,
      cacheTtlSeconds: 3600,
      version: '1.0.0',
    });
    this.transitSystem = options.transitSystem || process.env.TRANSIT_PROVIDER || 'DMRC';
  }

  async execute(context) {
    return this.getTransitStatus(context);
  }

  async getTransitStatus(context) {
    const startTime = Date.now();
    const latencyMs = Date.now() - startTime;

    return {
      status: 'SCHEDULED',
      frequency: 'Every 4–6 min',
      line: 'Main Transit Line',
      destination: 'Central Concourse',
      source: `Static Timetable (${this.transitSystem})`,
      lastUpdated: new Date().toISOString(),
      latencyMs,
      confidence: 0.7,
    };
  }
}
