import 'journey_plan.dart';
import 'route_alert.dart';

enum JourneyStatus {
  planned,
  active,
  paused,
  completed,
  cancelled,
  replanning,
}

enum JourneyEventType {
  started,
  reachedHub,
  boardedTransit,
  exitedGate,
  rerouted,
  completed,
}

class JourneyEvent {
  final String id;
  final JourneyEventType type;
  final String description;
  final DateTime timestamp;

  const JourneyEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

class JourneySession {
  final String sessionId;
  final JourneyPlan plan;
  final JourneyStatus status;
  final int currentStepIndex;
  final double currentLatitude;
  final double currentLongitude;
  final double progress;                 // 0.0 to 1.0
  final double remainingDistanceMeters;
  final int remainingDurationMinutes;
  final DateTime startedAt;
  final DateTime lastUpdated;
  final DateTime? endTime;
  final List<JourneyEvent> events;
  final List<RouteAlert> activeAlerts;

  const JourneySession({
    required this.sessionId,
    required this.plan,
    required this.status,
    required this.currentStepIndex,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.progress,
    required this.remainingDistanceMeters,
    required this.remainingDurationMinutes,
    required this.startedAt,
    required this.lastUpdated,
    this.endTime,
    this.events = const [],
    this.activeAlerts = const [],
  });

  JourneySession copyWith({
    JourneyStatus? status,
    int? currentStepIndex,
    double? currentLatitude,
    double? currentLongitude,
    double? progress,
    double? remainingDistanceMeters,
    int? remainingDurationMinutes,
    DateTime? lastUpdated,
    DateTime? endTime,
    List<JourneyEvent>? events,
    List<RouteAlert>? activeAlerts,
  }) {
    return JourneySession(
      sessionId: sessionId,
      plan: plan,
      status: status ?? this.status,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      progress: progress ?? this.progress,
      remainingDistanceMeters: remainingDistanceMeters ?? this.remainingDistanceMeters,
      remainingDurationMinutes: remainingDurationMinutes ?? this.remainingDurationMinutes,
      startedAt: startedAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
      endTime: endTime ?? this.endTime,
      events: events ?? this.events,
      activeAlerts: activeAlerts ?? this.activeAlerts,
    );
  }
}
