import { homeRepository } from "./home.repository.js";
import { HomeMapper } from "./home.mapper.js";

/**
 * ============================================================================
 * SARTHEE AI — HOME SERVICE
 * ============================================================================
 *
 * Application/business orchestration layer for the Home module.
 *
 * Architecture:
 *
 * Controller
 *    ↓
 * HomeService
 *    ├── Repository
 *    ├── Mapper
 *    ├── Cache
 *    ├── Request deduplication
 *    └── Refresh / invalidation policy
 *    ↓
 * Stable Home API payload
 *
 * Responsibilities:
 *
 * • Coordinate HomeRepository
 * • Map repository data into public responses
 * • Cache mapped Home responses
 * • Generate request-aware cache keys
 * • Deduplicate concurrent identical requests
 * • Support force refresh
 * • Support explicit cache invalidation
 * • Keep cache failures non-fatal
 * • Remain testable through dependency injection
 *
 * The service intentionally contains no:
 *
 * • Express request/response objects
 * • HTTP routing
 * • Zod parsing
 * • database implementation
 * • Flutter-specific logic
 */

// =============================================================================
// DEFAULT CONFIGURATION
// =============================================================================

export const HOME_SERVICE_DEFAULTS = Object.freeze({
  cacheTtlMs: 5 * 60 * 1000,

  cachePrefix: "home",

  cacheVersion: "v1",
});

// =============================================================================
// HOME SERVICE
// =============================================================================

export class HomeService {
  constructor({
    repository = homeRepository,

    mapper = HomeMapper,

    cache = null,

    cacheTtlMs = HOME_SERVICE_DEFAULTS.cacheTtlMs,

    cachePrefix = HOME_SERVICE_DEFAULTS.cachePrefix,

    cacheVersion = HOME_SERVICE_DEFAULTS.cacheVersion,

    clock = () => Date.now(),
  } = {}) {
    validateRepository(repository);
    validateMapper(mapper);
    validateCache(cache);
    validateClock(clock);
    validateCacheTtl(cacheTtlMs);

    this._repository = repository;

    this._mapper = mapper;

    this._cache = cache;

    this._cacheTtlMs = cacheTtlMs;

    this._cachePrefix = normalizeCacheSegment(cachePrefix, "home");

    this._cacheVersion = normalizeCacheSegment(cacheVersion, "v1");

    this._clock = clock;

    /**
     * In-flight request registry.
     *
     * If multiple identical Home requests arrive while one repository request
     * is already running, they share the same Promise instead of duplicating
     * the work.
     */
    this._inFlight = new Map();
  }

  // ==========================================================================
  // GET HOME
  // ==========================================================================

  /**
   * Retrieves Home content.
   *
   * Default strategy:
   *
   * 1. Normalize context
   * 2. Build deterministic cache key
   * 3. Read cache
   * 4. Reuse in-flight request when available
   * 5. Fetch repository
   * 6. Map response
   * 7. Write cache
   */
  async getHomeContent(context = {}, { forceRefresh = false } = {}) {
    const normalizedContext = normalizeContext(context);

    const cacheKey = this.buildCacheKey(normalizedContext);

    // ------------------------------------------------------------------------
    // CACHE HIT
    // ------------------------------------------------------------------------

    if (!forceRefresh) {
      const cached = await this._readCache(cacheKey);

      if (cached !== null) {
        return cached;
      }
    }

    // ------------------------------------------------------------------------
    // REQUEST DEDUPLICATION
    // ------------------------------------------------------------------------

    const existingRequest = this._inFlight.get(cacheKey);

    if (existingRequest) {
      return existingRequest;
    }

    // ------------------------------------------------------------------------
    // LOAD
    // ------------------------------------------------------------------------

    const operation = this._loadAndCache({
      context: normalizedContext,
      cacheKey,
    });

    this._inFlight.set(cacheKey, operation);

    try {
      return await operation;
    } finally {
      /*
       * Delete only if this exact operation still owns the key.
       *
       * This protects against future changes where another request could be
       * registered under the same key before cleanup completes.
       */
      if (this._inFlight.get(cacheKey) === operation) {
        this._inFlight.delete(cacheKey);
      }
    }
  }

  // ==========================================================================
  // REFRESH
  // ==========================================================================

  /**
   * Forces authoritative Home retrieval.
   *
   * Cache lookup is bypassed, but the resulting fresh response is cached.
   */
  async refreshHomeContent(context = {}) {
    return this.getHomeContent(context, {
      forceRefresh: true,
    });
  }

