import '../entities/journey_plan.dart';
import '../entities/journey_session.dart';
import '../repositories/i_journey_repository.dart';

class ActiveTripTracker {
  final IJourneyRepository repository;

  ActiveTripTracker(this.repository);

  Future<JourneySession> startTrip(JourneyPlan plan) async {
    return await repository.startJourneySession(plan);
  }

  Future<JourneySession> updatePosition({
    required String sessionId,
    required double lat,
    required double lng,
  }) async {
    return await repository.updateSessionLocation(
      sessionId: sessionId,
      currentLat: lat,
      currentLng: lng,
    );
  }

  Future<JourneySession> updateStatus({
    required String sessionId,
    required JourneyStatus status,
  }) async {
    return await repository.updateSessionStatus(
      sessionId: sessionId,
      newStatus: status,
    );
  }
}
