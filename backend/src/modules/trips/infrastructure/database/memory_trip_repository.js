import { TRIP_STATES } from '../../domain/entities/trip_entity.js';

export class MemoryTripRepository {
  constructor() {
    this.store = new Map();
  }

  async save(tripEntity) {
    if (!tripEntity || !tripEntity.id) {
      throw new Error('MemoryTripRepository.save requires a valid TripEntity with an id.');
    }
    this.store.set(tripEntity.id, tripEntity);
    return this.store.get(tripEntity.id);
  }

  async findById(id) {
    return this.store.get(id) || null;
  }

  async findByUserId(userId) {
    const results = [];
    for (const trip of this.store.values()) {
      if (trip.userId === userId && !trip.isArchived) {
        results.push(trip);
      }
    }
    return results;
  }

  async updateState(id, newState) {
    const trip = this.store.get(id);
    if (!trip) return null;
    if (!Object.values(TRIP_STATES).includes(newState)) {
      throw new Error(`Invalid trip state transition to "${newState}".`);
    }
    trip.status = newState;
    trip.history.push({ state: newState, timestamp: new Date().toISOString() });
    trip.updatedAt = new Date().toISOString();
    this.store.set(id, trip);
    return trip;
  }

  async delete(id) {
    return this.store.delete(id);
  }

  async exists(id) {
    return this.store.has(id);
  }

  async list(filter = {}) {
    let results = Array.from(this.store.values());
    if (filter.city) {
      results = results.filter((t) => t.city.toLowerCase() === filter.city.toLowerCase());
    }
    if (filter.persona) {
      results = results.filter((t) => t.persona.toLowerCase() === filter.persona.toLowerCase());
    }
    if (filter.status) {
      results = results.filter((t) => t.status === filter.status);
    }
    if (typeof filter.isArchived === 'boolean') {
      results = results.filter((t) => Boolean(t.isArchived) === filter.isArchived);
    }
    return results;
  }

  async archive(id) {
    const trip = this.store.get(id);
    if (!trip) return null;
    trip.isArchived = true;
    trip.status = TRIP_STATES.ARCHIVED;
    trip.updatedAt = new Date().toISOString();
    this.store.set(id, trip);
    return trip;
  }

  async restore(id) {
    const trip = this.store.get(id);
    if (!trip) return null;
    trip.isArchived = false;
    trip.status = TRIP_STATES.PLANNED;
    trip.updatedAt = new Date().toISOString();
    this.store.set(id, trip);
    return trip;
  }
}

export const memoryTripRepository = new MemoryTripRepository();
