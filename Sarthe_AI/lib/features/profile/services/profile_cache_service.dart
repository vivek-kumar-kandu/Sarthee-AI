import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/profile_entity.dart';

/// ============================================================================
/// PROFILE CACHE SERVICE
/// ============================================================================
///
/// Responsibilities
///
/// ✓ Save profile locally
/// ✓ Read cached profile
/// ✓ Cache expiration
/// ✓ Cache invalidation
///
/// Does NOT perform:
///
/// ✗ Network requests
/// ✗ Business logic
///
/// ============================================================================

abstract interface class IProfileCacheService {
  Future<void> saveCachedProfile(ProfileEntity profile);

  Future<ProfileEntity?> getCachedProfile();

  Future<void> clearCache();
}

class ProfileCacheService implements IProfileCacheService {
  ProfileCacheService._();

  static final ProfileCacheService instance = ProfileCacheService._();

  static const String _profileKey = 'profile_cache';
  static const String _timestampKey = 'profile_cache_timestamp';

  static const Duration _cacheDuration = Duration(hours: 12);

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ===========================================================================
  // GET
  // ===========================================================================

  @override
  Future<ProfileEntity?> getCachedProfile() async {
    try {
      final prefs = await _prefs;

      final jsonString = prefs.getString(_profileKey);
      final timestamp = prefs.getInt(_timestampKey);

      if (jsonString == null || timestamp == null) {
        return null;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      final expired = DateTime.now().difference(cacheTime) > _cacheDuration;

      if (expired) {
        await clearCache();
        return null;
      }

      final Map<String, dynamic> json =
          jsonDecode(jsonString) as Map<String, dynamic>;

      return _fromJson(json);
    } catch (_) {
      await clearCache();
      return null;
    }
  }

  // ===========================================================================
  // SAVE
  // ===========================================================================

  @override
  Future<void> saveCachedProfile(ProfileEntity profile) async {
    final prefs = await _prefs;

    await prefs.setString(_profileKey, jsonEncode(_toJson(profile)));

    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  // ===========================================================================
  // CLEAR
  // ===========================================================================

  @override
  Future<void> clearCache() async {
    final prefs = await _prefs;

    await Future.wait([prefs.remove(_profileKey), prefs.remove(_timestampKey)]);
  }

  // ===========================================================================
  // SERIALIZATION
  // ===========================================================================

  Map<String, dynamic> _toJson(ProfileEntity profile) {
    return {
      'id': profile.id,
      'firebaseUid': profile.firebaseUid,
      'email': profile.email,
      'name': profile.name,
      'picture': profile.picture,
      'role': profile.role,
      'isActive': profile.isActive,
      'createdAt': profile.createdAt.toIso8601String(),
      'updatedAt': profile.updatedAt.toIso8601String(),
      'lastLoginAt': profile.lastLoginAt?.toIso8601String(),

      'profile': {
        'dob': profile.profile.dob,
        'gender': profile.profile.gender,
        'location': profile.profile.location,
        'bio': profile.profile.bio,
      },

      'location': {
        'city': profile.location.city,
        'latitude': profile.location.latitude,
        'longitude': profile.location.longitude,
      },

      'preferences': {
        'language': profile.preferences.language,
        'theme': profile.preferences.theme,
        'notifications': profile.preferences.notifications,
      },
    };
  }

  ProfileEntity _fromJson(Map<String, dynamic> json) {
    return ProfileEntity(
      id: json['id'] ?? '',
      firebaseUid: json['firebaseUid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      picture: json['picture'],
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      profile: UserProfile(
        dob: json['profile']?['dob'],
        gender: json['profile']?['gender'],
        location: json['profile']?['location'],
        bio: json['profile']?['bio'],
      ),
      location: UserLocation(
        city: json['location']?['city'],
        latitude: (json['location']?['latitude'] as num?)?.toDouble(),
        longitude: (json['location']?['longitude'] as num?)?.toDouble(),
      ),
      preferences: UserPreferences(
        language: json['preferences']?['language'],
        theme: json['preferences']?['theme'],
        notifications: json['preferences']?['notifications'],
      ),
    );
  }
}
