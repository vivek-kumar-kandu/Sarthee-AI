import { describe, test } from 'node:test';
import assert from 'node:assert';
import { TransitFeedMonitor } from '../../src/infrastructure/providers/transit/transit_feed_monitor.js';
import { GtfsStaticProvider } from '../../src/infrastructure/providers/transit/gtfs_static_provider.js';
import { GtfsRealtimeProvider } from '../../src/infrastructure/providers/transit/gtfs_realtime_provider.js';
import { TransitStatusService } from '../../src/modules/journey/domain/services/transit_status_service.js';

describe('Layer 2 & 3: Phase 2B Live Transit Suite Unit Tests', () => {
  describe('TransitFeedMonitor', () => {
    test('should initialize in UNCONFIGURED state when feed URL is missing', () => {
      const monitor = new TransitFeedMonitor();
      monitor.setFeedConfigured(false);

      const status = monitor.getStatus();
      assert.strictEqual(status.state, TransitFeedMonitor.STATES.UNCONFIGURED);
    });

    test('should record latency and transition to HEALTHY state on success', () => {
      const monitor = new TransitFeedMonitor();
      monitor.setFeedConfigured(true);
      monitor.recordSuccess(145, true);

      const status = monitor.getStatus();
      assert.strictEqual(status.state, TransitFeedMonitor.STATES.HEALTHY);
      assert.strictEqual(status.metrics.latencyMs, 145);
      assert.strictEqual(status.metrics.cacheHits, 1);
    });

    test('should transition to OFFLINE state and record fallback on failure', () => {
      const monitor = new TransitFeedMonitor();
      monitor.recordFailure('timeout');

      const status = monitor.getStatus();
      assert.strictEqual(status.state, TransitFeedMonitor.STATES.OFFLINE);
      assert.strictEqual(status.metrics.fallbackCount, 1);
    });
  });

  describe('GtfsStaticProvider & City-Agnostic Support', () => {
    test('should return static timetable metadata with confidence 0.7', async () => {
      const staticProvider = new GtfsStaticProvider({ transitSystem: 'BMRCL' });
      const status = await staticProvider.getTransitStatus({});

      assert.strictEqual(status.status, 'SCHEDULED');
      assert.strictEqual(status.confidence, 0.7);
      assert.ok(status.source.includes('BMRCL'));
    });
  });

  describe('GtfsRealtimeProvider & Metadata Enrichment', () => {
    test('should return UNCONFIGURED scheduled metadata when feed URL is absent', async () => {
      const provider = new GtfsRealtimeProvider();
      const status = await provider.getTransitStatus({});

      assert.strictEqual(status.status, 'SCHEDULED');
      assert.strictEqual(status.confidence, 0.7);
      assert.strictEqual(status.feedState, TransitFeedMonitor.STATES.UNCONFIGURED);
    });

    test('should return LIVE metadata envelope when feed URL is configured', async () => {
      const provider = new GtfsRealtimeProvider({ feedUrl: 'https://gtfs.example.com/feed' });
      const status = await provider.getTransitStatus({});

      assert.strictEqual(status.status, 'LIVE');
      assert.strictEqual(status.confidence, 1.0);
      assert.strictEqual(status.source, 'GTFS-Realtime');
      assert.strictEqual(status.platform, '2');
      assert.strictEqual(status.gate, '3');
      assert.strictEqual(status.occupancy, 'LOW');
    });
  });

  describe('TransitStatusService Resolution', () => {
    test('should resolve live provider envelope when live status is HEALTHY', async () => {
      const liveProvider = new GtfsRealtimeProvider({ feedUrl: 'https://gtfs.example.com/feed' });
      const staticProvider = new GtfsStaticProvider();
      const service = new TransitStatusService(liveProvider, staticProvider);

      const resolved = await service.resolveTransitStatus({});
      assert.strictEqual(resolved.status, 'LIVE');
      assert.strictEqual(resolved.confidence, 1.0);
    });

    test('should resolve static timetable fallback when live provider returns SCHEDULED', async () => {
      const liveProvider = new GtfsRealtimeProvider(); // unconfigured
      const staticProvider = new GtfsStaticProvider();
      const service = new TransitStatusService(liveProvider, staticProvider);

      const resolved = await service.resolveTransitStatus({});
      assert.strictEqual(resolved.status, 'SCHEDULED');
      assert.strictEqual(resolved.confidence, 0.7);
    });
  });
});
