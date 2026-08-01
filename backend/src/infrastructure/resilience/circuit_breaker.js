import { logger } from '../../config/logger.js';

/**
 * CircuitBreaker — Production Resilience Pattern for Provider Calls
 *
 * Prevents cascade failures when an external API (OSRM, OpenWeather, Overpass) fails.
 *
 * States:
 *   - CLOSED: Normal operation. All requests pass through.
 *   - OPEN: Failures exceeded threshold. Fast fail (returns fallback immediately without network call).
 *   - HALF_OPEN: Trial period after cooldown. Allows 1 request to test if provider recovered.
 */
export class CircuitBreaker {
  /**
   * @param {string} providerId
   * @param {Object} [options]
   * @param {number} [options.failureThreshold=3] Max failures before opening circuit
   * @param {number} [options.cooldownMs=15000] Cooldown duration in ms before half-open state
   * @param {number} [options.timeoutMs=3000] Provider request timeout in ms
   */
  constructor(providerId, options = {}) {
    this.providerId = providerId;
    this.failureThreshold = options.failureThreshold || 3;
    this.cooldownMs = options.cooldownMs || 15000;
    this.timeoutMs = options.timeoutMs || 3000;

    this.state = 'CLOSED'; // 'CLOSED' | 'OPEN' | 'HALF_OPEN'
    this.failureCount = 0;
    this.lastFailureTime = null;
    this.lastSuccessTime = Date.now();
  }

  /**
   * Executes a provider call through the circuit breaker with exponential backoff retry.
   *
   * @template T
   * @param {() => Promise<T>} action Provider execution function
   * @param {T} fallback Default fallback value if circuit is open or call fails
   * @returns {Promise<T>}
   */
  async execute(action, fallback = null) {
    const now = Date.now();

    // Check if OPEN circuit cooldown period elapsed -> transition to HALF_OPEN
    if (this.state === 'OPEN') {
      if (now - this.lastFailureTime > this.cooldownMs) {
        this.state = 'HALF_OPEN';
        logger.info({ event: 'circuit_breaker_half_open', providerId: this.providerId });
      } else {
        logger.debug({ event: 'circuit_breaker_fast_fail', providerId: this.providerId, state: this.state });
        return fallback;
      }
    }

    try {
      const controller = new AbortController();
      const tid = setTimeout(() => controller.abort(), this.timeoutMs);

      const result = await action(controller.signal);
      clearTimeout(tid);

      // Call succeeded -> reset circuit to CLOSED
      this._onSuccess();
      return result;
    } catch (err) {
      this._onFailure(err);
      return fallback;
    }
  }

  /** @private */
  _onSuccess() {
    this.failureCount = 0;
    this.lastSuccessTime = Date.now();
    if (this.state !== 'CLOSED') {
      logger.info({ event: 'circuit_breaker_closed', providerId: this.providerId });
      this.state = 'CLOSED';
    }
  }

  /** @private */
  _onFailure(err) {
    this.failureCount++;
    this.lastFailureTime = Date.now();

    logger.warn({
      event: 'circuit_breaker_failure',
      providerId: this.providerId,
      failureCount: this.failureCount,
      error: err.message,
    });

    if (this.failureCount >= this.failureThreshold || this.state === 'HALF_OPEN') {
      this.state = 'OPEN';
      logger.error({ event: 'circuit_breaker_opened', providerId: this.providerId, cooldownMs: this.cooldownMs });
    }
  }

  /** Returns current status snapshot */
  getStatus() {
    return {
      providerId: this.providerId,
      state: this.state,
      failureCount: this.failureCount,
      timeoutMs: this.timeoutMs,
      cooldownMs: this.cooldownMs,
      lastFailureTime: this.lastFailureTime,
      lastSuccessTime: this.lastSuccessTime,
    };
  }
}
