import 'location_model.dart';

class LocationHistory {
  const LocationHistory({
    required this.location,
    required this.visitedAt,
    required this.source,
  });

  final LocationModel location;
  final DateTime visitedAt;
  final String source;
}
