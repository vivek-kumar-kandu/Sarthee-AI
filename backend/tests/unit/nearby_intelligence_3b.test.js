/**
 * Phase 3B — Nearby Intelligence Suite Unit Tests
 *
 * Tests:
 *   1. NearbyCacheService (<400ms target, memory LRU & TTL expiry)
 *   2. ImageResolverService (multi-tier resolution & category static fallbacks)
 *   3. NearbyAdvisorService (grounded advice schema & fallback structure)
 *   4. SearchQueryParser (intent, category, attribute tag extraction)
 *   5. FavoritesService & Collections (1-click collection-to-SmartRoute payload mapping)
 *   6. NearbyAnalyticsService (impression & conversion tracking)
 */

import { describe, test } from 'node:test';
import assert from 'node:assert/strict';

import { NearbyCacheService } from '../../src/modules/nearby/domain/services/nearby_cache_service.js';
import { ImageResolverService } from '../../src/modules/nearby/domain/services/image_resolver_service.js';
import { NearbyAdvisorService } from '../../src/modules/nearby/domain/services/nearby_advisor_service.js';
import { SearchQueryParser } from '../../src/modules/nearby/domain/services/search_query_parser.js';
import { FavoritesService } from '../../src/modules/favorites/domain/services/favorites_service.js';
import { NearbyAnalyticsService } from '../../src/modules/nearby/domain/services/nearby_analytics_service.js';
import { NearbyContext } from '../../src/modules/nearby/domain/value_objects/nearby_context.js';

const DUMMY_LOC = { lat: 26.9124, lng: 75.7873 };

