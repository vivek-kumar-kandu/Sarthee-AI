import { randomUUID } from 'crypto';

/**
 * Immutable TripContext Value Object
 *
 * Single source of truth for a trip planning execution session.
 * Stores prompt, dynamic constraints, persona, weather snapshot,
 * candidate POIs, timeline stops, cost breakdown, confidence %, and execution metrics.
 */
export class TripContext {
  constructor({
    rawPrompt = '',
    city = 'Jaipur',
    totalHours = 6,
    persona = 'Family',
    maxBudget = 1500,
    dynamicConstraints = {},
    weatherSnapshot = null,
    candidatePois = [],
    optimizedDays = [],
    costBreakdown = null,
    confidence = { score: 94, verifiedSources: ['OSRM', 'OpenWeather', 'Opening Hours', 'Overpass'] },
    metadata = {},
  }) {
    this.requestId = randomUUID();
    this.timestamp = new Date().toISOString();

    this.rawPrompt = rawPrompt;
    this.city = city;
    this.totalHours = totalHours;
    this.persona = persona;
    this.maxBudget = maxBudget;

    this.dynamicConstraints = Object.freeze({
      maxWalkingMeters: 2000,
      maxBudget,
      mustVisit: [],
      avoid: [],
      indoorOnly: false,
      wheelchair: false,
      kidsFriendly: persona === 'Family',
      petFriendly: false,
      ...dynamicConstraints,
    });

    this.weatherSnapshot = weatherSnapshot ? Object.freeze({ ...weatherSnapshot }) : null;
    this.candidatePois = Object.freeze([...candidatePois]);
    this.optimizedDays = Object.freeze([...optimizedDays]);

    this.costBreakdown = costBreakdown
      ? Object.freeze({ ...costBreakdown })
      : Object.freeze({ transport: 180, food: 500, tickets: 420, buffer: 400, total: maxBudget });

    this.confidence = Object.freeze({ ...confidence });
    this.metadata = Object.freeze({ ...metadata });

    Object.freeze(this);
  }

  /** Returns new frozen instance with merged updates */
  evolve(updates = {}) {
    return new TripContext({
      rawPrompt: this.rawPrompt,
      city: this.city,
      totalHours: this.totalHours,
      persona: this.persona,
      maxBudget: this.maxBudget,
      dynamicConstraints: this.dynamicConstraints,
      weatherSnapshot: this.weatherSnapshot,
      candidatePois: this.candidatePois,
      optimizedDays: this.optimizedDays,
      costBreakdown: this.costBreakdown,
      confidence: this.confidence,
      metadata: this.metadata,
      ...updates,
    });
  }
}
