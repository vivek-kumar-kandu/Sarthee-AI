import { IPoiNearbyProvider } from './i_nearby_poi_provider.js';
import { logger } from '../../../config/logger.js';
import nearbyConfig from '../../../config/nearby.json' with { type: 'json' };

const MIRRORS = nearbyConfig.providers.mirrors;
const TIMEOUT_MS = nearbyConfig.providers.timeoutMs;

class BaseOverpassProvider extends IPoiNearbyProvider {
  constructor(opts) {
    super(opts);
    this.mirrors = MIRRORS;
  }

  _buildQuery(_lat, _lng, _radiusMeters) {
    throw new Error(`${this.id}._buildQuery() must be implemented.`);
  }

  _normalize(el, centerLat, centerLng) {
    const lat = el.lat ?? el.center?.lat;
    const lng = el.lon ?? el.center?.lon;
    if (!lat || !lng) return null;

    const name = el.tags?.name || el.tags?.['name:en'] || null;
    if (!name) return null;

    const distanceKm = this._haversineKm(centerLat, centerLng, lat, lng);

    return {
      id: `osm_${el.type}_${el.id}`,
      osmId: el.id,
      osmType: el.type,
      name,
      category: this.category,
      lat,
      lng,
      distanceKm: Math.round(distanceKm * 10) / 10,
      distanceMeters: Math.round(distanceKm * 1000),
      tags: el.tags || {},
      provider: this.id,
    };
  }

  _haversineKm(lat1, lon1, lat2, lon2) {
    const R = 6371;
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos((lat1 * Math.PI) / 180) *
        Math.cos((lat2 * Math.PI) / 180) *
        Math.sin(dLon / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }

  async execute(context) {
    const { lat, lng } = context.userLocation;
    const radiusMeters = context.radius || 5000;
    const query = this._buildQuery(lat, lng, radiusMeters);

    for (const mirrorUrl of this.mirrors) {
      try {
        const controller = new AbortController();
        const tid = setTimeout(() => controller.abort(), TIMEOUT_MS);

        const response = await fetch(mirrorUrl, {
          method: 'POST',
          body: `data=${encodeURIComponent(query)}`,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'Sarthee-AI-Backend/1.0',
          },
          signal: controller.signal,
        });
        clearTimeout(tid);

        if (!response.ok) continue;

        const data = await response.json();
        const elements = Array.isArray(data.elements) ? data.elements : [];

        const pois = elements
          .map((el) => this._normalize(el, lat, lng))
          .filter(Boolean);

        return pois;
      } catch (err) {
        logger.warn({
          event: 'nearby_provider_mirror_fail',
          provider: this.id,
          mirror: mirrorUrl,
          error: err.message,
        });
      }
    }

    return [];
  }
}

export class HeritageProvider extends BaseOverpassProvider {
  constructor(opts = {}) {
    super({ id: 'heritage_provider', name: 'Heritage & Monuments Provider', category: 'heritage', ...opts });
  }

  _buildQuery(lat, lng, r) {
    return `[out:json][timeout:10];
(
  node(around:${r},${lat},${lng})[tourism~"attraction|monument|museum|artwork|viewpoint|fort|palace|castle"];
  way(around:${r},${lat},${lng})[tourism~"attraction|monument|museum|artwork|viewpoint|fort|palace|castle"];
  node(around:${r},${lat},${lng})[historic~"fort|palace|monument|ruins|archaeological_site|memorial"];
  way(around:${r},${lat},${lng})[historic~"fort|palace|monument|ruins|archaeological_site|memorial"];
);
out center 30;`;
  }

  _normalize(el, cLat, cLng) {
    const base = super._normalize(el, cLat, cLng);
    if (!base) return null;
    return {
      ...base,
      subcategory: el.tags?.tourism || el.tags?.historic || 'heritage',
      isIndoor: !!el.tags?.indoor || el.tags?.tourism === 'museum',
      estimatedVisitHours: el.tags?.tourism === 'museum' ? 1.5 : 2,
    };
  }
}

export class FoodProvider extends BaseOverpassProvider {
  constructor(opts = {}) {
    super({ id: 'food_provider', name: 'Food & Restaurants Provider', category: 'food', ...opts });
  }

  _buildQuery(lat, lng, r) {
    return `[out:json][timeout:10];
node(around:${r},${lat},${lng})[amenity~"restaurant|cafe|fast_food|food_court|bar|bakery|ice_cream"];
out body 30;`;
  }

  _normalize(el, cLat, cLng) {
    const base = super._normalize(el, cLat, cLng);
    if (!base) return null;
    return {
      ...base,
      subcategory: el.tags?.amenity || 'restaurant',
      cuisine: el.tags?.cuisine || null,
      isVeg: el.tags?.diet_vegetarian === 'yes' || el.tags?.diet_vegan === 'yes',
      isIndoor: true,
    };
  }
}

export class HotelProvider extends BaseOverpassProvider {
  constructor(opts = {}) {
    super({ id: 'hotel_provider', name: 'Hotels & Stays Provider', category: 'hotels', ...opts });
  }

  _buildQuery(lat, lng, r) {
    return `[out:json][timeout:10];
(
  node(around:${r},${lat},${lng})[tourism~"hotel|guest_house|hostel|motel|resort|apartment"];
  way(around:${r},${lat},${lng})[tourism~"hotel|guest_house|hostel|motel|resort|apartment"];
);
out center 20;`;
  }

  _normalize(el, cLat, cLng) {
    const base = super._normalize(el, cLat, cLng);
    if (!base) return null;
    return {
      ...base,
      subcategory: el.tags?.tourism || 'hotel',
      stars: el.tags?.stars ? parseInt(el.tags.stars) : null,
      phone: el.tags?.phone || el.tags?.['contact:phone'] || null,
      website: el.tags?.website || el.tags?.['contact:website'] || null,
      isIndoor: true,
    };
  }
}

export class EmergencyProvider extends BaseOverpassProvider {
  constructor(opts = {}) {
    super({ id: 'emergency_provider', name: 'Emergency Services Provider', category: 'emergency', ...opts });
  }

  _buildQuery(lat, lng, r) {
    return `[out:json][timeout:10];
node(around:${r},${lat},${lng})[amenity~"hospital|clinic|pharmacy|police|fire_station"];
out body 20;`;
  }

  _normalize(el, cLat, cLng) {
    const base = super._normalize(el, cLat, cLng);
    if (!base) return null;

    const amenity = el.tags?.amenity || 'emergency';
    const urgencyMap = {
      hospital: 'critical',
      clinic: 'high',
      pharmacy: 'medium',
      police: 'high',
      fire_station: 'critical',
    };

    return {
      ...base,
      subcategory: amenity,
      urgencyLevel: urgencyMap[amenity] || 'medium',
      phone: el.tags?.phone || el.tags?.['contact:phone'] || null,
      isOpen24h: el.tags?.opening_hours === '24/7',
      isIndoor: true,
    };
  }
}