  // ==========================================================================
  // CACHE INVALIDATION
  // ==========================================================================

  /**
   * Invalidates one context-specific Home cache entry.
   */
  async invalidate(context = {}) {
    const normalizedContext = normalizeContext(context);

    const cacheKey = this.buildCacheKey(normalizedContext);

    return this._deleteCache(cacheKey);
  }

  /**
   * Attempts to clear all Home cache entries.
   *
   * If the configured cache implementation supports prefix deletion, that
   * capability is preferred.
   *
   * Otherwise a regular clear() operation is used when available.
   */
  async invalidateAll() {
    if (!this._cache) {
      return false;
    }

    try {
      const prefix = `${this._cachePrefix}:${this._cacheVersion}:`;

      if (typeof this._cache.deleteByPrefix === "function") {
        await this._cache.deleteByPrefix(prefix);

        return true;
      }

      if (typeof this._cache.clear === "function") {
        await this._cache.clear();

        return true;
      }

      return false;
    } catch {
      /*
       * Cache infrastructure should never make Home unavailable.
       */
      return false;
    }
  }

  // ==========================================================================
  // READINESS
  // ==========================================================================

  /**
   * Checks whether the repository backing the Home service is ready.
   */
  async isReady() {
    if (typeof this._repository.isReady !== "function") {
      return true;
    }

    try {
      return Boolean(await this._repository.isReady());
    } catch {
      return false;
    }
  }

  // ==========================================================================
  // CACHE KEY
  // ==========================================================================

  /**
   * Builds a deterministic cache key from request context.
   *
   * Raw user identifiers are never written directly into cache keys.
   */
  buildCacheKey(context = {}) {
    const normalized = normalizeContext(context);

    const location = normalized.locationName ?? "-";

    const coordinates =
      normalized.latitude !== undefined && normalized.longitude !== undefined
        ? `${normalizeCoordinateForKey(
            normalized.latitude,
          )},${normalizeCoordinateForKey(normalized.longitude)}`
        : "-";

    const locale = normalized.locale ?? "-";

    const userContext = normalized.userId ? stableHash(normalized.userId) : "-";

    const personalization = normalized.forcePersonalization ? "1" : "0";

    return [
      this._cachePrefix,
      this._cacheVersion,
      encodeCacheSegment(location),
      encodeCacheSegment(coordinates),
      encodeCacheSegment(locale),
      userContext,
      personalization,
    ].join(":");
  }

  // ==========================================================================
  // INTERNAL LOAD
  // ==========================================================================

  async _loadAndCache({ context, cacheKey }) {
    const raw = await this._repository.getHomeContent(context);

    const mapped = this._mapper.toResponse(raw);

    await this._writeCache(cacheKey, mapped);

    return mapped;
  }

  // ==========================================================================
  // CACHE READ
  // ==========================================================================

  async _readCache(key) {
    if (!this._cache) {
      return null;
    }

    try {
      let entry;

      if (typeof this._cache.get === "function") {
        entry = await this._cache.get(key);
      } else {
        return null;
      }

      if (entry === null || entry === undefined) {
        return null;
      }

      /*
       * Support caches returning raw values directly.
       */
      if (!isCacheEnvelope(entry)) {
        return entry;
      }

      if (
        entry.expiresAt !== null &&
        entry.expiresAt !== undefined &&
        this._clock() > entry.expiresAt
      ) {
        await this._deleteCache(key);

        return null;
      }

      return entry.value;
    } catch {
      return null;
    }
  }

  // ==========================================================================
  // CACHE WRITE
  // ==========================================================================

  async _writeCache(key, value) {
    if (!this._cache) {
      return false;
    }

    if (typeof this._cache.set !== "function") {
      return false;
    }

    try {
      const expiresAt =
        this._cacheTtlMs > 0 ? this._clock() + this._cacheTtlMs : null;

      const envelope = Object.freeze({
        value,

        cachedAt: this._clock(),

        expiresAt,
      });

      /*
       * Generic cache contract:
       *
       * set(key, value, options)
       *
       * Cache implementations that ignore the third argument remain
       * compatible.
       */
      await this._cache.set(key, envelope, {
        ttlMs: this._cacheTtlMs,
      });

      return true;
    } catch {
      /*
       * Repository success must not be converted into API failure merely
       * because cache persistence failed.
       */
      return false;
    }
  }

  // ==========================================================================
  // CACHE DELETE
  // ==========================================================================

