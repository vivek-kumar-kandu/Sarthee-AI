import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/location_failure.dart';
import '../models/location_model.dart';
import '../models/location_permission.dart';
import '../models/location_result.dart';

class GpsService {
  GpsService._();

  static final GpsService instance = GpsService._();

  Future<LocationPermissionState> checkPermission() async {
    final LocationPermission permission = await Geolocator.checkPermission();

    return _mapPermission(permission);
  }

  Future<LocationPermissionState> requestPermission() async {
    final LocationPermission permission = await Geolocator.requestPermission();

    return _mapPermission(permission);
  }

  Future<bool> isGpsEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocationResult<LocationModel>> getCurrentLocation({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationFailureResult<LocationModel>(
          LocationFailure.gpsDisabled(),
        );
      }

      final LocationPermissionState permissionState = await checkPermission();
      if (!permissionState.isGranted) {
        return LocationFailureResult<LocationModel>(
          LocationFailure.permissionDenied(),
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      ).timeout(timeout);

      return LocationSuccess<LocationModel>(
        LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: DateTime.now(),
        ),
      );
    } on TimeoutException {
      return LocationFailureResult<LocationModel>(
        LocationFailure.unknown(message: 'Location request timed out.'),
      );
    } on LocationServiceDisabledException {
      return LocationFailureResult<LocationModel>(
        LocationFailure.gpsDisabled(),
      );
    } on PermissionDeniedException {
      return LocationFailureResult<LocationModel>(
        LocationFailure.permissionDenied(),
      );
    } on Exception catch (_) {
      return LocationFailureResult<LocationModel>(LocationFailure.unknown());
    }
  }

  LocationPermissionState _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return const LocationPermissionState(
          status: LocationPermissionStatus.granted,
        );
      case LocationPermission.denied:
        return const LocationPermissionState(
          status: LocationPermissionStatus.denied,
        );
      case LocationPermission.deniedForever:
        return const LocationPermissionState(
          status: LocationPermissionStatus.permanentlyDenied,
        );
      case LocationPermission.unableToDetermine:
        return const LocationPermissionState(
          status: LocationPermissionStatus.unknown,
        );
    }
  }
}
