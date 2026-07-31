import { JourneyProviderRegistry } from '../../../../infrastructure/providers/registry/journey_provider_registry.js';
import { OverpassPoiProvider } from '../../../../infrastructure/providers/poi/overpass_poi_provider.js';
import { OpenWeatherProvider } from '../../../../infrastructure/providers/weather/openweather_provider.js';
import { MultiModalGraphSearchService } from '../services/multi_modal_graph_search_service.js';
import { JourneyAdvisorService } from '../services/journey_advisor_service.js';
import { JourneyContext } from '../value_objects/journey_context.js';
import { logger } from '../../../../config/logger.js';

export class JourneyIntelligenceOrchestrator {
  constructor(options = {}) {
    this.registry = options.registry || new JourneyProviderRegistry();
    this.graphSearchService = options.graphSearchService || new MultiModalGraphSearchService();
    this.advisorService = options.advisorService || new JourneyAdvisorService();

    // Register Default Providers
    const poiEnabled = process.env.ENABLE_POI !== 'false';
    const weatherEnabled = process.env.ENABLE_WEATHER !== 'false';

    this.registry.register(new OverpassPoiProvider({ isEnabled: poiEnabled }));
    this.registry.register(new OpenWeatherProvider({ isEnabled: weatherEnabled }));
  }

  /**
   * Orchestrates dynamic journey intelligence concurrently
   */
  async orchestrate(dto) {
    const startTime = Date.now();
    const { originName, originLat, originLng, destinationName, destinationLat, destinationLng, preferredMode } = dto;

    const requestContext = { originLat, originLng, destLat: destinationLat, destLng: destinationLng };

    // Phase 1: Parallel Independent Provider Lookups via Promise.allSettled
    const [graphResult, poiResult, weatherResult] = await Promise.allSettled([
      this.graphSearchService.generateKeyedPlans(
        originName, originLat, originLng,
        destinationName, destinationLat, destinationLng,
        { hourOfDay: new Date().getHours() }
      ),
      this.registry.get('overpass_poi')?.execute(requestContext) ?? Promise.resolve(null),
      this.registry.get('openweather')?.execute(requestContext) ?? Promise.resolve(null),
    ]);

    const plans = graphResult.status === 'fulfilled' ? graphResult.value : {};
    const originLandmark = poiResult.status === 'fulfilled' ? poiResult.value : null;
    const weatherAdvisory = weatherResult.status === 'fulfilled' ? weatherResult.value : null;

    // Attach originLandmark metadata to steps if present
    if (originLandmark) {
      for (const planKey of Object.keys(plans)) {
        if (plans[planKey] && Array.isArray(plans[planKey].steps) && plans[planKey].steps.length > 0) {
          plans[planKey].steps[0].landmarkTip = originLandmark.landmarkTip;
          plans[planKey].steps[0].landmark = {
            name: originLandmark.name,
            type: originLandmark.type,
            distanceMeters: originLandmark.distanceMeters,
            landmarkTip: originLandmark.landmarkTip,
          };
        }
      }
    }

    const orchestrationTimeMs = Date.now() - startTime;

    // Create Immutable JourneyContext
    const context = new JourneyContext({
      originName,
      originLat,
      originLng,
      destinationName,
      destinationLat,
      destinationLng,
      preferredMode,
      plans,
      weather: weatherAdvisory,
      originLandmark,
      providerMetadata: {
        orchestrationTimeMs,
        poiStatus: poiResult.status,
        weatherStatus: weatherResult.status,
      },
    });

    // Phase 2: Grounded AI Explanation Rationale
    let aiRationale = null;
    if (process.env.ENABLE_GEMINI !== 'false') {
      aiRationale = await this.advisorService.generateAdvice(context);
    }

    // Attach aiRationale to all plan options
    if (aiRationale) {
      for (const planKey of Object.keys(plans)) {
        if (plans[planKey]) {
          plans[planKey].aiRationale = aiRationale;
        }
      }
    }

    logger.info({
      event: 'journey_orchestration_complete',
      orchestrationTimeMs,
      originName,
      destinationName,
      preferredMode,
    });

    return { context, aiRationale };
  }
}