  async _deleteCache(key) {
    if (!this._cache || typeof this._cache.delete !== "function") {
      return false;
    }

    try {
      await this._cache.delete(key);

      return true;
    } catch {
      return false;
    }
  }
}

// =============================================================================
// CONTEXT NORMALIZATION
// =============================================================================

function normalizeContext(context) {
  if (
    context === null ||
    typeof context !== "object" ||
    Array.isArray(context)
  ) {
    return Object.freeze({
      forcePersonalization: false,
    });
  }

  const locationName = normalizeOptionalText(context.locationName);

  const locale = normalizeOptionalText(context.locale);

  const userId = normalizeOptionalText(context.userId);

  const latitude = normalizeCoordinate(context.latitude, -90, 90);

  const longitude = normalizeCoordinate(context.longitude, -180, 180);

  const hasCoordinates = latitude !== undefined && longitude !== undefined;

  return Object.freeze({
    ...(locationName !== undefined && {
      locationName,
    }),

    ...(hasCoordinates && {
      latitude,
      longitude,
    }),

    ...(locale !== undefined && {
      locale,
    }),

    ...(userId !== undefined && {
      userId,
    }),

    forcePersonalization: Boolean(context.forcePersonalization),
  });
}

// =============================================================================
// TEXT NORMALIZATION
// =============================================================================

function normalizeOptionalText(value) {
  if (typeof value !== "string") {
    return undefined;
  }

  const normalized = value.trim();

  return normalized.length > 0 ? normalized : undefined;
}

// =============================================================================
// COORDINATE NORMALIZATION
// =============================================================================

function normalizeCoordinate(value, minimum, maximum) {
  if (
    typeof value !== "number" ||
    !Number.isFinite(value) ||
    value < minimum ||
    value > maximum
  ) {
    return undefined;
  }

  return value;
}

function normalizeCoordinateForKey(value) {
  /*
   * Six decimal places provides sub-meter-ish precision while preventing
   * irrelevant floating-point representation differences in cache keys.
   */
  return Number(value)
    .toFixed(6)
    .replace(/\.?0+$/, "");
}

// =============================================================================
// CACHE HELPERS
// =============================================================================

function isCacheEnvelope(value) {
  return (
    value !== null &&
    typeof value === "object" &&
    Object.prototype.hasOwnProperty.call(value, "value") &&
    Object.prototype.hasOwnProperty.call(value, "cachedAt")
  );
}

function normalizeCacheSegment(value, fallback) {
  const normalized = normalizeOptionalText(value);

  return normalized ?? fallback;
}

function encodeCacheSegment(value) {
  return encodeURIComponent(String(value));
}

// =============================================================================
// PRIVACY-SAFE USER KEY
// =============================================================================

/**
 * Small deterministic non-cryptographic hash used only to avoid storing raw
 * user identifiers in cache keys.
 *
 * This is NOT intended for passwords, authentication, signatures, or other
 * security-sensitive cryptographic purposes.
 */
function stableHash(value) {
  const input = String(value);

  let hash = 2166136261;

  for (let index = 0; index < input.length; index += 1) {
    hash ^= input.charCodeAt(index);

    hash = Math.imul(hash, 16777619);
  }

  return (hash >>> 0).toString(16);
}

// =============================================================================
// DEPENDENCY VALIDATION
// =============================================================================

function validateRepository(repository) {
  if (!repository || typeof repository.getHomeContent !== "function") {
    throw new TypeError(
      "HomeService repository must implement getHomeContent().",
    );
  }
}

function validateMapper(mapper) {
  if (!mapper || typeof mapper.toResponse !== "function") {
    throw new TypeError("HomeService mapper must implement toResponse().");
  }
}

function validateCache(cache) {
  if (cache === null) {
    return;
  }

  if (typeof cache !== "object") {
    throw new TypeError("HomeService cache must be an object or null.");
  }
}

function validateClock(clock) {
  if (typeof clock !== "function") {
    throw new TypeError("HomeService clock must be a function.");
  }
}

function validateCacheTtl(cacheTtlMs) {
  if (!Number.isFinite(cacheTtlMs) || cacheTtlMs < 0) {
    throw new TypeError(
      "HomeService cacheTtlMs must be a non-negative finite number.",
    );
  }
}

// =============================================================================
// FACTORY
// =============================================================================

export function createHomeService(options) {
  return new HomeService(options);
}

// =============================================================================
// DEFAULT INSTANCE
// =============================================================================

export const homeService = new HomeService();

export default homeService;
