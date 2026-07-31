import { logger } from '../../../../config/logger.js';

/**
 * Curated high-resolution category fallback image URLs.
 * Ensures zero broken image cards in Flutter UI.
 */
const CATEGORY_STATIC_IMAGES = {
  heritage: [
    'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?auto=format&fit=crop&w=800&q=80', // Fort/Palace
    'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=800&q=80', // Monument
  ],
  food: [
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80', // Restaurant
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80', // Cafe
  ],
  hotels: [
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80', // Hotel
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80', // Stay
  ],
  emergency: [
    'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?auto=format&fit=crop&w=800&q=80', // Hospital
  ],
  temples: [
    'https://images.unsplash.com/photo-1609949279531-c4f0ed49e38a?auto=format&fit=crop&w=800&q=80', // Temple
  ],
  parks: [
    'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?auto=format&fit=crop&w=800&q=80', // Park
  ],
  shopping: [
    'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?auto=format&fit=crop&w=800&q=80', // Mall/Market
  ],
  fuel: [
    'https://images.unsplash.com/photo-1527018601619-a508a2be00fe?auto=format&fit=crop&w=800&q=80', // Fuel station
  ],
  fallback: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=800&q=80',
};

/**
 * ImageResolverService
 *
 * Resolves high-resolution POI image URLs through a multi-tier failover priority:
 *
 *   1. Direct OSM image / wikimedia_commons tag
 *   2. Wikipedia PageImages API lookup (if wikipedia/wikidata tag present)
 *   3. Wikipedia title search from POI name
 *   4. Category-specific high-resolution fallback asset
 *   5. Global fallback placeholder
 *
 * 24-hour in-memory caching ensures fast resolution (<10ms for known places).
 */
export class ImageResolverService {
  constructor() {
    /** @type {Map<string, { url: string, source: string, expiresAt: number }>} */
    this.cache = new Map();
    this.cacheTtlMs = 86400 * 1000; // 24-hour TTL
  }

  /**
   * Resolves an image URL for a given POI object.
   * @param {Object} poi POI object from provider
   * @returns {Promise<{ url: string, source: string }>}
   */
  async resolveImage(poi) {
    if (!poi) return { url: CATEGORY_STATIC_IMAGES.fallback, source: 'fallback' };

    const cacheKey = `img:${poi.id || poi.name}`;
    const cached = this.cache.get(cacheKey);
    if (cached && Date.now() < cached.expiresAt) {
      return { url: cached.url, source: cached.source };
    }

    const result = await this._doResolve(poi);
    this.cache.set(cacheKey, { ...result, expiresAt: Date.now() + this.cacheTtlMs });
    return result;
  }

  /** @private */
  async _doResolve(poi) {
    const tags = poi.tags || {};

    // ── Tier 1: Direct OSM image URL tag ────────────────────────────────────
    if (tags.image && typeof tags.image === 'string' && tags.image.startsWith('http')) {
      return { url: tags.image, source: 'osm_image_tag' };
    }

    // ── Tier 2: Wikimedia Commons file tag ─────────────────────────────────
    if (tags.wikimedia_commons) {
      const fileName = tags.wikimedia_commons.replace(/^File:/i, '').trim();
      const commonsUrl = `https://commons.wikimedia.org/wiki/Special:FilePath/${encodeURIComponent(fileName)}?width=800`;
      return { url: commonsUrl, source: 'wikimedia_tag' };
    }

    // ── Tier 3: Wikipedia PageImages API by tag or name ─────────────────────
    const wikiTitle = this._extractWikiTitle(tags, poi.name);
    if (wikiTitle) {
      const wikiUrl = await this._fetchWikipediaImage(wikiTitle);
      if (wikiUrl) {
        return { url: wikiUrl, source: 'wikipedia_api' };
      }
    }

    // ── Tier 4: Category Static Asset Fallback ──────────────────────────────
    const categoryAssets = CATEGORY_STATIC_IMAGES[poi.category] || CATEGORY_STATIC_IMAGES.heritage;
    const index = Math.abs(this._hashCode(poi.name || 'poi')) % categoryAssets.length;
    return {
      url: categoryAssets[index] || CATEGORY_STATIC_IMAGES.fallback,
      source: 'category_static_fallback',
    };
  }

  /** @private */
  _extractWikiTitle(tags, poiName) {
    if (tags.wikipedia) {
      // e.g. "en:Amer Fort" -> "Amer Fort"
      return tags.wikipedia.replace(/^[a-z]{2}:/i, '').trim();
    }
    // Famous landmarks: name search
    if (poiName && poiName.length >= 3) {
      return poiName.trim();
    }
    return null;
  }

  /** @private */
  async _fetchWikipediaImage(title) {
    try {
      const apiUrl = `https://en.wikipedia.org/w/api.php?action=query&titles=${encodeURIComponent(title)}&prop=pageimages&format=json&pithumbsize=800&origin=*`;
      const controller = new AbortController();
      const tid = setTimeout(() => controller.abort(), 2000);

      const resp = await fetch(apiUrl, { signal: controller.signal });
      clearTimeout(tid);

      if (!resp.ok) return null;
      const data = await resp.json();
      const pages = data.query?.pages;
      if (!pages) return null;

      const page = Object.values(pages)[0];
      if (page?.thumbnail?.source) {
        return page.thumbnail.source;
      }
    } catch (err) {
      logger.debug({ event: 'wikipedia_image_fetch_failed', title, error: err.message });
    }
    return null;
  }

  /** Simple string hash for deterministic fallback index */
  _hashCode(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      hash = (hash << 5) - hash + str.charCodeAt(i);
      hash |= 0;
    }
    return hash;
  }
}
