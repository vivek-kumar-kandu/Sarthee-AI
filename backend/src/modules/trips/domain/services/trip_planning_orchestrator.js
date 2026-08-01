import { TripProviderRegistry } from '../../../../infrastructure/providers/registry/trip_provider_registry.js';
import { ItineraryOptimizationEngine } from './itinerary_optimization_engine.js';
import { TripAdvisorService } from './trip_advisor_service.js';
import { TripReOptimizerService } from './trip_reoptimizer_service.js';
import { TripContext } from '../value_objects/trip_context.js';
import { TripEntity, TRIP_STATES } from '../entities/trip_entity.js';
import { logger } from '../../../../config/logger.js';

/**
 * In-Memory Trip Store (Zero MongoDB dependency)
 * Stores saved & active user trips in memory
 */
export const memoryTripStore = new Map();

/**
 * TripPlanningOrchestrator
 *
 * Coordinates the full Phase 4B AI Trip Planning Pipeline:
 *   1. Parse user prompt & dynamic constraints
 *   2. Fetch candidate POIs, Weather, Events, Tourism via TripProviderRegistry
 *   3. Run 12-factor ItineraryOptimizationEngine scoring solver
 *   4. Build multi-phase timeline slots & automatic 5-15 min buffers
 *   5. Compute granular cost breakdown & dynamic runtime confidence %
 *   6. Generate grounded AI explanation via TripAdvisorService
 *   7. Assemble & store TripEntity (In-Memory, Zero MongoDB)
 */
export class TripPlanningOrchestrator {
  constructor(options = {}) {
    this.registry = options.registry || new TripProviderRegistry();
    this.optimizationEngine = options.optimizationEngine || new ItineraryOptimizationEngine();
    this.advisorService = options.advisorService || new TripAdvisorService();
    this.reoptimizerService = options.reoptimizerService || new TripReOptimizerService(this.optimizationEngine);
  }

  /**
   * Plans a complete trip from a user request.
   */
  async planTrip(params) {
    const startTime = Date.now();

    const {
      rawPrompt = '',
      city = 'Jaipur',
      totalHours = 6,
      persona = 'Family',
      maxBudget = 1500,
      dynamicConstraints = {},
      weatherSnapshot = null,
      userId = 'guest',
    } = params;

    // 1. Build initial TripContext
    let context = new TripContext({
      rawPrompt,
      city,
      totalHours,
      persona,
      maxBudget,
      dynamicConstraints,
      weatherSnapshot,
    });

    // 2. Fetch data across providers via TripProviderRegistry
    const providerOutputs = await this.registry.fetchAll({
      city,
      userLocation: { lat: 26.9124, lng: 75.7873 },
      radius: 12000,
    });

    // Gather candidate POIs from Overpass / Tourism providers
    let candidatePois = providerOutputs.tourism_provider || [];
    if (candidatePois.length === 0 && providerOutputs.overpass_poi) {
      candidatePois = providerOutputs.overpass_poi;
    }

    context = context.evolve({ candidatePois });

    // 3. Run 12-Factor Optimization Engine
    const { days, costBreakdown, confidence } = this.optimizationEngine.optimize(candidatePois, context);

    context = context.evolve({
      optimizedDays: days,
      costBreakdown,
      confidence,
    });

    // 4. Create rich TripEntity
    const tripTitle = `${city} ${persona} Expedition`;
    const trip = new TripEntity({
      userId,
      title: tripTitle,
      city,
      persona,
      status: TRIP_STATES.PLANNED,
      days,
      costBreakdown,
      confidence,
    });

    // 5. Generate Grounded AI Advice (Gemini 2.0 Flash)
    const aiAdvice = await this.advisorService.generateTripAdvice(trip, context);
    trip.aiAdvice = aiAdvice;

    // 6. Store in In-Memory Trip Store
    memoryTripStore.set(trip.id, trip);

    logger.info({
      event: 'trip_plan_complete',
      tripId: trip.id,
      city,
      persona,
      totalStops: days[0]?.stops?.length || 0,
      elapsedMs: Date.now() - startTime,
    });

    return { trip, context, aiAdvice };
  }

  /**
   * Recalculates remaining stops for an active trip
   */
  async recalculateTrip(tripId, params) {
    const trip = memoryTripStore.get(tripId);
    if (!trip) {
      throw new Error(`Trip with ID "${tripId}" not found.`);
    }

    const reoptimized = this.reoptimizerService.reoptimizeTrip(trip, params);
    trip.days = reoptimized.days;
    trip.updatedAt = new Date().toISOString();
    memoryTripStore.set(trip.id, trip);

    return { trip, reoptimization: reoptimized };
  }
}
