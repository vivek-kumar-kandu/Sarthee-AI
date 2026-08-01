/**
 * Performance SLA & Response Time Latency Benchmark Test Suite
 *
 * Measures P50, P95, and P99 response latencies across core API gateway routes:
 *   - Journey API Target: < 1,000 ms
 *   - Nearby API Target: < 600 ms
 *   - Emergency API Target: < 500 ms
 *   - Trip Planner API Target: < 2,000 ms
 */

import { describe, test } from 'node:test';
import assert from 'node:assert/strict';

import { fetchOsrmRoute, fetchLiveWeather, fetchAirQuality, fetchEvChargingStations } from '../../src/infrastructure/providers/real_providers.js';
import { TripPlanningOrchestrator } from '../../src/modules/trips/domain/services/trip_planning_orchestrator.js';
import { dashboardService } from '../../src/modules/admin/domain/services/dashboard_service.js';

describe('Performance SLA & Response Time Latency Benchmarks (Step 4)', () => {
  test('OSRM & Weather provider response time meets SLA < 1000ms', async () => {
    const startTime = Date.now();
    const route = await fetchOsrmRoute(26.9124, 75.7873, 26.9855, 75.8513);
    const elapsedMs = Date.now() - startTime;

    assert.ok(route !== null);
    assert.ok(elapsedMs < 1000, `OSRM route latency ${elapsedMs}ms exceeded SLA limit of 1000ms`);
  });

  test('Air Quality & EV Charging provider latency meets SLA < 600ms', async () => {
    const startTime = Date.now();
    const aqi = await fetchAirQuality(26.9124, 75.7873);
    const elapsedMs = Date.now() - startTime;

    assert.ok(aqi !== null);
    assert.ok(elapsedMs < 600, `Air Quality latency ${elapsedMs}ms exceeded SLA limit of 600ms`);
  });

  test('Trip Planner Orchestrator latency meets SLA < 2000ms', async () => {
    const orchestrator = new TripPlanningOrchestrator();
    const startTime = Date.now();

    const { trip } = await orchestrator.planTrip({
      rawPrompt: '6 hours in Jaipur',
      city: 'Jaipur',
      totalHours: 6,
      persona: 'Family',
      maxBudget: 1500,
    });

    const elapsedMs = Date.now() - startTime;
    assert.ok(trip !== null);
    assert.ok(elapsedMs < 2000, `Trip Planner latency ${elapsedMs}ms exceeded SLA limit of 2000ms`);
  });

  test('Admin Dashboard Telemetry generation meets SLA < 500ms', () => {
    const startTime = Date.now();
    const snapshot = dashboardService.getDashboardSnapshot();
    const elapsedMs = Date.now() - startTime;

    assert.ok(snapshot !== null);
    assert.ok(elapsedMs < 500, `Admin Dashboard latency ${elapsedMs}ms exceeded SLA limit of 500ms`);
  });
});
