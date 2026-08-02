import 'location_history.dart';
import 'location_model.dart';
import 'nearby_place.dart';

class LocationContext {
  const LocationContext({
    this.currentLocation,
    this.nearbyPlaces = const <NearbyPlace>[],
    this.visitedPlaces = const <LocationHistory>[],
    this.preferences = const <String>[],
  });

  final LocationModel? currentLocation;
  final List<NearbyPlace> nearbyPlaces;
  final List<LocationHistory> visitedPlaces;
  final List<String> preferences;
}
