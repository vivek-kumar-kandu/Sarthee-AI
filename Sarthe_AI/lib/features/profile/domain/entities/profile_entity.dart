import 'package:flutter/foundation.dart';

/// ============================================================================
/// PROFILE ENTITY
/// ============================================================================
///
/// Pure Domain Entity.
///
/// This class is used ONLY inside Flutter.
/// It is completely independent of JSON, Dio, MongoDB,
/// Firebase, or Backend implementation.
///
/// UI
/// ↓
/// Provider
/// ↓
/// Repository
///
/// should only work with ProfileEntity.
/// ============================================================================

@immutable
class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.name,
    required this.picture,
    required this.role,
    required this.profile,
    required this.location,
    required this.preferences,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
  });

  final String id;
  final String firebaseUid;
  final String email;
  final String name;
  final String? picture;
  final String role;

  final UserProfile profile;
  final UserLocation location;
  final UserPreferences preferences;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  ProfileEntity copyWith({
    String? id,
    String? firebaseUid,
    String? email,
    String? name,
    String? picture,
    String? role,
    UserProfile? profile,
    UserLocation? location,
    UserPreferences? preferences,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      role: role ?? this.role,
      profile: profile ?? this.profile,
      location: location ?? this.location,
      preferences: preferences ?? this.preferences,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

@immutable
class UserProfile {
  const UserProfile({this.dob, this.gender, this.location, this.bio});

  final String? dob;
  final String? gender;
  final String? location;
  final String? bio;

  UserProfile copyWith({
    String? dob,
    String? gender,
    String? location,
    String? bio,
  }) {
    return UserProfile(
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      bio: bio ?? this.bio,
    );
  }
}

@immutable
class UserLocation {
  const UserLocation({this.city, this.latitude, this.longitude});

  final String? city;
  final double? latitude;
  final double? longitude;

  UserLocation copyWith({String? city, double? latitude, double? longitude}) {
    return UserLocation(
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

@immutable
class UserPreferences {
  const UserPreferences({this.language, this.theme, this.notifications});

  final String? language;
  final String? theme;
  final bool? notifications;

  UserPreferences copyWith({
    String? language,
    String? theme,
    bool? notifications,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
    );
  }
}
