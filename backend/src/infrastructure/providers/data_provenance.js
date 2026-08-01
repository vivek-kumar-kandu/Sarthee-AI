import { logger } from '../../config/logger.js';

/**
 * DataProvenance — Production Data Provenance Helper
 *
 * Ensures every API payload from Sarthee AI contains transparent,
 * verifiable source provenance metadata matching the "Never Fake Real-Time" principle.
 */
export class DataProvenance {
  /**
   * Constructs live data provenance metadata
   */
  static live(providerName, confidence = 1.0, metadata = {}) {
    return {
      provider: providerName,
      live: true,
      fallback: false,
      lastUpdated: new Date().toISOString(),
      confidence,
      ...metadata,
    };
  }

  /**
   * Constructs fallback data provenance metadata
   */
  static fallback(fallbackModelName, reason = 'Provider offline or timed out', metadata = {}) {
    logger.debug({ event: 'data_provenance_fallback', fallbackModelName, reason });
    return {
      provider: fallbackModelName,
      live: false,
      fallback: true,
      reason,
      lastUpdated: new Date().toISOString(),
      confidence: 0.8,
      ...metadata,
    };
  }
}
