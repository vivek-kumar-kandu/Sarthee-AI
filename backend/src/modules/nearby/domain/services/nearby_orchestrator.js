import { NearbyContext } from '../value_objects/nearby_context.js';
import { NearbyRankingEngine } from './nearby_ranking_engine.js';
import { NearbyCacheService } from './nearby_cache_service.js';
import { ImageResolverService } from './image_resolver_service.js';
import { NearbyAdvisorService } from './nearby_advisor_service.js';
import { SearchQueryParser } from './search_query_parser.js';
import { NearbyAnalyticsService } from './nearby_analytics_service.js';
import { logger } from '../../../../config/logger.js';
import nearbyConfig from '../../../../config/nearby.json' with { type: 'json' };

const DEFAULT_LIMIT = nearbyConfig.limits.defaultPerCategory;

/**
 * Production-Grade Phase 3B NearbyOrchestrator
 *
 * Full 4-Layer Pipeline Execution:
 *
 *   1. SearchQueryParser   — Parse intent & tags (familyFriendly, veg, ac, indoor)
 *   2. NearbyCacheService  — Check 5-min cache (<400ms target)
 *   3. Provider Registry   — Parallel fetch across OSM providers
 *   4. NearbyRankingEngine — Composite scoring (distance, rating, weather, open)
 *   5. ImageResolverService— Multi-tier image resolution (Wikimedia/Wikipedia)
 *   6. NearbyAdvisorService— Grounded Gemini 2.0 Flash AI travel advice
 *   7. NearbyAnalyticsService — Telemetry tracking
 *   8. Save to Cache       — Cache result for 5 minutes
 */
export class NearbyOrchestrator {
  /**
   * @param {import('../../../../infrastructure/providers/registry/nearby_provider_registry.js').NearbyProviderRegistry} registry
   * @param {Object} [options]
   */
  constructor(registry, options = {}) {
    this.registry = registry;
    this.rankingEngine = options.rankingEngine || new NearbyRankingEngine();
    this.cacheService = options.cacheService || new NearbyCacheService();
    this.imageResolver = options.imageResolver || new ImageResolverService();
    this.advisorService = options.advisorService || new NearbyAdvisorService();
    this.searchParser = options.searchParser || new SearchQueryParser();
    this.analytics = options.analytics || new NearbyAnalyticsService();
  }

  /**
   * Runs the production-grade Phase 3B nearby discovery pipeline.
   */
  async discover(params) {
    const startTime = Date.now();

    const {
      lat,
      lng,
      category = 'all',
      radius = nearbyConfig.radius.defaultMeters,
      limit = DEFAULT_LIMIT,
      rawQuery = '',
      weatherSnapshot = null,
      userPreferences = {},
    } = params;

    // ── Layer 4: Smart Search Parsing ─────────────────────────────────────
    const parsedQuery = this.searchParser.parse(rawQuery);
    const activeCategory = category !== 'all' ? category : parsedQuery.inferredCategory;

    // ── Layer 1: Check 5-Minute Cache Hit (<400ms target) ─────────────────
    const cacheKey = this.cacheService.generateKey(lat, lng, radius, activeCategory);
    const cachedResult = await this.cacheService.get(cacheKey);

    if (cachedResult) {
      logger.info({ event: 'nearby_cache_hit_pipeline', cacheKey, elapsedMs: Date.now() - startTime });
      return {
        context: new NearbyContext({
          userLocation: { lat, lng },
          category: activeCategory,
          radius,
          metadata: { cacheHit: true, elapsedMs: Date.now() - startTime },
        }),
        rankedPois: cachedResult.rankedPois.slice(0, limit),
        searchIntent: parsedQuery,
      };
    }

    // ── Build Initial NearbyContext ───────────────────────────────────────
    let context = new NearbyContext({
      userLocation: { lat, lng },
      category: activeCategory,
      radius: Math.min(radius, nearbyConfig.radius.maxMeters),
      weatherSnapshot,
      userPreferences,
    });

    // ── Layer 1 (Miss): Fetch from all registered providers ────────────────
    const { pois: rawPois, providersUsed } = await this.registry.fetchAll(context);
    context = context.evolve({ rawPois, providersUsed });

    // ── Layer 3: Rank results via NearbyRankingEngine ─────────────────────
    let allRanked = this.rankingEngine.rank(rawPois, context);
    let rankedPois = allRanked.slice(0, limit);

    // ── Layer 2 & 3: Resolve Images & AI Travel Advice in Parallel ────────
    rankedPois = await Promise.all(
      rankedPois.map(async (poi, idx) => {
        // Resolve Image via ImageResolverService
        const imgResult = await this.imageResolver.resolveImage(poi);

        // Generate AI Travel Advice for top 3 POIs
        let aiAdvice = null;
        if (idx < 3) {
          aiAdvice = await this.advisorService.generateAdvice(poi, context);
        }

        // Record telemetry impression
        this.analytics.recordPoiView(poi.id, poi.category);

        return {
          ...poi,
          imageUrl: imgResult.url,
          imageSource: imgResult.source,
          aiAdvice,
        };
      })
    );

    // ── Evolve final context ──────────────────────────────────────────────
    const elapsedMs = Date.now() - startTime;
    context = context.evolve({
      rankedPois,
      metadata: {
        totalRaw: rawPois.length,
        totalRanked: rankedPois.length,
        elapsedMs,
        providersUsed,
        cacheHit: false,
      },
    });

    // ── Layer 1: Store in 5-Minute Cache ──────────────────────────────────
    await this.cacheService.set(cacheKey, { rankedPois });

    // Track search query analytics
    if (rawQuery) {
      this.analytics.recordSearchQuery(rawQuery, activeCategory);
    }

    logger.info({
      event: 'nearby_discovery_pipeline_complete',
      requestId: context.requestId,
      rawCount: rawPois.length,
      rankedCount: rankedPois.length,
      elapsedMs,
    });

    return { context, rankedPois, searchIntent: parsedQuery };
  }
}
