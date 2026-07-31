import { IPoiProvider } from './i_poi_provider.js';
import { RedisCacheService } from '../../cache/redis_cache_service.js';
import { logger } from '../../../config/logger.js';

export class OverpassPoiProvider extends IPoiProvider {
  constructor(options = {}) {
    super({
      id: 'overpass_poi',
      name: 'OpenStreetMap Overpass POI Provider',
      priority: 'optional',
      dependencies: [],
      timeoutMs: options.timeoutMs || 2500,
      cacheTtlSeconds: 7200,
      version: '1.0.0',
      isEnabled: options.isEnabled ?? true,
    });

    this.cacheService = options.cacheService || new RedisCacheService();
    this.mirrors = [
      options.primaryUrl || process.env.OVERPASS_API_URL || 'https://overpass-api.de/api/interpreter',
      'https://lz4.overpass-api.de/api/interpreter',
      'https://overpass.openstreetmap.fr/api/interpreter',
    ];
  }

  /**
   * Retrieves prominent nearby landmark using multi-mirror Overpass failover & 2-hour caching
   */
  async getNearbyLandmark(lat, lng, radiusMeters = 100) {
    if (!lat || !lng) return null;

    // 4-Decimal Cache Key
    const cacheKey = `poi:${lat.toFixed(4)}:${lng.toFixed(4)}:${radiusMeters}`;
    const cached = await this.cacheService.get(cacheKey);
    if (cached) {
      return { ...cached, cacheHit: true };
    }

    const startTime = Date.now();

    // Query Overpass QL for nearby named POIs
    const query = `[out:json][timeout:3];node(around:${radiusMeters},${lat},${lng})["name"];out body 10;`;

    for (let i = 0; i < this.mirrors.length; i++) {
      const mirrorUrl = this.mirrors[i];
      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), this.timeoutMs);

        const response = await fetch(mirrorUrl, {
          method: 'POST',
          body: `data=${encodeURIComponent(query)}`,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'Sarthee-AI-Backend/1.0',
          },
          signal: controller.signal,
        });

        clearTimeout(timeoutId);

        if (response.ok) {
          const data = await response.json();
          if (Array.isArray(data.elements) && data.elements.length > 0) {
            const bestPoi = this._rankAndSelectBestPoi(data.elements, lat, lng);
            if (bestPoi) {
              const lookupTimeMs = Date.now() - startTime;
              const result = {
                name: bestPoi.name,
                type: bestPoi.type,
                distanceMeters: bestPoi.distanceMeters,
                landmarkTip: `Near ${bestPoi.name} (${bestPoi.distanceMeters}m away)`,
                provider: 'overpass',
                mirrorUrl,
                lookupTimeMs,
                cacheHit: false,
              };

              // Cache for 2 hours (7200s)
              await this.cacheService.set(cacheKey, result, 7200);
              return result;
            }
          }
        }
      } catch (err) {
        logger.warn({
          event: 'poi_lookup_mirror_switch',
          failedMirror: mirrorUrl,
          nextMirror: this.mirrors[i + 1] || 'none',
          reason: err.message,
          lat,
          lng,
        });
      }
    }

    return null; // Graceful fallback
  }

  /**
   * Private helper to rank POIs by priority & proximity
   */
  _rankAndSelectBestPoi(elements, centerLat, centerLng) {
    const scored = elements
      .map((el) => {
        const name = el.tags?.name;
        if (!name || name.trim().length < 2) return null;

        const dist = this._calculateDistanceMeters(centerLat, centerLng, el.lat, el.lon);
        let categoryWeight = 1.0;
        let type = 'landmark';

        const tags = el.tags || {};
        if (tags.railway || tags.subway || tags.highway === 'bus_stop' || tags.amenity === 'bus_station') {
          categoryWeight = 2.5; // Transit Hubs
          type = 'transit';
        } else if (tags.amenity === 'bank' || tags.amenity === 'hospital' || tags.amenity === 'place_of_worship') {
          categoryWeight = 2.0; // Essential Amenities
          type = 'amenity';
        } else if (tags.shop || tags.amenity === 'restaurant' || tags.amenity === 'fast_food') {
          categoryWeight = 1.8; // Commercial / Sweet Shops
          type = 'shop';
        }

        // Distance score penalty (closer is higher score)
        const score = (categoryWeight * 100) / (dist + 5);

        return {
          name: name.trim(),
          type,
          distanceMeters: Math.round(dist),
          score,
        };
      })
      .filter(Boolean);

    if (scored.length === 0) return null;

    // Sort by highest category/distance score
    scored.sort((a, b) => b.score - a.score);
    return scored[0];
  }

  _calculateDistanceMeters(lat1, lon1, lat2, lon2) {
    const R = 6371000; // meters
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos((lat1 * Math.PI) / 180) *
        Math.cos((lat2 * Math.PI) / 180) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return Math.round(R * c);
  }
}

