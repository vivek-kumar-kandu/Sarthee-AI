import { MultiModalGraphSearchService } from '../../domain/services/multi_modal_graph_search_service.js';

export class PlanJourneyUseCase {
  constructor(aiProvider, weatherProvider, graphService = new MultiModalGraphSearchService()) {
    this.aiProvider = aiProvider;
    this.weatherProvider = weatherProvider;
    this.graphService = graphService;
  }

  async execute(requestDto) {
    const plans = this.graphService.generateKeyedPlans(
      requestDto.originName,
      requestDto.originCoords.latitude,
      requestDto.originCoords.longitude,
      requestDto.destinationName,
      requestDto.destinationCoords.latitude,
      requestDto.destinationCoords.longitude
    );

    // Contextual AI Rationale integration
    if (this.aiProvider) {
      const aiResult = await this.aiProvider.generateRationale({
        origin: requestDto.originName,
        destination: requestDto.destinationName,
        timeMinutes: plans.balanced.totalDurationMinutes,
        cost: plans.balanced.totalCost,
      });

      plans.balanced.aiRationale = aiResult.rationale;
      plans.recommended.aiRationale = aiResult.rationale;
    }

    return plans;
  }
}
