import { NearbyOrchestrator } from '../../domain/services/nearby_orchestrator.js';
import { NearbyProviderRegistry } from '../../../../infrastructure/providers/registry/nearby_provider_registry.js';
import {
  HeritageProvider,
  FoodProvider,
  HotelProvider,
  EmergencyProvider,
} from '../../../../infrastructure/providers/nearby/nearby_osm_providers.js';
import { NearbyDTO } from '../../application/dto/nearby_dto.js';
import { logger } from '../../../../config/logger.js';
import nearbyConfig from '../../../../config/nearby.json' with { type: 'json' };

// ── Build registry singleton ─────────────────────────────────────────────────
const registry = new NearbyProviderRegistry();
registry
  .register(new HeritageProvider())
  .register(new FoodProvider())
  .register(new HotelProvider())
  .register(new EmergencyProvider());

const orchestrator = new NearbyOrchestrator(registry);

/**
 * NearbyController
 *
 * GET /api/v1/nearby?lat=&lng=&category=&radius=&limit=&query=
 *
 * Request Params:
 *   lat      {number} Required. User latitude.
 *   lng      {number} Required. User longitude.
 *   category {string} Optional. 'heritage'|'food'|'hotels'|'emergency'|'all' (default: 'all')
 *   radius   {number} Optional. Search radius in meters (default: 5000, max: 15000)
 *   limit    {number} Optional. Max results per category (default: 20, max: 50)
 *   query    {string} Optional. Search query string (e.g. "Veg restaurant near me")
 */
export const getNearbyPlaces = async (req, res) => {
  const startTime = Date.now();

  try {
    // ── Input Validation ────────────────────────────────────────────────────
    const lat = parseFloat(req.query.lat);
    const lng = parseFloat(req.query.lng);

    if (!lat || !lng || isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({
        error: 'INVALID_PARAMS',
        message: 'lat and lng are required numeric query parameters.',
        example: '/api/v1/nearby?lat=26.9124&lng=75.7873&category=heritage&radius=5000',
      });
    }

    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return res.status(400).json({
        error: 'INVALID_PARAMS',
        message: 'lat must be -90..90 and lng must be -180..180.',
      });
    }

    const category = req.query.category?.toLowerCase() || 'all';
    const validCategories = [...nearbyConfig.categories, 'all'];
    if (!validCategories.includes(category)) {
      return res.status(400).json({
        error: 'INVALID_PARAMS',
        message: `Invalid category "${category}". Supported: ${validCategories.join(', ')}`,
      });
    }

    const radius = Math.min(
      parseInt(req.query.radius) || nearbyConfig.radius.defaultMeters,
      nearbyConfig.radius.maxMeters
    );

    const limit = Math.min(
      parseInt(req.query.limit) || nearbyConfig.limits.defaultPerCategory,
      nearbyConfig.limits.maxPerCategory
    );

    const rawQuery = req.query.query ? String(req.query.query).trim() : '';

    // ── Orchestrate Production Discovery Pipeline ──────────────────────────
    const { context, rankedPois, searchIntent } = await orchestrator.discover({
      lat,
      lng,
      category,
      radius,
      limit,
      rawQuery,
      weatherSnapshot: null,
      userPreferences: {},
    });

    // ── DTO Mapping ─────────────────────────────────────────────────────────
    const responseBody = NearbyDTO.toApiResponse(rankedPois, context, searchIntent);

    logger.info({
      event: 'nearby_request_success',
      requestId: context.requestId,
      lat,
      lng,
      category: context.category,
      resultCount: rankedPois.length,
      elapsedMs: Date.now() - startTime,
    });

    return res.status(200).json(responseBody);
  } catch (err) {
    logger.error({
      event: 'nearby_request_error',
      error: err.message,
      stack: err.stack,
    });

    return res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'An unexpected error occurred while fetching nearby places.',
    });
  }
};
