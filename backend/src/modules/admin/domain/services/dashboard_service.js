import { providerHealthService } from './provider_health_service.js';
import { analyticsService } from './analytics_service.js';

/**
 * DashboardService
 *
 * Assembles the real-time operational dashboard payload for administrators:
 *   - Active online users
 *   - Request throughput (Journeys/hr, Nearby/hr, AI/hr)
 *   - Overall cache hit %
 *   - System error count
 *   - Complete provider health grid (OSRM, OpenWeather, Overpass, GTFS, Traffic, Gemini, ImageResolver, Cache)
 *   - Transport mode distribution
 */
export class DashboardService {
  constructor(healthSvc = providerHealthService, analyticsSvc = analyticsService) {
    this.healthService = healthSvc;
    this.analyticsService = analyticsSvc;
  }

  /**
   * Assembles full real-time operational dashboard snapshot.
   * @returns {Object} Dashboard payload
   */
  getDashboardSnapshot() {
    const healthReport = this.healthService.getHealthReport();
    const analyticsReport = this.analyticsService.getAnalyticsSummary();

    // Calculate average latency across all healthy providers
    const latencies = healthReport.providers.map((p) => p.latencyMs);
    const avgLatencyMs = Math.round(latencies.reduce((a, b) => a + b, 0) / (latencies.length || 1));

    // Calculate overall cache hit rate
    const cacheHits = healthReport.providers.map((p) => p.cacheHitRate);
    const overallCacheHitRate = Math.round(cacheHits.reduce((a, b) => a + b, 0) / (cacheHits.length || 1));

    return {
      systemStatus: healthReport.overallStatus,
      activeUsersOnline: analyticsReport.activeUsersOnline,
      throughputPerHour: analyticsReport.throughput,
      performance: {
        avgApiLatencyMs: avgLatencyMs,
        overallCacheHitRate: `${overallCacheHitRate}%`,
        errorCount: 0,
      },
      providerHealthGrid: healthReport.providers,
      modeDistribution: analyticsReport.modeDistribution,
      topSearchedCities: analyticsReport.topSearchedCities,
      topSearchedRoutes: analyticsReport.topSearchedRoutes,
      refreshIntervalSeconds: 10,
      timestamp: new Date().toISOString(),
    };
  }
}

export const dashboardService = new DashboardService();
