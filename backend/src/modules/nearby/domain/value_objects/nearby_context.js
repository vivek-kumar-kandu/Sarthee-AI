import { randomUUID } from 'crypto';

/**
 * Immutable NearbyContext Value Object
 *
 * Single source of truth for a nearby discovery request.
 * Mirrors JourneyContext immutability pattern.
 */
export class NearbyContext {
  constructor({
    userLocation,
    category = 'all',
    radius = 5000,
    weatherSnapshot = null,
    userPreferences = {},
    providersUsed = [],
    rawPois = [],
    rankedPois = [],
    metadata = {},
  }) {
    if (!userLocation?.lat || !userLocation?.lng) {
      throw new Error('NearbyContext requires a valid userLocation { lat, lng }');
    }

    this.requestId = randomUUID();
    this.timestamp = new Date().toISOString();

    this.userLocation = Object.freeze({ ...userLocation });
    this.category = category;
    this.radius = radius;

    this.weatherSnapshot = weatherSnapshot ? Object.freeze({ ...weatherSnapshot }) : null;
    this.userPreferences = Object.freeze({
      preferIndoor: false,
      preferRated: true,
      preferOpen: true,
      ...userPreferences,
    });

    this.providersUsed = Object.freeze([...providersUsed]);
    this.rawPois = Object.freeze([...rawPois]);
    this.rankedPois = Object.freeze([...rankedPois]);

    this.metadata = Object.freeze({
      totalRaw: rawPois.length,
      totalRanked: rankedPois.length,
      ...metadata,
    });

    Object.freeze(this);
  }

  evolve(updates = {}) {
    return new NearbyContext({
      userLocation: this.userLocation,
      category: this.category,
      radius: this.radius,
      weatherSnapshot: this.weatherSnapshot,
      userPreferences: this.userPreferences,
      providersUsed: this.providersUsed,
      rawPois: this.rawPois,
      rankedPois: this.rankedPois,
      metadata: this.metadata,
      ...updates,
    });
  }
}
