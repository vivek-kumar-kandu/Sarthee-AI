import '../entities/journey_plan.dart';
import '../repositories/i_journey_repository.dart';

class PlanSmartJourney {
  final IJourneyRepository repository;

  PlanSmartJourney(this.repository);

  Future<List<JourneyPlan>> call({
    required String originName,
    required double originLat,
    required double originLng,
    required String destinationName,
    required double destinationLat,
    required double destinationLng,
  }) async {
    return await repository.planJourney(
      originName: originName,
      originLat: originLat,
      originLng: originLng,
      destinationName: destinationName,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
  }
}
