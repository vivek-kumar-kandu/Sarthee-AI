import { logger } from '../../../../config/logger.js';

/**
 * NearbyCacheService
 *
 * 5-minute TTL caching layer for nearby POI discovery queries.
 * Primary cache: Redis (via RedisCacheService interface)
 * Fallback cache: In-memory Map with TTL expiration & max size limit
 *
 * Cache Key Format:
 *   `nearby:{lat.toFixed(3)}:{lng.toFixed(3)}:{radius}:{category}`
 *
 * Target Performance:
 *   < 400ms response time on cache hit
 */
export class NearbyCacheService {
  /**
   * @param {Object} [options]
   * @param {Object} [options.redisClient] Optional Redis client
   * @param {number} [options.ttlSeconds=300] 5-minute default TTL
   * @param {number} [options.maxMemoryItems=200] In-memory LRU limit
   */
  constructor(options = {}) {
    this.ttlMs = (options.ttlSeconds || 300) * 1000;
    this.redisClient = options.redisClient || null;
    this.memoryCache = new Map();
    this.maxMemoryItems = options.maxMemoryItems || 200;
  }

  /**
   * Generates a 3-decimal rounded cache key (~110m spatial resolution)
   * @param {number} lat Latitude
   * @param {number} lng Longitude
   * @param {number} radius Radius meters
   * @param {string} category Category string
   * @returns {string} Cache key
   */
  generateKey(lat, lng, radius, category) {
    const latRounded = Number(lat).toFixed(3);
    const lngRounded = Number(lng).toFixed(3);
    return `nearby:${latRounded}:${lngRounded}:${radius}:${category}`;
  }

  /**
   * Retrieves cached response if unexpired
   * @param {string} key Cache key
   * @returns {Promise<Object|null>} Cached payload or null
   */
  async get(key) {
    const startTime = Date.now();

    // 1. Try Redis first
    if (this.redisClient) {
      try {
        const raw = await this.redisClient.get(key);
        if (raw) {
          logger.debug({ event: 'nearby_cache_hit_redis', key, elapsedMs: Date.now() - startTime });
          return JSON.parse(raw);
        }
      } catch (err) {
        logger.warn({ event: 'nearby_redis_error', error: err.message });
      }
    }

    // 2. Fallback to In-Memory Map
    const entry = this.memoryCache.get(key);
    if (entry) {
      if (Date.now() < entry.expiresAt) {
        logger.debug({ event: 'nearby_cache_hit_memory', key, elapsedMs: Date.now() - startTime });
        return entry.data;
      }
      // Expired entry
      this.memoryCache.delete(key);
    }

    logger.debug({ event: 'nearby_cache_miss', key, elapsedMs: Date.now() - startTime });
    return null;
  }

  /**
   * Stores response payload in cache
   * @param {string} key Cache key
   * @param {Object} data Payload to store
   * @param {number} [customTtlSeconds] Optional custom TTL
   */
  async set(key, data, customTtlSeconds) {
    const ttlMs = customTtlSeconds ? customTtlSeconds * 1000 : this.ttlMs;
    const expiresAt = Date.now() + ttlMs;

    // 1. Store in Redis
    if (this.redisClient) {
      try {
        await this.redisClient.setEx(key, Math.ceil(ttlMs / 1000), JSON.stringify(data));
      } catch (err) {
        logger.warn({ event: 'nearby_redis_set_error', error: err.message });
      }
    }

    // 2. Store in In-Memory Map
    if (this.memoryCache.size >= this.maxMemoryItems) {
      // Evict oldest entry (LRU simple eviction)
      const oldestKey = this.memoryCache.keys().next().value;
      this.memoryCache.delete(oldestKey);
    }

    this.memoryCache.set(key, { data, expiresAt });
  }

  /** Clears in-memory cache */
  clear() {
    this.memoryCache.clear();
  }
}
