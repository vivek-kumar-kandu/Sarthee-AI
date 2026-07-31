import { MultiModalGraphSearchService } from '../../domain/services/multi_modal_graph_search_service.js';
import { OpenWeatherProvider } from '../../../../infrastructure/providers/weather/openweather_provider.js';
import { RedisCacheService } from '../../../../infrastructure/cache/redis_cache_service.js';

export class PlanJourneyUseCase {
  constructor(
    aiProvider,
    weatherProvider = new OpenWeatherProvider(),
    graphService = new MultiModalGraphSearchService(),
    cacheService = new RedisCacheService(600) // Default TTL 10 minutes (600s)
  ) {
    this.aiProvider = aiProvider;
    this.weatherProvider = weatherProvider;
    this.graphService = graphService;
    this.cacheService = cacheService;
  }

  async execute(requestDto) {
    const originLat = requestDto.originCoords.latitude;
    const originLng = requestDto.originCoords.longitude;
    const destLat = requestDto.destinationCoords.latitude;
    const destLng = requestDto.destinationCoords.longitude;
    const preferredMode = requestDto.preferredMode || 'balanced';

    // 1. Check Redis / Memory Cache First
    const cacheKey = this.cacheService.generateJourneyKey(originLat, originLng, destLat, destLng, preferredMode);
    const cachedPlans = await this.cacheService.get(cacheKey);

    if (cachedPlans) {
      // Flag cached state for logging and envelope metadata
      cachedPlans._isCached = true;
      return cachedPlans;
    }

    // 2. Cache Miss: Execute Multi-Modal Graph Search with OSRM & Dynamic Fares
    const plans = await this.graphService.generateKeyedPlans(
      requestDto.originName,
      originLat,
      originLng,
      requestDto.destinationName,
      destLat,
      destLng
    );

    // 3. Live Weather Advisory Integration
    let weatherAdvisoryText = '';
    if (this.weatherProvider) {
      try {
        const weather = await this.weatherProvider.getWeatherAdvisory(originLat, originLng);
        weatherAdvisoryText = weather.advisory || '';

        plans.recommended.weatherAdvisory = weatherAdvisoryText;
        plans.balanced.weatherAdvisory = weatherAdvisoryText;
      } catch (err) {
        // Fallback silently if weather fetch fails
      }
    }

    // 4. Grounded AI Rationale Integration
    if (this.aiProvider) {
      const recPlan = plans.recommended || plans.balanced;
      const aiResult = await this.aiProvider.generateRationale({
        origin: requestDto.originName,
        destination: requestDto.destinationName,
        timeMinutes: recPlan.totalDurationMinutes,
        cost: recPlan.totalCost,
        safetyScore: recPlan.compositeSafetyScore,
        safetyLabel: recPlan.safetyDetails?.ratingLabel || 'High Safety',
        weather: weatherAdvisoryText,
      });

      plans.balanced.aiRationale = aiResult.rationale;
      plans.recommended.aiRationale = aiResult.rationale;
    }

    // 5. Save Computed Plans into Cache (TTL: 10 minutes)
    await this.cacheService.set(cacheKey, plans, 600);
    plans._isCached = false;

    return plans;
  }
}
