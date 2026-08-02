import { TripPlanningOrchestrator } from '../../domain/services/trip_planning_orchestrator.js';
import { TripDTO } from '../../application/dto/trip_dto.js';
import { TRIP_STATES, TripEntity } from '../../domain/entities/trip_entity.js';
import { tripRepository } from '../../infrastructure/database/trip_repository.js';
import { ResponseBuilder } from '../../../../common/responses/response_builder.js';
import { DataProvenance, CONFIDENCE_TIERS } from '../../../../infrastructure/providers/data_provenance.js';
import { logger } from '../../../../config/logger.js';

const orchestrator = new TripPlanningOrchestrator();

/**
 * Helper to ensure entity methods like transitionTo and getSharePayload exist
 */
function ensureTripEntity(tripData) {
  if (!tripData) return null;
  if (tripData instanceof TripEntity) return tripData;
  return new TripEntity(tripData);
}

/**
 * POST /api/v1/trips/plan
 * Generates an AI-optimized trip itinerary from natural language prompt & constraints
 */
export const planTrip = async (req, res) => {
  const startTime = Date.now();
  try {
    const {
      rawPrompt = '',
      city = 'Jaipur',
      totalHours = 6,
      persona = 'Family',
      maxBudget = 1500,
      dynamicConstraints = {},
      userId = 'guest',
    } = req.body || {};

    const { trip, aiAdvice } = await orchestrator.planTrip({
      rawPrompt,
      city,
      totalHours: parseFloat(totalHours) || 6,
      persona,
      maxBudget: parseFloat(maxBudget) || 1500,
      dynamicConstraints,
      userId,
    });

    const responseBody = TripDTO.toApiResponse(trip, aiAdvice);
    const latencyMs = Date.now() - startTime;

    const provenance = DataProvenance.multiProvider({
      engine: 'Sarthee 12-Factor Optimizer',
      providers: ['OSRM', 'OpenWeather', 'Overpass OSM', 'Gemini 2.0 Flash'],
      confidence: CONFIDENCE_TIERS.MULTI_PROVIDER,
      latencyMs,
      cache: false,
      verified: true,
    });

    return ResponseBuilder.success(res, {
      data: responseBody.data,
      provenance,
      statusCode: 200,
      requestId: req.id,
      traceId: req.traceId,
    });
  } catch (err) {
    logger.error({ event: 'plan_trip_error', error: err.message, stack: err.stack });
    return ResponseBuilder.error(res, {
      code: 'SERVER_ERROR',
      message: 'Failed to plan trip.',
      statusCode: 500,
    });
  }
};

/**
 * POST /api/v1/trips/save
 * Saves a planned trip to user saved trips
 */
export const saveTrip = async (req, res) => {
  try {
    const { tripId } = req.body || {};
    let trip = await tripRepository.findById(tripId);

    if (!trip) {
      return ResponseBuilder.error(res, {
        code: 'NOT_FOUND',
        message: `Trip "${tripId}" not found.`,
        statusCode: 404,
      });
    }

    trip = ensureTripEntity(trip);
    trip.transitionTo(TRIP_STATES.SAVED);
    await tripRepository.save(trip);

    const responseBody = TripDTO.toApiResponse(trip);
    return ResponseBuilder.success(res, {
      data: responseBody.data,
      provenance: DataProvenance.live('Sarthee Trip Engine', { confidence: CONFIDENCE_TIERS.LIVE_PROCESSED }),
    });
  } catch (err) {
    logger.error({ event: 'save_trip_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to save trip.', statusCode: 500 });
  }
};

/**
 * GET /api/v1/trips
 * Returns list of user saved & active trips
 */
export const getTrips = async (req, res) => {
  try {
    const allTrips = await tripRepository.list({ isArchived: false });
    return ResponseBuilder.success(res, {
      data: {
        total: allTrips.length,
        trips: allTrips.map((t) => TripDTO.fromEntity(ensureTripEntity(t))),
      },
      provenance: DataProvenance.live('Sarthee Trip Repository', { confidence: CONFIDENCE_TIERS.LIVE_PROCESSED }),
    });
  } catch (err) {
    logger.error({ event: 'get_trips_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to list trips.', statusCode: 500 });
  }
};

/**
 * GET /api/v1/trips/:id
 * Fetches a single trip by ID
 */
export const getTripById = async (req, res) => {
  try {
    const trip = await tripRepository.findById(req.params.id);
    if (!trip) {
      return ResponseBuilder.error(res, { code: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.`, statusCode: 404 });
    }
    const responseBody = TripDTO.toApiResponse(ensureTripEntity(trip));
    return ResponseBuilder.success(res, {
      data: responseBody.data,
      provenance: DataProvenance.live('Sarthee Trip Repository', { confidence: CONFIDENCE_TIERS.LIVE_PROCESSED }),
    });
  } catch (err) {
    logger.error({ event: 'get_trip_by_id_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to fetch trip.', statusCode: 500 });
  }
};

/**
 * PATCH /api/v1/trips/:id
 * Updates trip title or persona
 */
export const updateTrip = async (req, res) => {
  try {
    let trip = await tripRepository.findById(req.params.id);
    if (!trip) {
      return ResponseBuilder.error(res, { code: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.`, statusCode: 404 });
    }

    trip = ensureTripEntity(trip);
    if (req.body.title) trip.title = req.body.title;
    if (req.body.persona) trip.persona = req.body.persona;
    trip.updatedAt = new Date().toISOString();

    await tripRepository.save(trip);
    const responseBody = TripDTO.toApiResponse(trip);
    return ResponseBuilder.success(res, {
      data: responseBody.data,
      provenance: DataProvenance.live('Sarthee Trip Repository', { confidence: CONFIDENCE_TIERS.LIVE_PROCESSED }),
    });
  } catch (err) {
    logger.error({ event: 'update_trip_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to update trip.', statusCode: 500 });
  }
};

