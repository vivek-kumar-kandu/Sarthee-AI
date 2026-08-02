import { logger } from '../../config/logger.js';

/**
 * Standardized Confidence Scoring Tier Rules
 */
export const CONFIDENCE_TIERS = Object.freeze({
  DIRECT_LIVE: 1.00,        // Direct live provider response
  LIVE_PROCESSED: 0.95,     // Live provider + internal processing
  MULTI_PROVIDER: 0.90,     // Multiple providers combined
  CACHED: 0.75,             // Cached response (LRU / Redis)
  STATIC_TIMETABLE: 0.60,   // Static timetable lookup
  SEASONAL_MODEL: 0.40,     // Seasonal monthly climate model
  MANUAL_FALLBACK: 0.20,    // Manual / Straight-line distance fallback
});

/**
 * DataProvenance — Production Data Provenance Helper
 *
 * Ensures every API payload from Sarthee AI contains transparent,
 * verifiable source provenance metadata matching the "Never Fake Real-Time" principle.
 */
export class DataProvenance {
  /**
   * Constructs single live provider provenance metadata
   */
  static live(providerName, options = {}) {
    const {
      confidence = CONFIDENCE_TIERS.DIRECT_LIVE,
      latencyMs = 0,
      cache = false,
      verified = true,
      providerVersion = 'v1.0',
      metadata = {},
    } = typeof options === 'number' ? { confidence: options } : options;

    return {
      provider: providerName,
      providerVersion,
      live: true,
      fallback: false,
      confidence,
      lastUpdated: new Date().toISOString(),
      latencyMs,
      cache,
      verified,
      ...metadata,
    };
  }

  /**
   * Constructs multi-provider provenance metadata (e.g. Journey / Trip Planner)
   */
  static multiProvider(options = {}) {
    const {
      engine = 'Sarthee Multi-Engine Solver',
      providers = [],
      confidence = CONFIDENCE_TIERS.MULTI_PROVIDER,
      latencyMs = 0,
      cache = false,
      verified = true,
      providerVersion = 'v1.0',
      metadata = {},
    } = options;

    return {
      engine,
      providers: Array.isArray(providers) ? providers : [providers],
      providerVersion,
      live: true,
      fallback: false,
      confidence,
      lastUpdated: new Date().toISOString(),
      latencyMs,
      cache,
      verified,
      ...metadata,
    };
  }

  /**
   * Constructs fallback data provenance metadata
   */
  static fallback(fallbackModelName, reason = 'Provider offline or timed out', options = {}) {
    const {
      confidence = CONFIDENCE_TIERS.MANUAL_FALLBACK,
      latencyMs = 0,
      cache = false,
      verified = false,
      metadata = {},
    } = typeof options === 'string' ? { reason: options } : options;

    logger.debug({ event: 'data_provenance_fallback', fallbackModelName, reason });

    return {
      provider: fallbackModelName,
      live: false,
      fallback: true,
      reason,
      lastUpdated: new Date().toISOString(),
      confidence,
      latencyMs,
      cache,
      verified,
      ...metadata,
    };
  }
}
