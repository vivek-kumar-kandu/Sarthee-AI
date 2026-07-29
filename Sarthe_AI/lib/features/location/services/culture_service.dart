import '../models/nearby_place.dart';

class CultureService {
  const CultureService();

  Future<List<NearbyPlace>> getCultureHighlights({
    required double latitude,
    required double longitude,
  }) async {
    return const <NearbyPlace>[];
  }
}
