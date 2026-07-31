import { emergencyService } from '../domain/services/emergency_service.js';
import { logger } from '../../../../config/logger.js';

/**
 * GET /api/v1/emergency?lat=&lng=&subcategory=
 * Fetches nearby emergency services
 */
export const getEmergencyServices = async (req, res) => {
  try {
    const lat = parseFloat(req.query.lat);
    const lng = parseFloat(req.query.lng);

    if (!lat || !lng || isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({
        error: 'INVALID_PARAMS',
        message: 'lat and lng query parameters are required.',
      });
    }

    const subcategory = req.query.subcategory || 'all';
    const services = await emergencyService.getEmergencyServices(lat, lng, subcategory);

    return res.status(200).json({
      subcategory,
      userLocation: { lat, lng },
      services,
      total: services.length,
    });
  } catch (err) {
    logger.error({ event: 'emergency_controller_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to fetch emergency services.' });
  }
};

/**
 * POST /api/v1/emergency/sos
 * Triggers 24x7 Emergency SOS alert dispatch
 */
export const triggerSos = async (req, res) => {
  try {
    const { lat, lng, userId, emergencyContacts } = req.body || {};

    if (!lat || !lng || typeof lat !== 'number' || typeof lng !== 'number') {
      return res.status(400).json({
        error: 'INVALID_PARAMS',
        message: 'lat and lng numeric body parameters are required.',
      });
    }

    const sosPayload = await emergencyService.dispatchSos({
      lat,
      lng,
      userId,
      emergencyContacts,
    });

    return res.status(200).json(sosPayload);
  } catch (err) {
    logger.error({ event: 'sos_trigger_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to trigger SOS dispatch.' });
  }
};
