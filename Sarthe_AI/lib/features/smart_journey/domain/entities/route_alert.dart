enum AlertCategory {
  traffic,
  weather,
  metroDelay,
  roadClosed,
  emergency,
  festival,
  crowd,
  maintenance,
}

enum AlertSeverity {
  info,
  warning,
  critical,
}

class RouteAlert {
  final String id;
  final AlertCategory category;
  final AlertSeverity severity;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? suggestedAlternative;

  const RouteAlert({
    required this.id,
    required this.category,
    required this.severity,
    required this.title,
    required this.message,
    required this.timestamp,
    this.suggestedAlternative,
  });
}
