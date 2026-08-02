import '../entities/journey_plan.dart';
import '../entities/journey_session.dart';
import '../entities/transit_hub.dart';
import '../entities/safety_profile.dart';

abstract class IJourneyRepository {
  /// Generate multi-modal journey plans connecting Origin and Destination
  Future<List<JourneyPlan>> planJourney({
    required String originName,
    required double originLat,
    required double originLng,
    required String destinationName,
    required double destinationLat,
    required double destinationLng,
  });

  /// Discover nearby transit hubs (Auto Stands, Metro Stations, Bus Stops)
  Future<List<TransitHub>> getNearbyTransitHubs({
    required double latitude,
    required double longitude,
    double radiusKm = 2.0,
  });

  /// Evaluate composite route safety
  Future<SafetyProfile> evaluateRouteSafety({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  });

  /// Start active journey tracking session
  Future<JourneySession> startJourneySession(JourneyPlan plan);

  /// Update journey session location and state
  Future<JourneySession> updateSessionLocation({
    required String sessionId,
    required double currentLat,
    required double currentLng,
  });

  /// Pause, Resume, or Cancel active journey session
  Future<JourneySession> updateSessionStatus({
    required String sessionId,
    required JourneyStatus newStatus,
  });

  /// Retrieve cached offline active trip data
  Future<JourneySession?> getCachedActiveSession();
}
