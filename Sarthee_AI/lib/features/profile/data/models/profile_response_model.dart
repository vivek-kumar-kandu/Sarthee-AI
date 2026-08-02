import '../../domain/entities/profile_entity.dart';

/// ============================================================================
/// PROFILE RESPONSE MODEL
/// ============================================================================
///
/// Converts Backend JSON
///
/// GET /auth/profile
///
/// into
///
/// ProfileEntity
///
/// UI never works directly with this model.
/// ============================================================================

class ProfileResponseModel {
  const ProfileResponseModel({required this.user});

  final ProfileResponseUser user;

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return ProfileResponseModel(
      user: ProfileResponseUser.fromJson(
        data['user'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  ProfileEntity toEntity() {
    return user.toEntity();
  }
}

class ProfileResponseUser {
  const ProfileResponseUser({
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

  final ProfileInfoModel profile;
  final LocationInfoModel location;
  final PreferencesModel preferences;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  factory ProfileResponseUser.fromJson(Map<String, dynamic> json) {
    return ProfileResponseUser(
      id: json['id']?.toString() ?? '',
      firebaseUid: json['firebaseUid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      picture: json['picture']?.toString(),
      role: json['role']?.toString() ?? 'user',

      profile: ProfileInfoModel.fromJson(
        json['profile'] as Map<String, dynamic>? ?? {},
      ),

      location: LocationInfoModel.fromJson(
        json['location'] as Map<String, dynamic>? ?? {},
      ),

      preferences: PreferencesModel.fromJson(
        json['preferences'] as Map<String, dynamic>? ?? {},
      ),

      isActive: json['isActive'] ?? true,

      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),

      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),

      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'].toString())
          : null,
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      firebaseUid: firebaseUid,
      email: email,
      name: name,
      picture: picture,
      role: role,

      profile: profile.toEntity(),

      location: location.toEntity(),

      preferences: preferences.toEntity(),

      isActive: isActive,

      createdAt: createdAt,

      updatedAt: updatedAt,

      lastLoginAt: lastLoginAt,
    );
  }
}

class ProfileInfoModel {
  const ProfileInfoModel({
    required this.dob,
    required this.gender,
    required this.location,
    required this.bio,
  });

  final String? dob;
  final String? gender;
  final String? location;
  final String? bio;

  factory ProfileInfoModel.fromJson(Map<String, dynamic> json) {
    return ProfileInfoModel(
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
      location: json['location']?.toString(),
      bio: json['bio']?.toString(),
    );
  }

  UserProfile toEntity() {
    return UserProfile(dob: dob, gender: gender, location: location, bio: bio);
  }
}

class LocationInfoModel {
  const LocationInfoModel({
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  final String? city;
  final double? latitude;
  final double? longitude;

  factory LocationInfoModel.fromJson(Map<String, dynamic> json) {
    return LocationInfoModel(
      city: json['city']?.toString(),

      latitude: (json['latitude'] as num?)?.toDouble(),

      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  UserLocation toEntity() {
    return UserLocation(city: city, latitude: latitude, longitude: longitude);
  }
}

class PreferencesModel {
  const PreferencesModel({
    required this.language,
    required this.theme,
    required this.notifications,
  });

  final String? language;
  final String? theme;
  final bool? notifications;

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      language: json['language']?.toString(),
      theme: json['theme']?.toString(),
      notifications: json['notifications'] as bool?,
    );
  }

  UserPreferences toEntity() {
    return UserPreferences(
      language: language,
      theme: theme,
      notifications: notifications,
    );
  }
}
