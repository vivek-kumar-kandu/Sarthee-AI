import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location_failure.dart';
import '../models/location_model.dart';
import '../models/location_permission.dart';
import '../models/location_result.dart';
import '../repositories/location_repository.dart';

class LocationState {
  const LocationState({
    this.status = LocationStatus.initial,
    this.location,
    this.permissionStatus = const LocationPermissionState(),
    this.error,
  });

  final LocationStatus status;
  final LocationModel? location;
  final LocationPermissionState permissionStatus;
  final LocationFailure? error;

  bool get isLoading => status == LocationStatus.loading;
  bool get isSuccess => status == LocationStatus.success;
  bool get isPermissionDenied => status == LocationStatus.permissionDenied;
}

enum LocationStatus { initial, loading, success, permissionDenied, error }

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier(this._repository) : super(const LocationState());

  final LocationRepository _repository;

  Future<void> loadCurrentLocation({bool useCache = true}) async {
    state = LocationState(
      status: LocationStatus.loading,
      permissionStatus: state.permissionStatus,
    );

    final LocationResult<LocationModel> result = await _repository
        .getCurrentLocation(useCache: useCache);

    if (result.isSuccess && result.value != null) {
      final location = result.value!;
      await _repository.recordLocationVisit(location);
      state = LocationState(
        status: LocationStatus.success,
        location: location,
        permissionStatus: const LocationPermissionState(
          status: LocationPermissionStatus.granted,
        ),
      );
      return;
    }

    final failure = result.failure;
    if (failure != null &&
        failure.kind == LocationFailureKind.permissionDenied) {
      state = LocationState(
        status: LocationStatus.permissionDenied,
        permissionStatus: const LocationPermissionState(
          status: LocationPermissionStatus.denied,
        ),
        error: failure,
      );
      return;
    }

    state = LocationState(
      status: LocationStatus.error,
      error: failure ?? LocationFailure.unknown(),
    );
  }

  Future<void> requestLocationPermission() async {
    state = LocationState(
      status: LocationStatus.loading,
      permissionStatus: state.permissionStatus,
    );

    try {
      final permission = await _repository.requestPermission();
      if (permission.isGranted) {
        await loadCurrentLocation(useCache: false);
      } else {
        state = LocationState(
          status: LocationStatus.permissionDenied,
          permissionStatus: permission,
        );
      }
    } catch (error) {
      state = LocationState(
        status: LocationStatus.error,
        error: LocationFailure.unknown(message: error.toString()),
      );
    }
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    return LocationNotifier(ref.watch(locationRepositoryProvider));
  },
);
