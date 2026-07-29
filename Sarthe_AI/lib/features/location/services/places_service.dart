import '../models/nearby_place.dart';
import '../models/location_model.dart';

class PlacesService {
  const PlacesService();

  Future<List<NearbyPlace>> getNearbyPlaces(LocationModel location) async {
    return <NearbyPlace>[];
  }

  Future<List<NearbyPlace>> searchPlaces(String query) async {
    return <NearbyPlace>[];
  }
}