function makeContext() {
  return new NearbyContext({ userLocation: DUMMY_LOC, category: 'heritage' });
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. NearbyCacheService (3B.1 Performance Layer)
// ─────────────────────────────────────────────────────────────────────────────
describe('NearbyCacheService (3B.1 Performance Layer)', () => {
  test('generates rounded 3-decimal cache key', () => {
    const cache = new NearbyCacheService();
    const key = cache.generateKey(26.912456, 75.787312, 5000, 'heritage');
    assert.strictEqual(key, 'nearby:26.912:75.787:5000:heritage');
  });

  test('stores and retrieves items from in-memory fallback', async () => {
    const cache = new NearbyCacheService({ ttlSeconds: 10 });
    const key = 'nearby:26.912:75.787:5000:food';
    const payload = { items: [{ name: 'Test Dhaba' }] };

    await cache.set(key, payload);
    const retrieved = await cache.get(key);
    assert.deepStrictEqual(retrieved, payload);
  });

  test('returns null for expired entries', async () => {
    const cache = new NearbyCacheService();
    const key = 'nearby:expired:key';
    await cache.set(key, { data: 1 }, 0.001); // 1ms TTL
    await new Promise((r) => setTimeout(r, 10)); // wait for expiry

    const retrieved = await cache.get(key);
    assert.strictEqual(retrieved, null);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 2. ImageResolverService (3B.2 Content Layer)
// ─────────────────────────────────────────────────────────────────────────────
describe('ImageResolverService (3B.2 Content Layer)', () => {
  const resolver = new ImageResolverService();

  test('returns direct OSM image tag when available', async () => {
    const poi = { id: 'p1', name: 'Amer Fort', category: 'heritage', tags: { image: 'https://example.com/fort.jpg' } };
    const res = await resolver.resolveImage(poi);
    assert.strictEqual(res.url, 'https://example.com/fort.jpg');
    assert.strictEqual(res.source, 'osm_image_tag');
  });

  test('constructs Wikimedia Commons URL from wikimedia_commons tag', async () => {
    const poi = { id: 'p2', name: 'Hawa Mahal', category: 'heritage', tags: { wikimedia_commons: 'File:Hawa_Mahal_Jaipur.jpg' } };
    const res = await resolver.resolveImage(poi);
    assert.ok(res.url.includes('commons.wikimedia.org'));
    assert.strictEqual(res.source, 'wikimedia_tag');
  });

  test('falls back to high-resolution category static image for unknown places', async () => {
    const poi = { id: 'p3', name: 'Unknown Cafe', category: 'food', tags: {} };
    const res = await resolver.resolveImage(poi);
    assert.ok(res.url.startsWith('http'));
    assert.strictEqual(res.source, 'category_static_fallback');
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 3. NearbyAdvisorService (3B.3 AI Intelligence Layer)
// ─────────────────────────────────────────────────────────────────────────────
describe('NearbyAdvisorService (3B.3 AI Intelligence Layer)', () => {
  const advisor = new NearbyAdvisorService();

  test('generates grounded structured fallback advice when API key is missing', async () => {
    const ctx = makeContext();
    const poi = { name: 'Amer Fort', category: 'heritage', score: 95, distanceKm: 2.3, reasons: ['Open Now', 'Highly Rated'] };
    const advice = await advisor.generateAdvice(poi, ctx);

    assert.ok('summary' in advice);
    assert.ok('whyRecommended' in advice);
    assert.ok('bestTime' in advice);
    assert.ok('estimatedVisit' in advice);
    assert.ok('weatherAdvice' in advice);
    assert.ok('familyFriendly' in advice);
    assert.ok('accessibility' in advice);
    assert.ok('confidence' in advice);
    assert.strictEqual(advice.aiGenerated, false);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 4. SearchQueryParser (3B.4 Smart Search Layer)
// ─────────────────────────────────────────────────────────────────────────────
describe('SearchQueryParser (3B.4 Smart Search Layer)', () => {
  const parser = new SearchQueryParser();

  test('extracts food category and veg tag from "Best Veg Restaurant near me"', () => {
    const res = parser.parse('Best Veg Restaurant near me');
    assert.strictEqual(res.inferredCategory, 'food');
    assert.ok(res.detectedTags.includes('veg'));
  });

  test('extracts heritage category, familyFriendly, and sunset tags', () => {
    const res = parser.parse('Family friendly fort for sunset photo');
    assert.strictEqual(res.inferredCategory, 'heritage');
    assert.ok(res.detectedTags.includes('familyFriendly'));
    assert.ok(res.detectedTags.includes('sunset'));
    assert.ok(res.detectedTags.includes('photography'));
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 5. FavoritesService & Collections (3B.5 Personalization Layer)
// ─────────────────────────────────────────────────────────────────────────────
describe('FavoritesService & Collections (3B.5 Personalization Layer)', () => {
  const service = new FavoritesService();

  test('adds and retrieves user favorites', async () => {
    const poi = { id: 'amer_fort', name: 'Amer Fort', category: 'heritage' };
    const favs = await service.addFavorite('user_123', poi);
    assert.strictEqual(favs.length, 1);
    assert.strictEqual(favs[0].name, 'Amer Fort');
  });

  test('creates collection and converts to 1-Click Smart Route payload', async () => {
    const col = await service.createCollection('user_123', {
      title: 'Jaipur Heritage Expedition',
      pois: [
        { name: 'Amer Fort', lat: 26.9855, lng: 75.8513 },
        { name: 'Jal Mahal', lat: 26.9534, lng: 75.8462 },
        { name: 'Hawa Mahal', lat: 26.9239, lng: 75.8267 },
      ],
    });

    assert.strictEqual(col.title, 'Jaipur Heritage Expedition');
    assert.strictEqual(col.itemCount, 3);

    const smartRoute = await service.convertCollectionToSmartRoute('user_123', col.id);
    assert.strictEqual(smartRoute.title, 'Jaipur Heritage Expedition');
    assert.strictEqual(smartRoute.origin.name, 'Amer Fort');
    assert.strictEqual(smartRoute.destination.name, 'Hawa Mahal');
    assert.strictEqual(smartRoute.waypoints.length, 1);
    assert.strictEqual(smartRoute.totalStops, 3);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 6. NearbyAnalyticsService (3B.6 Analytics Layer)
// ─────────────────────────────────────────────────────────────────────────────
describe('NearbyAnalyticsService (3B.6 Analytics Layer)', () => {
  test('tracks POI impressions and navigation conversion taps', () => {
    const analytics = new NearbyAnalyticsService();
    analytics.recordPoiView('amer_fort', 'heritage');
    analytics.recordPoiView('amer_fort', 'heritage');
    analytics.recordNavigateTap('amer_fort');

    const summary = analytics.getTelemetrySummary();
    assert.strictEqual(summary.totalPoiViews, 2);
    assert.strictEqual(summary.totalNavigations, 1);
    assert.strictEqual(summary.topCategory, 'heritage');
  });
});
