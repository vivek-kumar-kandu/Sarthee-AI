import 'journey_step.dart';
import 'fare_summary.dart';

enum RecommendationMode {
  recommended,
  fastest,
  cheapest,
  balanced,
  safest,
  accessible,
  eco,
  comfort,
}

class JourneyPlan {
  final String id;
  final String originName;
  final String destinationName;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final RecommendationMode mode;
  final int totalDurationMinutes;
  final double totalCost;
  final double totalWalkingDistanceMeters;
  final int compositeSafetyScore;
  final List<JourneyStep> steps;
  final FareSummary fareSummary;
  final String aiRationale;

  const JourneyPlan({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.mode,
    required this.totalDurationMinutes,
    required this.totalCost,
    required this.totalWalkingDistanceMeters,
    required this.compositeSafetyScore,
    required this.steps,
    required this.fareSummary,
    required this.aiRationale,
  });
}
