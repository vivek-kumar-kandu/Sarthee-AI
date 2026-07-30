import '../../domain/entities/journey_plan.dart';
import '../../domain/entities/journey_session.dart';
import '../../domain/entities/journey_step.dart';
import '../../domain/entities/transit_hub.dart';
import '../../domain/entities/transport_option.dart';
import '../../domain/entities/fare_summary.dart';
import '../../domain/entities/safety_profile.dart';
import '../../domain/entities/route_alert.dart';
import '../../domain/repositories/i_journey_repository.dart';
import '../datasources/local_transit_datasource.dart';

class JourneyRepositoryImpl implements IJourneyRepository {
  JourneySession? _cachedActiveSession;

  @override
  Future<List<JourneyPlan>> planJourney({
    required String originName,
    required double originLat,
    required double originLng,
    required String destinationName,
    required double destinationLat,
    required double destinationLng,
  }) async {
    // Simulate slight async network/data latency
    await Future.delayed(const Duration(milliseconds: 300));

    final metroStart = LocalTransitDatasource.dmrcStations.first;
    final metroEnd = LocalTransitDatasource.dmrcStations[1]; // Rajiv Chowk

    // Common Steps
    final step1WalkToAuto = JourneyStep(
      stepIndex: 1,
      type: StepType.walk,
      title: "Walk 350m to Old Bus Stand Auto Hub",
      instruction: "Head south towards Old Bus Stand Auto Hub. Safe paved footpath available.",
      distanceMeters: 350,
      durationMinutes: 5,
      estimatedFare: 0.0,
      farePaymentMethod: "Free",
      safety: const SafetyProfile(lightingRating: 9, crowdRating: 8),
    );

    final step2AutoToMetro = JourneyStep(
      stepIndex: 2,
      type: StepType.eRickshaw,
      title: "Take E-Rickshaw to Shaheed Sthal Metro Station",
      instruction: "Board E-Rickshaw at Stand. Frequent departures every 2 mins.",
      distanceMeters: 1200,
      durationMinutes: 8,
      estimatedFare: 15.0,
      farePaymentMethod: "UPI / Cash",
      endHub: TransitHub(
        id: metroStart.stationId,
        name: metroStart.stationName,
        type: TransitHubType.metroStation,
        latitude: metroStart.latitude,
        longitude: metroStart.longitude,
        supportedModes: [TransportMode.metro],
        primaryGate: "Gate No. 2",
        metroLineColor: metroStart.lineColorHex,
      ),
    );

    final step3MetroRide = JourneyStep(
      stepIndex: 3,
      type: StepType.metro,
      title: "Red Line Metro -> Yellow/Blue Line at Rajiv Chowk",
      instruction: "Board Red Line Train towards Rithala. Interchange at Kashmere Gate to Yellow Line towards Rajiv Chowk.",
      distanceMeters: 24500,
      durationMinutes: 42,
      estimatedFare: 50.0,
      farePaymentMethod: "DMRC Smart Card / UPI Ticket",
      metroLineColor: "#DC2626",
      metroGateNumber: "Gate 2 (Shaheed Sthal) -> Exit Gate 5 (Rajiv Chowk)",
      platformNumber: "Platform 1",
      nextDepartureInMinutes: 3,
      startHub: TransitHub(
        id: metroStart.stationId,
        name: metroStart.stationName,
        type: TransitHubType.metroStation,
        latitude: metroStart.latitude,
        longitude: metroStart.longitude,
        supportedModes: [TransportMode.metro],
      ),
      endHub: TransitHub(
        id: metroEnd.stationId,
        name: metroEnd.stationName,
        type: TransitHubType.metroStation,
        latitude: metroEnd.latitude,
        longitude: metroEnd.longitude,
        supportedModes: [TransportMode.metro],
        primaryGate: "Exit Gate 5",
      ),
    );

    final step4WalkToDest = JourneyStep(
      stepIndex: 4,
      type: StepType.walk,
      title: "Exit Gate 5 & Walk 250m to Connaught Place",
      instruction: "Exit from Rajiv Chowk Gate 5 (Palika Bazaar concourse). Walk 250m to destination.",
      distanceMeters: 250,
      durationMinutes: 4,
      estimatedFare: 0.0,
      farePaymentMethod: "Free",
      safety: const SafetyProfile(lightingRating: 9, crowdRating: 9),
    );

    final steps = [step1WalkToAuto, step2AutoToMetro, step3MetroRide, step4WalkToDest];

    final fareSummary = FareSummary(
      totalAmount: 65.0,
      items: const [
        FareItem(legTitle: "E-Rickshaw to Metro", amount: 15.0, paymentMethod: "Cash/UPI", confidence: DataConfidence.verified),
        FareItem(legTitle: "DMRC Metro Ticket", amount: 50.0, paymentMethod: "Smart Card", confidence: DataConfidence.live),
      ],
      smartCardDiscountEligible: true,
      potentialSavings: 5.0,
    );

    // Option 1: Balanced (Default)
    final planBalanced = JourneyPlan(
      id: "plan_balanced_01",
      originName: originName,
      destinationName: destinationName,
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      mode: RecommendationMode.balanced,
      totalDurationMinutes: 59,
      totalCost: 65.0,
      totalWalkingDistanceMeters: 600,
      compositeSafetyScore: 88,
      steps: steps,
      fareSummary: fareSummary,
      aiRationale: "Sarthee Suggests: Metro is 41 mins faster than cab due to heavy GT Road traffic. Total walking is only 600m.",
    );

    // Option 2: Fastest (Cab)
    final planFastest = JourneyPlan(
      id: "plan_fastest_01",
      originName: originName,
      destinationName: destinationName,
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      mode: RecommendationMode.fastest,
      totalDurationMinutes: 45,
      totalCost: 380.0,
      totalWalkingDistanceMeters: 50,
      compositeSafetyScore: 85,
      steps: [
        JourneyStep(
          stepIndex: 1,
          type: StepType.cab,
          title: "Direct Door-to-Door Taxi / Cab",
          instruction: "Board Uber / Ola cab from Home to Connaught Place.",
          distanceMeters: 26000,
          durationMinutes: 45,
          estimatedFare: 380.0,
          farePaymentMethod: "App Payment / Cash",
        ),
      ],
      fareSummary: const FareSummary(
        totalAmount: 380.0,
        items: [FareItem(legTitle: "Direct Cab", amount: 380.0, paymentMethod: "Online", confidence: DataConfidence.estimated)],
      ),
      aiRationale: "Fastest direct route with minimal walking, but incurs higher fare of ₹380.",
    );

    // Option 3: Cheapest (Bus + Metro)
    final planCheapest = JourneyPlan(
      id: "plan_cheapest_01",
      originName: originName,
      destinationName: destinationName,
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      mode: RecommendationMode.cheapest,
      totalDurationMinutes: 75,
      totalCost: 40.0,
      totalWalkingDistanceMeters: 750,
      compositeSafetyScore: 82,
      steps: steps,
      fareSummary: const FareSummary(
        totalAmount: 40.0,
        items: [
          FareItem(legTitle: "Local DTC Bus", amount: 10.0, paymentMethod: "Ticket", confidence: DataConfidence.verified),
          FareItem(legTitle: "Metro Ticket", amount: 30.0, paymentMethod: "Smart Card", confidence: DataConfidence.live),
        ],
      ),
      aiRationale: "Cheapest option saving ₹25 compared to auto combination.",
    );

    // Option 4: Safest (Main Roads & Well-lit concourses)
    final planSafest = JourneyPlan(
      id: "plan_safest_01",
      originName: originName,
      destinationName: destinationName,
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      mode: RecommendationMode.safest,
      totalDurationMinutes: 62,
      totalCost: 75.0,
      totalWalkingDistanceMeters: 400,
      compositeSafetyScore: 96,
      steps: steps,
      fareSummary: fareSummary,
      aiRationale: "Safest night-friendly route via high-illumination corridors and verified police booths.",
    );

    // Option 5: Comfort Mode (Minimum walking)
    final planComfort = JourneyPlan(
      id: "plan_comfort_01",
      originName: originName,
      destinationName: destinationName,
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      mode: RecommendationMode.comfort,
      totalDurationMinutes: 52,
      totalCost: 120.0,
      totalWalkingDistanceMeters: 150,
      compositeSafetyScore: 92,
      steps: steps,
      fareSummary: fareSummary,
      aiRationale: "Comfort mode optimized for minimal walking with lift/elevator access at all station gates.",
    );

    return [planBalanced, planFastest, planCheapest, planSafest, planComfort];
  }

