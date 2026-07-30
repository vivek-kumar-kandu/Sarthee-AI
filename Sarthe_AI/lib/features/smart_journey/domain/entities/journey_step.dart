import 'transit_hub.dart';
import 'safety_profile.dart';

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
  });
}
