import '../models/nearby_place.dart';

class MapsService {
  const MapsService();

  Future<List<NearbyPlace>> getMapPlaces({
    required double latitude,
    required double longitude,
  }) async {
    return const <NearbyPlace>[];
  }
}
