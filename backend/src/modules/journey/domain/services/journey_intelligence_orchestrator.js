import { JourneyProviderRegistry } from '../../../../infrastructure/providers/registry/journey_provider_registry.js';
import { OverpassPoiProvider } from '../../../../infrastructure/providers/poi/overpass_poi_provider.js';
import { OpenWeatherProvider } from '../../../../infrastructure/providers/weather/openweather_provider.js';
import { GtfsRealtimeProvider } from '../../../../infrastructure/providers/transit/gtfs_realtime_provider.js';
import { GtfsStaticProvider } from '../../../../infrastructure/providers/transit/gtfs_static_provider.js';
import { TrafficProvider } from '../../../../infrastructure/providers/traffic/traffic_provider.js';
import { IncidentProvider } from '../../../../infrastructure/providers/incidents/incident_provider.js';
import { MultiModalGraphSearchService } from '../services/multi_modal_graph_search_service.js';
import { RouteRankingEngine } from '../services/route_ranking_engine.js';
import { PersonalizationEngine } from '../services/personalization_engine.js';
import { TransitStatusService } from '../services/transit_status_service.js';
import { TrafficStatusService } from '../services/traffic_status_service.js';
import { IncidentStatusService } from '../services/incident_status_service.js';
import { JourneyAdvisorService } from '../services/journey_advisor_service.js';
import { JourneyContext } from '../value_objects/journey_context.js';
import { logger } from '../../../../config/logger.js';

export class JourneyIntelligenceOrchestrator {
  constructor(options = {}) {
    this.registry = options.registry || new JourneyProviderRegistry();
    this.graphSearchService = options.graphSearchService || new MultiModalGraphSearchService();
    this.advisorService = options.advisorService || new JourneyAdvisorService();
    this.routeRankingEngine = options.routeRankingEngine || new RouteRankingEngine();

    // Register Default Providers
    const poiEnabled = process.env.ENABLE_POI !== 'false';
    const weatherEnabled = process.env.ENABLE_WEATHER !== 'false';
    const transitEnabled = process.env.ENABLE_TRANSIT !== 'false';
    const trafficEnabled = process.env.ENABLE_TRAFFIC !== 'false';
    const incidentEnabled = process.env.ENABLE_INCIDENTS !== 'false';

    this.gtfsRealtimeProvider = new GtfsRealtimeProvider({ isEnabled: transitEnabled });
    this.gtfsStaticProvider = new GtfsStaticProvider();
    this.trafficProvider = new TrafficProvider({ isEnabled: trafficEnabled });
    this.incidentProvider = new IncidentProvider({ isEnabled: incidentEnabled });

    this.transitStatusService = new TransitStatusService(this.gtfsRealtimeProvider, this.gtfsStaticProvider);
    this.trafficStatusService = new TrafficStatusService(this.trafficProvider);
    this.incidentStatusService = new IncidentStatusService(this.incidentProvider);

    this.registry.register(new OverpassPoiProvider({ isEnabled: poiEnabled }));
    this.registry.register(new OpenWeatherProvider({ isEnabled: weatherEnabled }));
    this.registry.register(this.gtfsRealtimeProvider);
    this.registry.register(this.gtfsStaticProvider);
    this.registry.register(this.trafficProvider);
    this.registry.register(this.incidentProvider);
  }

  /**
   * Orchestrates dynamic journey intelligence concurrently
   */
  async orchestrate(dto) {
    const startTime = Date.now();
    const { originName, originLat, originLng, destinationName, destinationLat, destinationLng, preferredMode } = dto;

    const requestContext = { originLat, originLng, destLat: destinationLat, destLng: destinationLng };

    // Phase 1: Parallel Independent Provider Lookups via Promise.allSettled
    const [graphResult, poiResult, weatherResult, transitResult, trafficResult, incidentResult] = await Promise.allSettled([
      this.graphSearchService.generateKeyedPlans(
        originName, originLat, originLng,
        destinationName, destinationLat, destinationLng,
        { hourOfDay: new Date().getHours() }
      ),
      this.registry.get('overpass_poi')?.execute(requestContext) ?? Promise.resolve(null),
      this.registry.get('openweather')?.execute(requestContext) ?? Promise.resolve(null),
      this.transitStatusService.resolveTransitStatus(requestContext),
      this.trafficStatusService.resolveTrafficStatus(requestContext),
      this.incidentStatusService.resolveIncidents(requestContext),
    ]);

    const plans = graphResult.status === 'fulfilled' ? graphResult.value : {};
    const originLandmark = poiResult.status === 'fulfilled' ? poiResult.value : null;
    const weatherAdvisory = weatherResult.status === 'fulfilled' ? weatherResult.value : null;
    const transitEnvelope = transitResult.status === 'fulfilled' ? transitResult.value : null;
    const trafficEnvelope = trafficResult.status === 'fulfilled' ? trafficResult.value : null;
    const incidentsList = incidentResult.status === 'fulfilled' ? incidentResult.value : [];

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

    // Apply Deterministic Route Re-Ranking based on Weather, Time, Traffic, and Incidents
    const weatherRankedPlans = this.routeRankingEngine.reRankPlans(plans, weatherAdvisory, new Date().getHours(), trafficEnvelope, incidentsList);
    const rankedPlans = PersonalizationEngine.applyUserPreferences(weatherRankedPlans, dto.userPreferences || {});

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
      plans: rankedPlans,
      weather: weatherAdvisory,
      transit: transitEnvelope,
      traffic: trafficEnvelope,
      incidents: incidentsList,
      originLandmark,
      providerMetadata: {
        orchestrationTimeMs,
        poiStatus: poiResult.status,
        weatherStatus: weatherResult.status,
        transitStatus: transitResult.status,
        trafficStatus: trafficResult.status,
        incidentStatus: incidentResult.status,
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
