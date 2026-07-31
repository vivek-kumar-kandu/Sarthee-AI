/**
 * TransitStatusService
 * Pure domain service coordinating live and static transit providers and assembling transit metadata envelopes
 */
export class TransitStatusService {
  constructor(realtimeProvider = null, staticProvider = null) {
    this.realtimeProvider = realtimeProvider;
    this.staticProvider = staticProvider;
  }

  /**
   * Evaluates transit status and returns standardized transit envelope
   * @param {Object} context JourneyContext
   * @returns {Promise<Object>} Standardized transit metadata object
   */
  async resolveTransitStatus(context) {
    if (this.realtimeProvider) {
      try {
        const liveEnvelope = await this.realtimeProvider.getTransitStatus(context);
        if (liveEnvelope && liveEnvelope.status === 'LIVE') {
          return liveEnvelope;
        }
      } catch (_) {
        // Fallback to static provider
      }
    }

    if (this.staticProvider) {
      return this.staticProvider.getTransitStatus(context);
    }

    return {
      status: 'SCHEDULED',
      frequency: 'Every 4–6 min',
      source: 'Static Timetable',
      lastUpdated: new Date().toISOString(),
      latencyMs: 0,
      confidence: 0.7,
    };
  }
}

