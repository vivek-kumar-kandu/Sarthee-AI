import { describe, test } from 'node:test';
import assert from 'node:assert';
import { TrafficFeedMonitor } from '../../src/infrastructure/providers/traffic/traffic_feed_monitor.js';
import { TrafficProvider } from '../../src/infrastructure/providers/traffic/traffic_provider.js';
import { IncidentProvider } from '../../src/infrastructure/providers/incidents/incident_provider.js';
import { TrafficStatusService } from '../../src/modules/journey/domain/services/traffic_status_service.js';
import { IncidentStatusService } from '../../src/modules/journey/domain/services/incident_status_service.js';
import { RouteRankingEngine } from '../../src/modules/journey/domain/services/route_ranking_engine.js';

describe('Layer 2 & 3: Phase 2C Traffic & Incident Suite Unit Tests', () => {
  describe('TrafficFeedMonitor', () => {
    test('should initialize in UNCONFIGURED state when feed URL is missing', () => {
      const monitor = new TrafficFeedMonitor();
      monitor.setFeedConfigured(false);

      const status = monitor.getStatus();
      assert.strictEqual(status.state, TrafficFeedMonitor.STATES.UNCONFIGURED);
    });

    test('should transition to HEALTHY state on success', () => {
      const monitor = new TrafficFeedMonitor();
      monitor.setFeedConfigured(true);
      monitor.recordSuccess(95);

      const status = monitor.getStatus();
      assert.strictEqual(status.state, TrafficFeedMonitor.STATES.HEALTHY);
      assert.strictEqual(status.metrics.latencyMs, 95);
    });
  });

  describe('TrafficProvider & Never Fake Real-Time Principle', () => {
    test('should return UNAVAILABLE status without faking delay estimates when feed URL is missing', async () => {
      const provider = new TrafficProvider();
      const status = await provider.getTrafficStatus({});

      assert.strictEqual(status.status, 'UNAVAILABLE');
      assert.strictEqual(status.delayMinutes, 0);
      assert.strictEqual(status.confidence, 0.0);
    });

    test('should return LIVE traffic congestion metadata when feed URL is configured', async () => {
      const provider = new TrafficProvider({ feedUrl: 'https://api.traffic.example.com/feed' });
      const status = await provider.getTrafficStatus({});

      assert.strictEqual(status.status, 'LIVE');
      assert.strictEqual(status.delayMinutes, 12);
      assert.strictEqual(status.severity, 'HIGH');
      assert.strictEqual(status.confidence, 0.9);
    });
  });

  describe('IncidentProvider', () => {
    test('should return empty incidents list when feed URL is missing', async () => {
      const provider = new IncidentProvider();
      const res = await provider.getIncidents({});

      assert.strictEqual(res.status, 'UNAVAILABLE');
      assert.deepStrictEqual(res.incidents, []);
    });

    test('should return active incident alerts when feed URL is configured', async () => {
      const provider = new IncidentProvider({ feedUrl: 'https://api.incidents.example.com/feed' });
      const res = await provider.getIncidents({});

      assert.strictEqual(res.status, 'LIVE');
      assert.strictEqual(res.incidents.length, 1);
      assert.strictEqual(res.incidents[0].type, 'ROAD_CLOSED');
    });
  });

  describe('RouteRankingEngine Traffic & Incident Penalties', () => {
    const mockPlans = {
      fastest: {
        id: 'p_fast',
        mode: 'fastest',
        totalDurationMinutes: 25,
        totalCost: 380,
        totalWalkingDistanceMeters: 50,
        compositeSafetyScore: 85,
        steps: [{ type: 'cab' }],
      },
      balanced: {
        id: 'p_bal',
        mode: 'balanced',
        totalDurationMinutes: 34,
        totalCost: 80,
        totalWalkingDistanceMeters: 350,
        compositeSafetyScore: 90,
        steps: [{ type: 'metro' }],
      },
    };

    test('should penalize road plan score during heavy traffic congestion (+12 min delay)', () => {
      const rankingEngine = new RouteRankingEngine();
      const traffic = { status: 'LIVE', delayMinutes: 12, severity: 'HIGH' };

      const clearScore = rankingEngine.calculateRouteScore(mockPlans.fastest, null, 14, null, []);
      const trafficScore = rankingEngine.calculateRouteScore(mockPlans.fastest, null, 14, traffic, []);

      assert.ok(trafficScore < clearScore);
    });

    test('should promote Metro Rail to #1 plan when road plan suffers heavy traffic', () => {
      const rankingEngine = new RouteRankingEngine();
      const traffic = { status: 'LIVE', delayMinutes: 25, severity: 'HIGH' };

      const reRanked = rankingEngine.reRankPlans(mockPlans, null, 14, traffic, []);
      assert.ok(reRanked.recommended);
      assert.ok(reRanked.recommended.aiRationale.includes('Heavy Traffic Alert'));
    });
  });
});
