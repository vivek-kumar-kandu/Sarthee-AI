/**
 * TrafficFeedMonitor
 * Tracks traffic feed health states and operational latency metrics
 */
export class TrafficFeedMonitor {
  static STATES = {
    UNCONFIGURED: 'UNCONFIGURED',
    HEALTHY: 'HEALTHY',
    DELAYED: 'DELAYED',
    OFFLINE: 'OFFLINE',
  };

  constructor() {
    this.state = TrafficFeedMonitor.STATES.UNCONFIGURED;
    this.metrics = {
      latencyMs: 0,
      fallbackCount: 0,
      lastUpdated: null,
    };
  }

  setFeedConfigured(isConfigured) {
    if (!isConfigured) {
      this.state = TrafficFeedMonitor.STATES.UNCONFIGURED;
    } else if (this.state === TrafficFeedMonitor.STATES.UNCONFIGURED) {
      this.state = TrafficFeedMonitor.STATES.HEALTHY;
    }
  }

  recordSuccess(latencyMs) {
    this.state = TrafficFeedMonitor.STATES.HEALTHY;
    this.metrics.latencyMs = latencyMs;
    this.metrics.lastUpdated = new Date().toISOString();
  }

  recordFailure() {
    this.metrics.fallbackCount += 1;
    this.state = TrafficFeedMonitor.STATES.OFFLINE;
  }

  getStatus() {
    return {
      state: this.state,
      metrics: { ...this.metrics },
    };
  }
}
