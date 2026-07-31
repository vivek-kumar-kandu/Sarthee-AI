import 'transit_hub.dart';
import 'safety_profile.dart';
import 'landmark.dart';

enum StepType {
  walk,
  auto,
  eRickshaw,
  sharedAuto,
  metro,
  bus,
  cab,
  train,
}

class JourneyStep {
  final int stepIndex;
  final StepType type;
  final String title;                 // e.g. "Walk 350m to Old Bus Stand Auto Hub"
  final String instruction;           // e.g. "Take E-Rickshaw to Shaheed Sthal Metro"
  final double distanceMeters;
  final int durationMinutes;
  final double estimatedFare;
  final String farePaymentMethod;     // e.g. "Cash / UPI"
  final TransitHub? startHub;
  final TransitHub? endHub;
  final SafetyProfile safety;
  final String? metroLineColor;       // e.g. "#DC2626"
  final String? metroGateNumber;      // e.g. "Gate 2"
  final String? platformNumber;       // e.g. "Platform 1"
  final int? nextDepartureInMinutes;  // e.g. 4 (mins)
  final Landmark? landmark;
  final String? landmarkTip;

  const JourneyStep({
    required this.stepIndex,
    required this.type,
    required this.title,
    required this.instruction,
    required this.distanceMeters,
    required this.durationMinutes,
    required this.estimatedFare,
    required this.farePaymentMethod,
    this.startHub,
    this.endHub,
    this.safety = const SafetyProfile(),
    this.metroLineColor,
    this.metroGateNumber,
    this.platformNumber,
    this.nextDepartureInMinutes,
    this.landmark,
    this.landmarkTip,
  });

  factory JourneyStep.fromJson(Map<String, dynamic> json) {
    return JourneyStep(
      stepIndex: (json['stepIndex'] as num?)?.toInt() ?? 1,
      type: _parseStepType(json['type'] as String?),
      title: json['title'] as String? ?? 'Travel Step',
      instruction: json['instruction'] as String? ?? '',
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      estimatedFare: (json['estimatedFare'] as num?)?.toDouble() ?? 0.0,
      farePaymentMethod: json['farePaymentMethod'] as String? ?? 'UPI/Cash',
      metroLineColor: json['metroLineColor'] as String?,
      metroGateNumber: json['metroGateNumber'] as String?,
      platformNumber: json['platformNumber'] as String?,
      nextDepartureInMinutes: (json['nextDepartureInMinutes'] as num?)?.toInt(),
      landmark: json['landmark'] != null && json['landmark'] is Map<String, dynamic>
          ? Landmark.fromJson(json['landmark'] as Map<String, dynamic>)
          : null,
      landmarkTip: json['landmarkTip'] as String?,
    );
  }

  static StepType _parseStepType(String? typeStr) {
    switch (typeStr) {
      case 'walk':
        return StepType.walk;
      case 'auto':
        return StepType.auto;
      case 'eRickshaw':
        return StepType.eRickshaw;
      case 'sharedAuto':
        return StepType.sharedAuto;
      case 'metro':
        return StepType.metro;
      case 'bus':
        return StepType.bus;
      case 'cab':
        return StepType.cab;
      case 'train':
        return StepType.train;
      default:
        return StepType.walk;
    }
  }
}
