/**
 * TransitFeedMonitor
 * Monitors GTFS feed health states and operational metrics
 */
export class TransitFeedMonitor {
  static STATES = {
    UNCONFIGURED: 'UNCONFIGURED',
    HEALTHY: 'HEALTHY',
    DELAYED: 'DELAYED',
    OFFLINE: 'OFFLINE',
    RECOVERING: 'RECOVERING',
  };

  constructor() {
    this.state = TransitFeedMonitor.STATES.UNCONFIGURED;
    this.metrics = {
      latencyMs: 0,
      cacheHits: 0,
      fallbackCount: 0,
      retryCount: 0,
      lastUpdated: null,
    };
  }

  setFeedConfigured(isConfigured) {
    if (!isConfigured) {
      this.state = TransitFeedMonitor.STATES.UNCONFIGURED;
    } else if (this.state === TransitFeedMonitor.STATES.UNCONFIGURED) {
      this.state = TransitFeedMonitor.STATES.HEALTHY;
    }
  }

  recordSuccess(latencyMs, isCacheHit = false) {
    this.state = TransitFeedMonitor.STATES.HEALTHY;
    this.metrics.latencyMs = latencyMs;
    this.metrics.lastUpdated = new Date().toISOString();
    if (isCacheHit) {
      this.metrics.cacheHits += 1;
    }
  }

  recordFailure(reason = 'timeout') {
    this.metrics.fallbackCount += 1;
    this.state = TransitFeedMonitor.STATES.OFFLINE;
  }

  recordRetry() {
    this.metrics.retryCount += 1;
  }

  getStatus() {
    return {
      state: this.state,
      metrics: { ...this.metrics },
    };
  }
}

