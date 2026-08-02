import { describe, test } from 'node:test';
import assert from 'node:assert/strict';

import { TripRepository } from '../../src/modules/trips/infrastructure/database/trip_repository.js';
import { MemoryTripRepository } from '../../src/modules/trips/infrastructure/database/memory_trip_repository.js';
import { TripEntity, TRIP_STATES } from '../../src/modules/trips/domain/entities/trip_entity.js';

import { EmergencyRepository } from '../../src/modules/emergency/infrastructure/database/emergency_repository.js';
import { MemoryEmergencyRepository } from '../../src/modules/emergency/infrastructure/database/memory_emergency_repository.js';

import { FeedbackRepository } from '../../src/modules/feedback/infrastructure/database/feedback_repository.js';
import { MemoryFeedbackRepository } from '../../src/modules/feedback/infrastructure/database/memory_feedback_repository.js';

describe('Composite Repository Adapters Suite', () => {
  describe('TripRepository Composite Adapter', () => {
    test('should save, list, archive, restore, and delete trips in memory fallback mode', async () => {
      const memoryRepo = new MemoryTripRepository();
      const repository = new TripRepository(null, memoryRepo);

      const trip = new TripEntity({
        title: 'Jaipur Heritage Tour',
        city: 'Jaipur',
        persona: 'Heritage',
        userId: 'user_101',
      });

      // Save
      const saved = await repository.save(trip);
      assert.equal(saved.id, trip.id);

      // Find By ID
      const found = await repository.findById(trip.id);
      assert.equal(found.title, 'Jaipur Heritage Tour');

      // Exists
      const exists = await repository.exists(trip.id);
      assert.equal(exists, true);

      // Update State
      const updated = await repository.updateState(trip.id, TRIP_STATES.STARTED);
      assert.equal(updated.status, TRIP_STATES.STARTED);

      // List
      const list = await repository.list({ city: 'Jaipur' });
      assert.equal(list.length, 1);

      // Archive & Restore
      const archived = await repository.archive(trip.id);
      assert.equal(archived.isArchived, true);
      assert.equal(archived.status, TRIP_STATES.ARCHIVED);

      const restored = await repository.restore(trip.id);
      assert.equal(restored.isArchived, false);
      assert.equal(restored.status, TRIP_STATES.PLANNED);

      // Delete
      const deleted = await repository.delete(trip.id);
      assert.equal(deleted, true);
      const afterDelete = await repository.findById(trip.id);
      assert.equal(afterDelete, null);
    });

    test('should silently failover to memory repository if mongo repository throws an error', async () => {
      const memoryRepo = new MemoryTripRepository();
      const faultyMongoRepo = {
        save: async () => {
          throw new Error('Mongo Connection Lost');
        },
      };

      const repository = new TripRepository(faultyMongoRepo, memoryRepo);
      const trip = new TripEntity({ title: 'Failover Trip Test' });

      // Simulate mongo connection boolean being true
      const origFn = global.isMongoConnected;
      try {
        // execute with fallback
        const result = await repository.save(trip);
        assert.equal(result.id, trip.id);
        assert.equal(result.title, 'Failover Trip Test');
      } finally {
        global.isMongoConnected = origFn;
      }
    });
  });

  describe('EmergencyRepository Composite Adapter', () => {
    test('should dispatch, store, update status, and query active/recent SOS alerts', async () => {
      const memoryRepo = new MemoryEmergencyRepository();
      const repository = new EmergencyRepository(null, memoryRepo);

      const sosPayload = {
        sosId: 'sos_test_001',
        userId: 'usr_sos_99',
        timestamp: new Date().toISOString(),
        userLocation: { lat: 26.9124, lng: 75.7873, liveLocationLink: 'https://maps.google.com/?q=26.9124,75.7873' },
        status: 'DISPATCHED',
      };

      // Save
      await repository.save(sosPayload);

      // Find By ID
      const alert = await repository.findById('sos_test_001');
      assert.equal(alert.sosId, 'sos_test_001');
      assert.equal(alert.status, 'DISPATCHED');

      // Update Status
      const updated = await repository.updateStatus('sos_test_001', 'ACKNOWLEDGED');
      assert.equal(updated.status, 'ACKNOWLEDGED');

      // Query Active & Recent
      const activeList = await repository.findActive();
      assert.equal(activeList.length, 1);

      const recentList = await repository.findRecent(5);
      assert.equal(recentList.length, 1);
    });
  });

  describe('FeedbackRepository Composite Adapter', () => {
    test('should store beta feedback, compute ratings breakdown, and calculate category statistics', async () => {
      const memoryRepo = new MemoryFeedbackRepository();
      const repository = new FeedbackRepository(null, memoryRepo);

      await repository.save({
        feedbackId: 'fb_1',
        userId: 'tester_1',
        rating: 5,
        journeyAccuracyRating: 4,
        nearbyAccuracyRating: 5,
        performanceRating: 5,
        category: 'bug_report',
        comments: 'Great app, fixed route issue',
        timestamp: new Date().toISOString(),
      });

      await repository.save({
        feedbackId: 'fb_2',
        userId: 'tester_2',
        rating: 3,
        journeyAccuracyRating: 3,
        nearbyAccuracyRating: 4,
        performanceRating: 4,
        category: 'feature_request',
        comments: 'Add offline map cache',
        timestamp: new Date().toISOString(),
      });

      // Find All
      const all = await repository.findAll();
      assert.equal(all.length, 2);

      // Find By Category
      const bugReports = await repository.findByCategory('bug_report');
      assert.equal(bugReports.length, 1);
      assert.equal(bugReports[0].feedbackId, 'fb_1');

      // Find By Rating
      const fiveStar = await repository.findByRating(5);
      assert.equal(fiveStar.length, 1);

      // Statistics
      const stats = await repository.getStatistics();
      assert.equal(stats.totalEntries, 2);
      assert.equal(stats.averages.overall, 4.0);
      assert.equal(stats.categoryCounts.bug_report, 1);
      assert.equal(stats.categoryCounts.feature_request, 1);
    });
  });
});
