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
  final String? polyline;

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
    this.polyline,
  });

  factory JourneyPlan.fromJson(Map<String, dynamic> json) {
    return JourneyPlan(
      id: json['id'] as String? ?? 'plan_01',
      originName: json['originName'] as String? ?? 'Origin',
      destinationName: json['destinationName'] as String? ?? 'Destination',
      originLat: (json['originLat'] as num?)?.toDouble() ?? 0.0,
      originLng: (json['originLng'] as num?)?.toDouble() ?? 0.0,
      destinationLat: (json['destinationLat'] as num?)?.toDouble() ?? 0.0,
      destinationLng: (json['destinationLng'] as num?)?.toDouble() ?? 0.0,
      mode: _parseMode(json['mode'] as String?),
      totalDurationMinutes: (json['totalDurationMinutes'] as num?)?.toInt() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      totalWalkingDistanceMeters: (json['totalWalkingDistanceMeters'] as num?)?.toDouble() ?? 0.0,
      compositeSafetyScore: (json['compositeSafetyScore'] as num?)?.toInt() ?? 80,
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => JourneyStep.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      fareSummary: json['fareSummary'] != null
          ? FareSummary.fromJson(json['fareSummary'] as Map<String, dynamic>)
          : const FareSummary(totalAmount: 0, items: []),
      aiRationale: json['aiRationale'] as String? ?? 'Sarthee AI Journey Recommendation',
      polyline: json['polyline'] as String?,
    );
  }

  static RecommendationMode _parseMode(String? str) {
    switch (str) {
      case 'recommended':
        return RecommendationMode.recommended;
      case 'fastest':
        return RecommendationMode.fastest;
      case 'cheapest':
        return RecommendationMode.cheapest;
      case 'safest':
        return RecommendationMode.safest;
      case 'accessible':
        return RecommendationMode.accessible;
      case 'eco':
        return RecommendationMode.eco;
      case 'comfort':
        return RecommendationMode.comfort;
      default:
        return RecommendationMode.balanced;
    }
  }
}
