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

  /// Calculates real profile completion percentage (0.0 to 1.0)
  double get completionPercentage {
    int totalPoints = 0;
    int earnedPoints = 0;

    // Quick Profile Base (45%)
    totalPoints += 15;
    if (name.trim().isNotEmpty) earnedPoints += 15;

    totalPoints += 15;
    if (location.city != null && location.city!.trim().isNotEmpty) earnedPoints += 15;

    totalPoints += 15;
    if (preferences.language != null && preferences.language!.trim().isNotEmpty) earnedPoints += 15;

    // Detailed Profile (25%)
    totalPoints += 10;
    if (profile.bio != null && profile.bio!.trim().isNotEmpty) earnedPoints += 10;

    totalPoints += 10;
    if (profile.gender != null && profile.gender!.trim().isNotEmpty) earnedPoints += 10;

    totalPoints += 5;
    if (profile.dob != null && profile.dob!.trim().isNotEmpty) earnedPoints += 5;

    // Travel Persona (20%)
    totalPoints += 10;
    if (profile.travelInterests != null && profile.travelInterests!.isNotEmpty) earnedPoints += 10;

    totalPoints += 5;
    if (profile.travelPace != null && profile.travelPace!.trim().isNotEmpty) earnedPoints += 5;

    totalPoints += 5;
    if (profile.companionPreference != null && profile.companionPreference!.trim().isNotEmpty) earnedPoints += 5;

    // Travel Preferences (10%)
    totalPoints += 5;
    if (preferences.dietaryPreference != null && preferences.dietaryPreference!.trim().isNotEmpty) earnedPoints += 5;

    totalPoints += 5;
    if (preferences.budgetTier != null && preferences.budgetTier!.trim().isNotEmpty) earnedPoints += 5;

    return earnedPoints / totalPoints;
  }

  /// Returns list of uncompleted profile sections.
  List<String> get missingFields {
    final list = <String>[];
    if (profile.bio == null || profile.bio!.trim().isEmpty) list.add("Personal Bio");
    if (profile.gender == null || profile.gender!.trim().isEmpty) list.add("Gender");
    if (profile.travelInterests == null || profile.travelInterests!.isEmpty) list.add("Travel Interests");
    if (profile.travelPace == null || profile.travelPace!.trim().isEmpty) list.add("Travel Pace");
    if (preferences.dietaryPreference == null || preferences.dietaryPreference!.trim().isEmpty) list.add("Dietary Preference");
    if (preferences.budgetTier == null || preferences.budgetTier!.trim().isEmpty) list.add("Budget Tier");
    return list;
  }

  /// Checks if minimum Quick Setup fields are saved.
  bool get isQuickSetupComplete {
    return name.trim().isNotEmpty &&
        (location.city != null && location.city!.trim().isNotEmpty);
  }

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
  const UserProfile({
    this.dob,
    this.gender,
    this.location,
    this.bio,
    this.travelInterests,
    this.travelPace,
    this.companionPreference,
  });

  final String? dob;
  final String? gender;
  final String? location;
  final String? bio;

  // Travel Persona Fields
  final List<String>? travelInterests;
  final String? travelPace;
  final String? companionPreference;

  UserProfile copyWith({
    String? dob,
    String? gender,
    String? location,
    String? bio,
    List<String>? travelInterests,
    String? travelPace,
    String? companionPreference,
  }) {
    return UserProfile(
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      travelInterests: travelInterests ?? this.travelInterests,
      travelPace: travelPace ?? this.travelPace,
      companionPreference: companionPreference ?? this.companionPreference,
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
  const UserPreferences({
    this.language,
    this.theme,
    this.notifications,
    this.dietaryPreference,
    this.budgetTier,
    this.preferredTransport,
  });

  final String? language;
  final String? theme;
  final bool? notifications;

  // Travel Preference Fields
  final String? dietaryPreference;
  final String? budgetTier;
  final String? preferredTransport;

  UserPreferences copyWith({
    String? language,
    String? theme,
    bool? notifications,
    String? dietaryPreference,
    String? budgetTier,
    String? preferredTransport,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      budgetTier: budgetTier ?? this.budgetTier,
      preferredTransport: preferredTransport ?? this.preferredTransport,
    );
  }
}
