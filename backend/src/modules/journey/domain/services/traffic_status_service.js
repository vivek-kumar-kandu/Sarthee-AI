/**
 * TrafficStatusService
 * Pure domain service formatting traffic congestion envelopes
 */
export class TrafficStatusService {
  constructor(trafficProvider = null) {
    this.trafficProvider = trafficProvider;
  }

  async resolveTrafficStatus(context) {
    if (this.trafficProvider) {
      try {
        return await this.trafficProvider.getTrafficStatus(context);
      } catch (_) {
        // Fallback
      }
    }

    return {
      status: 'UNAVAILABLE',
      delayMinutes: 0,
      severity: 'NONE',
      source: 'Unconfigured Traffic Feed',
      confidence: 0.0,
    };
  }
}
