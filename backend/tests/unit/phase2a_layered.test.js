import { describe, test } from 'node:test';
import assert from 'node:assert';
import { GtfsRealtimeProvider } from '../../src/infrastructure/providers/transit/gtfs_realtime_provider.js';
import { PersonalizationEngine } from '../../src/modules/journey/domain/services/personalization_engine.js';
import { ReRoutingEngine } from '../../src/modules/journey/domain/services/re_routing_engine.js';

describe('Layer 3 & Infrastructure: Phase 2A Layered Suite Unit Tests', () => {
  describe('GtfsRealtimeProvider & Trustworthy Real-Time Principle', () => {
    test('should return trustworthy timetable schedule frequency when live feed is unconfigured', async () => {
      const transitProvider = new GtfsRealtimeProvider();
      const status = await transitProvider.getTransitStatus({});

      assert.strictEqual(status.status, 'SCHEDULED');
      assert.strictEqual(status.confidence, 0.7);
      assert.strictEqual(status.frequency, 'Every 4–6 min');
    });

    test('should return live status when live feed URL is configured', async () => {
      const transitProvider = new GtfsRealtimeProvider({ feedUrl: 'https://api.gtfs-realtime.example.com/feed' });
      const status = await transitProvider.getTransitStatus({});

      assert.strictEqual(status.status, 'LIVE');
      assert.strictEqual(status.confidence, 1.0);
      assert.strictEqual(status.platform, '2');
    });
  });

  describe('PersonalizationEngine', () => {
    const mockPlans = {
      balanced: { id: 'p1', mode: 'balanced', recommendationScore: 80, totalWalkingDistanceMeters: 200 },
      cheapest: { id: 'p2', mode: 'cheapest', recommendationScore: 75, totalWalkingDistanceMeters: 800 },
    };

    test('should boost minimal walking plan score when avoidWalking preference is true', () => {
      const result = PersonalizationEngine.applyUserPreferences(mockPlans, { avoidWalking: true });
      assert.strictEqual(result.balanced.personalizedScore, 100);
      assert.strictEqual(result.recommended.mode, 'recommended');
    });

    test('should boost cheapest plan score when preferCheapest preference is true', () => {
      const result = PersonalizationEngine.applyUserPreferences(mockPlans, { preferCheapest: true });
      assert.strictEqual(result.cheapest.personalizedScore, 100);
    });
  });

  describe('ReRoutingEngine', () => {
    test('should return isDeviated false when user GPS is within 200m threshold', () => {
      const currentLat = 28.6715;
      const currentLng = 77.4121;
      const expectedLat = 28.6718;
      const expectedLng = 77.4123;

      const result = ReRoutingEngine.checkDeviation(currentLat, currentLng, expectedLat, expectedLng, 200);
      assert.strictEqual(result.isDeviated, false);
      assert.strictEqual(result.action, 'continue_on_route');
    });

    test('should return isDeviated true and trigger recalculate_journey when GPS strays beyond 200m', () => {
      const currentLat = 28.6715;
      const currentLng = 77.4121;
      const expectedLat = 28.6785;
      const expectedLng = 77.4200;

      const result = ReRoutingEngine.checkDeviation(currentLat, currentLng, expectedLat, expectedLng, 200);
      assert.strictEqual(result.isDeviated, true);
      assert.strictEqual(result.action, 'recalculate_journey');
      assert.ok(result.distanceMeters > 200);
    });
  });
});
