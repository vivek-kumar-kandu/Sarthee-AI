import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location_model.dart';
import '../models/nearby_place.dart';
import '../services/places_service.dart';

class NearbyPlacesNotifier
    extends StateNotifier<AsyncValue<List<NearbyPlace>>> {
  NearbyPlacesNotifier(this._placesService)
    : super(const AsyncValue.data(<NearbyPlace>[]));

  final PlacesService _placesService;

  Future<void> loadNearbyPlaces({required LocationModel? location}) async {
    state = const AsyncValue.loading();

    if (location == null) {
      state = const AsyncValue.data(<NearbyPlace>[]);
      return;
    }

    try {
      final places = await _placesService.getNearbyPlaces(location);
      state = AsyncValue.data(places);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final placesServiceProvider = Provider<PlacesService>((ref) {
  return const PlacesService();
});

final nearbyPlacesProvider =
    StateNotifierProvider<NearbyPlacesNotifier, AsyncValue<List<NearbyPlace>>>((
      ref,
    ) {
      return NearbyPlacesNotifier(ref.watch(placesServiceProvider));
    });
