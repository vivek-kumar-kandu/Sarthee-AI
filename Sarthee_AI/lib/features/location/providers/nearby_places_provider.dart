import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_response.dart';
import '../models/location_model.dart';
import '../models/nearby_place.dart';
import '../services/places_service.dart';

class NearbyPlacesNotifier
    extends StateNotifier<AsyncValue<ApiResponse<List<NearbyPlace>>>> {
  NearbyPlacesNotifier(this._placesService)
      : super(const AsyncValue.loading());

  final PlacesService _placesService;

  Future<void> loadNearbyPlaces({required LocationModel? location, String category = 'all'}) async {
    state = const AsyncValue.loading();

    if (location == null) {
      state = AsyncValue.data(
        ApiResponse<List<NearbyPlace>>(
          status: 'success',
          data: const <NearbyPlace>[],
          meta: Meta.empty(),
        ),
      );
      return;
    }

    try {
      final response = await _placesService.getNearbyPlaces(location, category: category);
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final placesServiceProvider = Provider<PlacesService>((ref) {
  return const PlacesService();
});

final nearbyPlacesProvider =
    StateNotifierProvider<NearbyPlacesNotifier, AsyncValue<ApiResponse<List<NearbyPlace>>>>((
      ref,
    ) {
      return NearbyPlacesNotifier(ref.watch(placesServiceProvider));
    });
