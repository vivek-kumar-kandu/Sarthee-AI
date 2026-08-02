import '../entities/transit_hub.dart';
import '../repositories/i_journey_repository.dart';

class GetNearbyHubs {
  final IJourneyRepository repository;

  GetNearbyHubs(this.repository);

  Future<List<TransitHub>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 2.0,
  }) async {
    return await repository.getNearbyTransitHubs(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}
