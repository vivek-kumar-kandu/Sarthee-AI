import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

class LocationCacheService {
  LocationCacheService._();

  static final LocationCacheService instance = LocationCacheService._();

  static const String _latitudeKey = 'location_cache_latitude';
  static const String _longitudeKey = 'location_cache_longitude';
  static const String _cityKey = 'location_cache_city';
  static const String _countryKey = 'location_cache_country';
  static const String _timestampKey = 'location_cache_timestamp';
  static const String _accuracyKey = 'location_cache_accuracy';

  static const Duration _maxAge = Duration(hours: 6);

  Future<LocationModel?> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();

    final latitude = prefs.getDouble(_latitudeKey);
    final longitude = prefs.getDouble(_longitudeKey);

    if (latitude == null || longitude == null) {
      return null;
    }

    final timestampMillis = prefs.getInt(_timestampKey);
    final timestamp = timestampMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(timestampMillis)
        : null;

    final location = LocationModel(
      latitude: latitude,
      longitude: longitude,
      city: prefs.getString(_cityKey),
      country: prefs.getString(_countryKey),
      accuracy: prefs.getDouble(_accuracyKey),
      timestamp: timestamp,
    );

    if (timestamp == null) {
      return null;
    }

    final age = DateTime.now().difference(timestamp);
    if (age > _maxAge) {
      await clear();
      return null;
    }

    return location;
  }

  Future<void> saveLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(_latitudeKey, location.latitude);
    await prefs.setDouble(_longitudeKey, location.longitude);
    await prefs.setString(_cityKey, location.city ?? '');
    await prefs.setString(_countryKey, location.country ?? '');
    await prefs.setDouble(_accuracyKey, location.accuracy ?? 0.0);
    await prefs.setInt(
      _timestampKey,
      (location.timestamp ?? DateTime.now()).millisecondsSinceEpoch,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latitudeKey);
    await prefs.remove(_longitudeKey);
    await prefs.remove(_cityKey);
    await prefs.remove(_countryKey);
    await prefs.remove(_timestampKey);
    await prefs.remove(_accuracyKey);
  }
}
