import '../models/location_history.dart';
import '../models/location_model.dart';
import '../models/location_permission.dart';
import '../models/location_result.dart';
import '../services/location_service.dart';

class LocationRepository {
  LocationRepository({LocationService? locationService})
    : _locationService = locationService ?? LocationService();

  final LocationService _locationService;

  Future<LocationResult<LocationModel>> getCurrentLocation({
    bool useCache = true,
  }) async {
    return _locationService.resolveCurrentLocation(useCache: useCache);
  }

  Future<LocationPermissionState> checkPermission() async {
    return _locationService.checkPermission();
  }

  Future<LocationPermissionState> requestPermission() async {
    return _locationService.requestPermission();
  }

  Future<bool> isGpsEnabled() async {
    return _locationService.isGpsEnabled();
  }

  Future<List<LocationHistory>> getLocationHistory() async {
    return _locationService.getLocationHistory();
  }

  Future<void> recordLocationVisit(
    LocationModel location, {
    String source = 'gps',
  }) async {
    await _locationService.addLocationHistory(location, source: source);
  }
}