/**
 * DELETE /api/v1/trips/:id
 * Deletes or archives a trip
 */
export const deleteTrip = async (req, res) => {
  try {
    const exists = await tripRepository.exists(req.params.id);
    if (!exists) {
      return ResponseBuilder.error(res, { code: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.`, statusCode: 404 });
    }
    await tripRepository.delete(req.params.id);
    return ResponseBuilder.success(res, { message: `Trip "${req.params.id}" deleted.` });
  } catch (err) {
    logger.error({ event: 'delete_trip_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to delete trip.', statusCode: 500 });
  }
};

/**
 * POST /api/v1/trips/:id/start
 * Transitions trip state machine to STARTED
 */
export const startTrip = async (req, res) => {
  try {
    let trip = await tripRepository.findById(req.params.id);
    if (!trip) {
      return ResponseBuilder.error(res, { code: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.`, statusCode: 404 });
    }
    trip = ensureTripEntity(trip);
    trip.transitionTo(TRIP_STATES.STARTED);
    await tripRepository.save(trip);
    const responseBody = TripDTO.toApiResponse(trip);
    return ResponseBuilder.success(res, {
      data: responseBody.data,
      provenance: DataProvenance.live('Sarthee Trip Repository', { confidence: CONFIDENCE_TIERS.LIVE_PROCESSED }),
    });
  } catch (err) {
    logger.error({ event: 'start_trip_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to start trip.', statusCode: 500 });
  }
};

/**
 * POST /api/v1/trips/:id/share
 * Generates share token & QR code payload
 */
export const shareTrip = async (req, res) => {
  try {
    let trip = await tripRepository.findById(req.params.id);
    if (!trip) {
      return ResponseBuilder.error(res, { code: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.`, statusCode: 404 });
    }
    trip = ensureTripEntity(trip);
    return ResponseBuilder.success(res, {
      data: trip.getSharePayload(),
      provenance: DataProvenance.live('Sarthee Trip Repository', { confidence: CONFIDENCE_TIERS.LIVE_PROCESSED }),
    });
  } catch (err) {
    logger.error({ event: 'share_trip_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to share trip.', statusCode: 500 });
  }
};

/**
 * POST /api/v1/trips/:id/recalculate
 * Triggers Live Trip Re-Optimization Engine
 */
export const recalculateTrip = async (req, res) => {
  try {
    const { currentStopIndex = 0, triggerReason = 'schedule_missed', weatherSnapshot = null } = req.body || {};
    const result = await orchestrator.recalculateTrip(req.params.id, {
      currentStopIndex,
      triggerReason,
      weatherSnapshot,
    });
    return ResponseBuilder.success(res, {
      data: result,
      provenance: DataProvenance.multiProvider({ engine: 'Live Re-Optimizer', providers: ['OpenWeather', 'OSRM'], confidence: CONFIDENCE_TIERS.LIVE_PROCESSED }),
    });
  } catch (err) {
    logger.error({ event: 'recalculate_trip_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: err.message, statusCode: 500 });
  }
};

/**
 * POST /api/v1/trips/:id/completeStop
 * Marks a stop as completed in active trip
 */
export const completeStop = async (req, res) => {
  try {
    let trip = await tripRepository.findById(req.params.id);
    if (!trip) {
      return ResponseBuilder.error(res, { code: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.`, statusCode: 404 });
    }
    trip = ensureTripEntity(trip);
    const { stopNumber = 1 } = req.body || {};

    if (trip.days[0]?.stops) {
      const stop = trip.days[0].stops.find((s) => s.stopNumber === stopNumber);
      if (stop) stop.isCompleted = true;
    }

    await tripRepository.save(trip);
    const responseBody = TripDTO.toApiResponse(trip);
    return ResponseBuilder.success(res, {
      data: responseBody.data,
      provenance: DataProvenance.live('Sarthee Trip Repository', { confidence: CONFIDENCE_TIERS.LIVE_PROCESSED }),
    });
  } catch (err) {
    logger.error({ event: 'complete_stop_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to complete stop.', statusCode: 500 });
  }
};

export const exportTrip = async (req, res) => {
  let trip = await tripRepository.findById(req.params.id);
  if (!trip) return ResponseBuilder.error(res, { code: 'NOT_FOUND', message: 'Trip not found.', statusCode: 404 });
  trip = ensureTripEntity(trip);
  return ResponseBuilder.success(res, { data: TripDTO.fromEntity(trip) });
};

export const exportPdf = async (req, res) => {
  return ResponseBuilder.success(res, { data: { downloadUrl: `/api/v1/trips/${req.params.id}/download-pdf` }, message: 'PDF export payload generated' });
};

export const exportCalendar = async (req, res) => {
  return ResponseBuilder.success(res, { data: { downloadUrl: `/api/v1/trips/${req.params.id}/trip.ics` }, message: 'iCal calendar file generated' });
};
