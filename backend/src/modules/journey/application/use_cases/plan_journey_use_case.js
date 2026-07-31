import { JourneyIntelligenceOrchestrator } from '../../domain/services/journey_intelligence_orchestrator.js';
import { JourneyAdvisorService } from '../../domain/services/journey_advisor_service.js';
import { JourneyResponseMapper } from '../../presentation/mappers/journey_response_mapper.js';
import { RedisCacheService } from '../../../../infrastructure/cache/redis_cache_service.js';

export class PlanJourneyUseCase {
  constructor(
    aiProvider,
    weatherProvider,
    graphService,
    cacheService = new RedisCacheService(600)
  ) {
    this.cacheService = cacheService;
    const advisorService = aiProvider ? new JourneyAdvisorService(aiProvider) : new JourneyAdvisorService();
    this.orchestrator = new JourneyIntelligenceOrchestrator({
      graphSearchService: graphService,
      advisorService,
    });
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
      cachedPlans._isCached = true;
      return cachedPlans;
    }

    // 2. Cache Miss: Delegate to JourneyIntelligenceOrchestrator
    const dto = {
      originName: requestDto.originName,
      originLat,
      originLng,
      destinationName: requestDto.destinationName,
      destinationLat: destLat,
      destinationLng: destLng,
      preferredMode,
    };

    const { context, aiRationale } = await this.orchestrator.orchestrate(dto);

    // 3. Map to Clean Response DTO
    const responsePayload = JourneyResponseMapper.toResponseDTO(context, aiRationale);

    // 4. Save to Redis Cache (10-min TTL)
    await this.cacheService.set(cacheKey, responsePayload, 600);

    return responsePayload;
  }
}
