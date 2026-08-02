import { emergencyService } from '../../domain/services/emergency_service.js';
import { logger } from '../../../../config/logger.js';
import { ResponseBuilder } from '../../../../common/responses/response_builder.js';
import { DataProvenance, CONFIDENCE_TIERS } from '../../../../infrastructure/providers/data_provenance.js';

/**
 * GET /api/v1/emergency?lat=&lng=&subcategory=
 * Fetches nearby emergency services
 */
export const getEmergencyServices = async (req, res) => {
  const startTime = Date.now();
  try {
    const lat = parseFloat(req.query.lat);
    const lng = parseFloat(req.query.lng);

    if (!lat || !lng || isNaN(lat) || isNaN(lng)) {
      return ResponseBuilder.error(res, {
        code: 'INVALID_PARAMS',
        message: 'lat and lng query parameters are required.',
        statusCode: 400,
      });
    }

    const subcategory = req.query.subcategory || 'all';
    const services = await emergencyService.getEmergencyServices(lat, lng, subcategory);
    const latencyMs = Date.now() - startTime;

    const provenance = DataProvenance.live('Overpass Emergency Provider', {
      confidence: CONFIDENCE_TIERS.LIVE_PROCESSED,
      latencyMs,
      cache: false,
      verified: true,
    });

    return ResponseBuilder.success(res, {
      data: {
        subcategory,
        userLocation: { lat, lng },
        services,
        total: services.length,
      },
      provenance,
      statusCode: 200,
      requestId: req.id,
      traceId: req.traceId,
    });
  } catch (err) {
    logger.error({ event: 'emergency_controller_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to fetch emergency services.', statusCode: 500 });
  }
};

/**
 * POST /api/v1/emergency/sos
 * Triggers 24x7 Emergency SOS alert dispatch
 */
export const triggerSos = async (req, res) => {
  const startTime = Date.now();
  try {
    const { lat, lng, userId, emergencyContacts } = req.body || {};

    if (!lat || !lng || typeof lat !== 'number' || typeof lng !== 'number') {
      return ResponseBuilder.error(res, {
        code: 'INVALID_PARAMS',
        message: 'lat and lng numeric body parameters are required.',
        statusCode: 400,
      });
    }

    const sosPayload = await emergencyService.dispatchSos({
      lat,
      lng,
      userId,
      emergencyContacts,
    });
    const latencyMs = Date.now() - startTime;

    const provenance = DataProvenance.live('24x7 SOS Dispatcher Engine', {
      confidence: CONFIDENCE_TIERS.DIRECT_LIVE,
      latencyMs,
      cache: false,
      verified: true,
    });

    return ResponseBuilder.success(res, {
      data: sosPayload,
      provenance,
      statusCode: 201,
      requestId: req.id,
      traceId: req.traceId,
    });
  } catch (err) {
    logger.error({ event: 'sos_trigger_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to trigger SOS dispatch.', statusCode: 500 });
  }
};