  @override
  Future<List<TransitHub>> getNearbyTransitHubs({
    required double latitude,
    required double longitude,
    double radiusKm = 2.0,
  }) async {
    return LocalTransitDatasource.autoAndERickshawHubs;
  }

  @override
  Future<SafetyProfile> evaluateRouteSafety({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    return const SafetyProfile(
      lightingRating: 9,
      crowdRating: 8,
      policePresenceRating: 8,
      cctvRating: 9,
      womensSafetyRating: 9,
      medicalAccessRating: 8,
      safetyAdvisory: "Verified safe route along main illuminated arterial roads.",
    );
  }

  @override
  Future<JourneySession> startJourneySession(JourneyPlan plan) async {
    final session = JourneySession(
      sessionId: "session_${DateTime.now().millisecondsSinceEpoch}",
      plan: plan,
      status: JourneyStatus.active,
      currentStepIndex: 0,
      currentLatitude: plan.originLat,
      currentLongitude: plan.originLng,
      progress: 0.0,
      remainingDistanceMeters: plan.steps.fold(0.0, (sum, s) => sum + s.distanceMeters),
      remainingDurationMinutes: plan.totalDurationMinutes,
      startedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      events: [
        JourneyEvent(
          id: "event_1",
          type: JourneyEventType.started,
          description: "Journey started from ${plan.originName}",
          timestamp: DateTime.now(),
        ),
      ],
      activeAlerts: [
        RouteAlert(
          id: "alert_1",
          category: AlertCategory.traffic,
          severity: AlertSeverity.info,
          title: "Heavy GT Road Traffic",
          message: "Cab travel time increased by +25 mins. Metro recommended.",
          timestamp: DateTime.now(),
        ),
      ],
    );

    _cachedActiveSession = session;
    return session;
  }

  @override
  Future<JourneySession> updateSessionLocation({
    required String sessionId,
    required double currentLat,
    required double currentLng,
  }) async {
    if (_cachedActiveSession != null && _cachedActiveSession!.sessionId == sessionId) {
      _cachedActiveSession = _cachedActiveSession!.copyWith(
        currentLatitude: currentLat,
        currentLongitude: currentLng,
      );
      return _cachedActiveSession!;
    }
    throw Exception("Session not found");
  }

  @override
  Future<JourneySession> updateSessionStatus({
    required String sessionId,
    required JourneyStatus newStatus,
  }) async {
    if (_cachedActiveSession != null && _cachedActiveSession!.sessionId == sessionId) {
      _cachedActiveSession = _cachedActiveSession!.copyWith(
        status: newStatus,
        endTime: (newStatus == JourneyStatus.completed || newStatus == JourneyStatus.cancelled)
            ? DateTime.now()
            : null,
      );
      return _cachedActiveSession!;
    }
    throw Exception("Session not found");
  }

  @override
  Future<JourneySession?> getCachedActiveSession() async {
    return _cachedActiveSession;
  }
}
