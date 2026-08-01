import { TripPlanningOrchestrator, memoryTripStore } from '../../domain/services/trip_planning_orchestrator.js';
import { TripDTO } from '../../application/dto/trip_dto.js';
import { TRIP_STATES } from '../../domain/entities/trip_entity.js';
import { logger } from '../../../../config/logger.js';

const orchestrator = new TripPlanningOrchestrator();

/**
 * POST /api/v1/trips/plan
 * Generates an AI-optimized trip itinerary from natural language prompt & constraints
 */
export const planTrip = async (req, res) => {
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

    return res.status(200).json(TripDTO.toApiResponse(trip, aiAdvice));
  } catch (err) {
    logger.error({ event: 'plan_trip_error', error: err.message, stack: err.stack });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to plan trip.' });
  }
};

/**
 * POST /api/v1/trips/save
 * Saves a planned trip to user saved trips
 */
export const saveTrip = async (req, res) => {
  try {
    const { tripId } = req.body || {};
    const trip = memoryTripStore.get(tripId);

    if (!trip) {
      return res.status(404).json({ error: 'NOT_FOUND', message: `Trip "${tripId}" not found.` });
    }

    trip.transitionTo(TRIP_STATES.SAVED);
    memoryTripStore.set(trip.id, trip);

    return res.status(200).json(TripDTO.toApiResponse(trip));
  } catch (err) {
    logger.error({ event: 'save_trip_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to save trip.' });
  }
};

/**
 * GET /api/v1/trips
 * Returns list of user saved & active trips
 */
export const getTrips = async (req, res) => {
  try {
    const allTrips = Array.from(memoryTripStore.values());
    return res.status(200).json({
      success: true,
      total: allTrips.length,
      data: allTrips.map((t) => TripDTO.fromEntity(t)),
    });
  } catch (err) {
    logger.error({ event: 'get_trips_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to list trips.' });
  }
};

/**
 * GET /api/v1/trips/:id
 * Fetches a single trip by ID
 */
export const getTripById = async (req, res) => {
  try {
    const trip = memoryTripStore.get(req.params.id);
    if (!trip) {
      return res.status(404).json({ error: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.` });
    }
    return res.status(200).json(TripDTO.toApiResponse(trip));
  } catch (err) {
    logger.error({ event: 'get_trip_by_id_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to fetch trip.' });
  }
};

/**
 * PATCH /api/v1/trips/:id
 * Updates trip title or persona
 */
export const updateTrip = async (req, res) => {
  try {
    const trip = memoryTripStore.get(req.params.id);
    if (!trip) {
      return res.status(404).json({ error: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.` });
    }

    if (req.body.title) trip.title = req.body.title;
    if (req.body.persona) trip.persona = req.body.persona;
    trip.updatedAt = new Date().toISOString();

    memoryTripStore.set(trip.id, trip);
    return res.status(200).json(TripDTO.toApiResponse(trip));
  } catch (err) {
    logger.error({ event: 'update_trip_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to update trip.' });
  }
};

/**
 * DELETE /api/v1/trips/:id
 * Deletes or archives a trip
 */
export const deleteTrip = async (req, res) => {
  try {
    const exists = memoryTripStore.has(req.params.id);
    if (!exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.` });
    }
    memoryTripStore.delete(req.params.id);
    return res.status(200).json({ success: true, message: `Trip "${req.params.id}" deleted.` });
  } catch (err) {
    logger.error({ event: 'delete_trip_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to delete trip.' });
  }
};

/**
 * POST /api/v1/trips/:id/start
 * Transitions trip state machine to STARTED
 */
export const startTrip = async (req, res) => {
  try {
    const trip = memoryTripStore.get(req.params.id);
    if (!trip) {
      return res.status(404).json({ error: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.` });
    }
    trip.transitionTo(TRIP_STATES.STARTED);
    memoryTripStore.set(trip.id, trip);
    return res.status(200).json(TripDTO.toApiResponse(trip));
  } catch (err) {
    logger.error({ event: 'start_trip_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to start trip.' });
  }
};

/**
 * POST /api/v1/trips/:id/share
 * Generates share token & QR code payload
 */
export const shareTrip = async (req, res) => {
  try {
    const trip = memoryTripStore.get(req.params.id);
    if (!trip) {
      return res.status(404).json({ error: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.` });
    }
    return res.status(200).json({ success: true, data: trip.getSharePayload() });
  } catch (err) {
    logger.error({ event: 'share_trip_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to share trip.' });
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
    return res.status(200).json({ success: true, data: result });
  } catch (err) {
    logger.error({ event: 'recalculate_trip_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: err.message });
  }
};

/**
 * POST /api/v1/trips/:id/completeStop
 * Marks a stop as completed in active trip
 */
export const completeStop = async (req, res) => {
  try {
    const trip = memoryTripStore.get(req.params.id);
    if (!trip) {
      return res.status(404).json({ error: 'NOT_FOUND', message: `Trip "${req.params.id}" not found.` });
    }
    const { stopNumber = 1 } = req.body || {};

    if (trip.days[0]?.stops) {
      const stop = trip.days[0].stops.find((s) => s.stopNumber === stopNumber);
      if (stop) stop.isCompleted = true;
    }

    memoryTripStore.set(trip.id, trip);
    return res.status(200).json(TripDTO.toApiResponse(trip));
  } catch (err) {
    logger.error({ event: 'complete_stop_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to complete stop.' });
  }
};

/**
 * Future Export endpoints (/export, /pdf, /calendar)
 */
export const exportTrip = async (req, res) => {
  const trip = memoryTripStore.get(req.params.id);
  if (!trip) return res.status(404).json({ error: 'NOT_FOUND' });
  return res.status(200).json({ success: true, format: 'json', data: TripDTO.fromEntity(trip) });
};

export const exportPdf = async (req, res) => {
  return res.status(200).json({ success: true, message: 'PDF export payload generated', downloadUrl: `/api/v1/trips/${req.params.id}/download-pdf` });
};

export const exportCalendar = async (req, res) => {
  return res.status(200).json({ success: true, message: 'iCal calendar file generated', downloadUrl: `/api/v1/trips/${req.params.id}/trip.ics` });
};
