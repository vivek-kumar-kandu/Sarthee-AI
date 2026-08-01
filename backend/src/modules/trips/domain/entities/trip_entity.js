import { randomUUID } from 'crypto';

/**
 * Valid Trip States in the State Machine
 */
export const TRIP_STATES = Object.freeze({
  DRAFT: 'DRAFT',
  PLANNED: 'PLANNED',
  SAVED: 'SAVED',
  STARTED: 'STARTED',
  PAUSED: 'PAUSED',
  COMPLETED: 'COMPLETED',
  ARCHIVED: 'ARCHIVED',
});

/**
 * TripEntity — Rich Domain Entity for Sarthee AI Trips
 *
 * Implements:
 *   - Trip State Machine (DRAFT -> PLANNED -> SAVED -> STARTED -> PAUSED -> COMPLETED -> ARCHIVED)
 *   - Multi-day structured itineraries:
 *     days: [{ dayIndex: 1, title: 'Day 1', stops: [...] }]
 *   - Granular cost breakdown (Transport, Food, Tickets, Buffer)
 *   - Share token & QR Code payload generator
 *   - 100% In-Memory Domain Storage (Zero MongoDB dependency)
 */
export class TripEntity {
  constructor({
    id = null,
    userId = 'guest',
    title = 'Custom Trip',
    city = 'Jaipur',
    persona = 'Family',
    status = TRIP_STATES.PLANNED,
    days = [],
    costBreakdown = null,
    confidence = { score: 94, verifiedSources: ['OSRM', 'OpenWeather', 'Opening Hours', 'Overpass'] },
    shareToken = null,
    history = [],
    metadata = {},
  }) {
    this.id = id || `trip_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`;
    this.userId = userId;
    this.title = title;
    this.city = city;
    this.persona = persona;
    this.status = Object.values(TRIP_STATES).includes(status) ? status : TRIP_STATES.PLANNED;

    this.days = Array.isArray(days) ? days : [];
    this.costBreakdown = costBreakdown || { transport: 180, food: 500, tickets: 420, buffer: 400, total: 1500 };
    this.confidence = confidence;

    this.shareToken = shareToken || randomUUID().substr(0, 8);
    this.history = Array.isArray(history) && history.length > 0 ? history : [{ state: this.status, timestamp: new Date().toISOString() }];
    this.metadata = metadata;
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
  }

  /**
   * Transition trip to a new state in the State Machine
   * @param {string} newState Valid state from TRIP_STATES
   */
  transitionTo(newState) {
    if (!Object.values(TRIP_STATES).includes(newState)) {
      throw new Error(`Invalid trip state transition to "${newState}".`);
    }

    this.status = newState;
    this.history.push({ state: newState, timestamp: new Date().toISOString() });
    this.updatedAt = new Date().toISOString();
    return this;
  }

  /** Generates shareable payload & QR Code URL */
  getSharePayload() {
    const shareUrl = `https://sarthee.ai/trips/share/${this.shareToken}`;
    const qrCodeUrl = `https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(shareUrl)}`;

    return {
      tripId: this.id,
      title: this.title,
      city: this.city,
      shareToken: this.shareToken,
      shareUrl,
      qrCodeUrl,
      status: this.status,
    };
  }
}
