import '../models/location_history.dart';
import '../models/location_model.dart';
import '../models/location_permission.dart';
import '../models/location_result.dart';
import 'gps_service.dart';
import 'location_cache_service.dart';

class LocationService {
  LocationService({GpsService? gpsService, LocationCacheService? cacheService})
    : _gpsService = gpsService ?? GpsService.instance,
      _cacheService = cacheService ?? LocationCacheService.instance;

  final GpsService _gpsService;
  final LocationCacheService _cacheService;

  Future<LocationResult<LocationModel>> resolveCurrentLocation({
    bool useCache = true,
  }) async {
    if (useCache) {
      final cached = await _cacheService.getCachedLocation();
      if (cached != null) {
        return LocationSuccess<LocationModel>(cached);
      }
    }

    final result = await _gpsService.getCurrentLocation();
    if (result.isSuccess && result.value != null) {
      await _cacheService.saveLocation(result.value!);
    }

    return result;
  }

  Future<LocationPermissionState> checkPermission() async {
    return _gpsService.checkPermission();
  }

  Future<LocationPermissionState> requestPermission() async {
    return _gpsService.requestPermission();
  }

  Future<bool> isGpsEnabled() async {
    return _gpsService.isGpsEnabled();
  }

  Future<List<LocationHistory>> getLocationHistory() async {
    return const <LocationHistory>[];
  }

  Future<void> addLocationHistory(
    LocationModel location, {
    String source = 'gps',
  }) async {
    await Future<void>.value();
    if (location.timestamp == null) {
      return;
    }
  }
}
