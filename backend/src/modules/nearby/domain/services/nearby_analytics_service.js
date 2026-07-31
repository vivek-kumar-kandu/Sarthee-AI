import { logger } from '../../../../config/logger.js';

/**
 * NearbyAnalyticsService
 *
 * Tracks telemetry and analytics for nearby place discovery:
 *   - POI view counts and impressions
 *   - Most popular categories
 *   - Average search radius
 *   - Search query trends
 *   - Conversion rate (Nearby View -> Navigate Here tap)
 */
export class NearbyAnalyticsService {
  constructor() {
    this.poiViews = new Map(); // poiId -> count
    this.categoryCounts = new Map(); // category -> count
    this.navigateTaps = new Map(); // poiId -> count
    this.searchQueries = [];
  }

  /** Record a POI card impression/view */
  recordPoiView(poiId, category) {
    if (!poiId) return;
    this.poiViews.set(poiId, (this.poiViews.get(poiId) || 0) + 1);
    if (category) {
      this.categoryCounts.set(category, (this.categoryCounts.get(category) || 0) + 1);
    }
  }

  /** Record a "Navigate Here" tap (conversion) */
  recordNavigateTap(poiId) {
    if (!poiId) return;
    this.navigateTaps.set(poiId, (this.navigateTaps.get(poiId) || 0) + 1);
    logger.info({ event: 'nearby_navigate_conversion', poiId });
  }

  /** Record a search query for trend analysis */
  recordSearchQuery(query, category) {
    if (!query) return;
    this.searchQueries.push({
      query: query.trim(),
      category: category || 'all',
      timestamp: new Date().toISOString(),
    });
    if (this.searchQueries.length > 500) {
      this.searchQueries.shift(); // keep last 500
    }
  }

  /** Returns top telemetry summary */
  getTelemetrySummary() {
    const topCategory = Array.from(this.categoryCounts.entries())
      .sort((a, b) => b[1] - a[1])[0]?.[0] || 'all';

    return {
      totalPoiViews: Array.from(this.poiViews.values()).reduce((a, b) => a + b, 0),
      totalNavigations: Array.from(this.navigateTaps.values()).reduce((a, b) => a + b, 0),
      topCategory,
      recentSearchCount: this.searchQueries.length,
    };
  }
}
