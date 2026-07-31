/**
 * Phase 4A — Enterprise Operations Platform & Safety Intelligence Unit Tests
 *
 * Tests:
 *   1. ProviderMonitorFramework telemetry sample recording & status reporting
 *   2. ProviderHealthService health report grid aggregation
 *   3. AnalyticsService mode split %, throughput & trend tracking
 *   4. DashboardService operational dashboard snapshot generation
 *   5. SOSDispatcher 24x7 SOS payload generation with live GPS & nearest police/hospital
 *   6. EmergencyService service lookup & SOS dispatching
 */

import { describe, test } from 'node:test';
import assert from 'node:assert/strict';

import { ProviderMonitorFramework } from '../../src/infrastructure/monitoring/provider_monitor_framework.js';
import { ProviderHealthService } from '../../src/modules/admin/domain/services/provider_health_service.js';
import { AnalyticsService } from '../../src/modules/admin/domain/services/analytics_service.js';
import { DashboardService } from '../../src/modules/admin/domain/services/dashboard_service.js';
import { SOSDispatcher } from '../../src/modules/emergency/domain/services/sos_dispatcher.js';
import { EmergencyService } from '../../src/modules/emergency/domain/services/emergency_service.js';

// ── Mock Emergency Provider ──────────────────────────────────────────────────
class MockEmergencyProvider {
  async execute() {
    return [
      { name: 'SMS Hospital & ER', subcategory: 'hospital', lat: 26.8984, lng: 75.8112, phone: '102', urgencyLevel: 'critical', distanceKm: 1.2 },
      { name: 'Jaipur Police HQ', subcategory: 'police', lat: 26.9184, lng: 75.8150, phone: '112', urgencyLevel: 'high', distanceKm: 0.8 },
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. ProviderMonitorFramework (4A.1)
// ─────────────────────────────────────────────────────────────────────────────
describe('ProviderMonitorFramework (4A.1)', () => {
  test('initializes default monitors for all core providers', () => {
    const pmf = new ProviderMonitorFramework();
    const statuses = pmf.getAllStatuses();
    assert.ok(statuses.length >= 8);
    const osrm = pmf.getProviderStatus('osrm_routing');
    assert.ok(osrm !== null);
    assert.strictEqual(osrm.providerId, 'osrm_routing');
    assert.strictEqual(osrm.status, 'healthy');
  });

  test('records telemetry samples and updates moving average latency & success rate', () => {
    const pmf = new ProviderMonitorFramework();
    pmf.recordSample('osrm_routing', 120, true, null, true);
    const updated = pmf.getProviderStatus('osrm_routing');
    assert.ok(updated.latencyMs > 0);
    assert.ok(updated.successRate > 90);
  });

  test('transitions provider status to degraded/down when failures occur', () => {
    const pmf = new ProviderMonitorFramework();
    for (let i = 0; i < 15; i++) {
      pmf.recordSample('open_weather', 2000, false, 'Timeout error');
    }
    const status = pmf.getProviderStatus('open_weather');
    assert.strictEqual(status.status, 'down');
    assert.strictEqual(status.lastFailure, 'Timeout error');
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 2. ProviderHealthService & DashboardService (4A.2)
// ─────────────────────────────────────────────────────────────────────────────
describe('ProviderHealthService & DashboardService (4A.2)', () => {
  test('ProviderHealthService aggregates health grid report', () => {
    const pmf = new ProviderMonitorFramework();
    const healthSvc = new ProviderHealthService(pmf);
    const report = healthSvc.getHealthReport();

    assert.ok('overallStatus' in report);
    assert.ok('totalProviders' in report);
    assert.ok(report.providers.length >= 8);
  });

  test('DashboardService generates operational dashboard snapshot', () => {
    const pmf = new ProviderMonitorFramework();
    const healthSvc = new ProviderHealthService(pmf);
    const analyticsSvc = new AnalyticsService();
    const dashSvc = new DashboardService(healthSvc, analyticsSvc);

    const snapshot = dashSvc.getDashboardSnapshot();
    assert.ok('systemStatus' in snapshot);
    assert.ok('activeUsersOnline' in snapshot);
    assert.ok('throughputPerHour' in snapshot);
    assert.ok('performance' in snapshot);
    assert.ok(snapshot.performance.avgApiLatencyMs > 0);
    assert.ok(Array.isArray(snapshot.providerHealthGrid));
    assert.ok('modeDistribution' in snapshot);
    assert.strictEqual(snapshot.modeDistribution.metro, 48.5);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 3. AnalyticsService (4A.2)
// ─────────────────────────────────────────────────────────────────────────────
describe('AnalyticsService (4A.2)', () => {
  test('tracks city and route searches correctly', () => {
    const analytics = new AnalyticsService();
    analytics.recordCitySearch('Jaipur');
    analytics.recordCitySearch('Jaipur');
    analytics.recordRouteSearch('Ghaziabad', 'New Delhi');

    const summary = analytics.getAnalyticsSummary();
    assert.ok(summary.activeUsersOnline > 0);
    assert.ok(summary.throughput.journeyPerHour > 0);
    assert.ok(Array.isArray(summary.topSearchedCities));
    assert.ok(Array.isArray(summary.topSearchedRoutes));
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 4. SOSDispatcher & EmergencyService (4A.3)
// ─────────────────────────────────────────────────────────────────────────────
describe('SOSDispatcher & EmergencyService (4A.3)', () => {
  test('SOSDispatcher generates actionable 24x7 SOS payload with live GPS link', () => {
    const dispatcher = new SOSDispatcher();
    const payload = dispatcher.generateSosPayload({
      lat: 26.9124,
      lng: 75.7873,
      userId: 'user_test',
      nearestPolice: { name: 'Jaipur Central Police Station', distanceKm: 1.1 },
      nearestHospital: { name: 'SMS Hospital ER', distanceKm: 1.5 },
    });

    assert.ok(payload.sosId.startsWith('sos_'));
    assert.ok(payload.userLocation.liveLocationLink.includes('26.9124,75.7873'));
    assert.strictEqual(payload.nearestServices.police.name, 'Jaipur Central Police Station');
    assert.strictEqual(payload.nearestServices.hospital.name, 'SMS Hospital ER');
    assert.ok(payload.actionableSms.includes('EMERGENCY SOS ALERT'));
    assert.strictEqual(payload.status, 'DISPATCHED');
  });

  test('EmergencyService dispatches 24x7 SOS alert with fallback helplines', async () => {
    const mockRegistry = {
      async fetchEmergencyServices(lat, lng, sub) {
        return [
          { name: 'SMS Hospital & ER', subcategory: 'hospital', distanceKm: 1.2 },
          { name: 'Jaipur Police HQ', subcategory: 'police', distanceKm: 0.8 },
        ];
      },
    };

    const service = new EmergencyService(mockRegistry);
    const payload = await service.dispatchSos({
      lat: 26.9124,
      lng: 75.7873,
      userId: 'user_456',
    });

    assert.ok(payload.sosId.length > 0);
    assert.ok(payload.emergencyHelplines.police === '112');
    assert.ok(payload.emergencyHelplines.womenHelpline === '1091');
    assert.ok(payload.emergencyHelplines.ambulance === '102');
  });
});
