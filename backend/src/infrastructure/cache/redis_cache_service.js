export class RedisCacheService {
  constructor(defaultTtlSeconds = 600) {
    this.defaultTtlSeconds = defaultTtlSeconds;
    this._memoryStore = new Map();
  }

  /**
   * Generates standardized cache key for journey requests
   */
  generateJourneyKey(originLat, originLng, destLat, destLng, mode = 'balanced') {
    const lat1 = Number(originLat).toFixed(4);
    const lng1 = Number(originLng).toFixed(4);
    const lat2 = Number(destLat).toFixed(4);
    const lng2 = Number(destLng).toFixed(4);
    return `journey:plan:${lat1},${lng1}:${lat2},${lng2}:${mode}`;
  }

  /**
   * Retrieves item from cache if unexpired
   */
  async get(key) {
    const entry = this._memoryStore.get(key);
    if (!entry) return null;

    if (Date.now() > entry.expiresAt) {
      this._memoryStore.delete(key);
      return null;
    }

    try {
      return JSON.parse(entry.value);
    } catch (_) {
      return null;
    }
  }

  /**
   * Stores item in cache with TTL in seconds
   */
  async set(key, value, ttlSeconds = this.defaultTtlSeconds) {
    const expiresAt = Date.now() + ttlSeconds * 1000;
    this._memoryStore.set(key, {
      value: JSON.stringify(value),
      expiresAt,
    });
  }

  /**
   * Clears single key or entire cache
   */
  async del(key) {
    this._memoryStore.delete(key);
  }

  async clear() {
    this._memoryStore.clear();
  }
}

