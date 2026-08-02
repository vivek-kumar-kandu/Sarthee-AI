import '../../domain/entities/profile_entity.dart';

/// ============================================================================
/// PROFILE UPDATE REQUEST
/// ============================================================================
///
/// Used only for:
/// PUT /api/v1/auth/profile
///
/// Backend expects:
///
/// {
///   "profile": {},
///   "location": {},
///   "preferences": {}
/// }
/// ============================================================================

class ProfileUpdateRequest {
  const ProfileUpdateRequest({
    required this.profile,
    required this.location,
    required this.preferences,
  });

  final ProfileInfoRequest profile;
  final LocationRequest location;
  final PreferencesRequest preferences;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    final profileJson = profile.toJson();
    final locationJson = location.toJson();
    final preferencesJson = preferences.toJson();

    if (profileJson.isNotEmpty) {
      json['profile'] = profileJson;
    }

    if (locationJson.isNotEmpty) {
      json['location'] = locationJson;
    }

    if (preferencesJson.isNotEmpty) {
      json['preferences'] = preferencesJson;
    }

    return json;
  }

  factory ProfileUpdateRequest.fromEntity(ProfileEntity entity) {
    return ProfileUpdateRequest(
      profile: ProfileInfoRequest(
        dob: entity.profile.dob,
        gender: entity.profile.gender,
        location: entity.profile.location,
        bio: entity.profile.bio,
      ),
      location: LocationRequest(
        city: entity.location.city,
        latitude: entity.location.latitude,
        longitude: entity.location.longitude,
      ),
      preferences: PreferencesRequest(
        language: entity.preferences.language,
        theme: entity.preferences.theme,
        notifications: entity.preferences.notifications,
      ),
    );
  }
}

class ProfileInfoRequest {
  const ProfileInfoRequest({
    this.dob,
    this.gender,
    this.location,
    this.bio,
  });

  final String? dob;
  final String? gender;
  final String? location;
  final String? bio;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (dob != null && dob!.trim().isNotEmpty) {
      json['dob'] = dob;
    }

    if (gender != null && gender!.trim().isNotEmpty) {
      json['gender'] = gender;
    }

    if (location != null && location!.trim().isNotEmpty) {
      json['location'] = location;
    }

    if (bio != null && bio!.trim().isNotEmpty) {
      json['bio'] = bio;
    }

    return json;
  }
}

class LocationRequest {
  const LocationRequest({
    this.city,
    this.latitude,
    this.longitude,
  });

  final String? city;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (city != null && city!.trim().isNotEmpty) {
      json['city'] = city;
    }

    if (latitude != null) {
      json['latitude'] = latitude;
    }

    if (longitude != null) {
      json['longitude'] = longitude;
    }

    return json;
  }
}

class PreferencesRequest {
  const PreferencesRequest({
    this.language,
    this.theme,
    this.notifications,
  });

  final String? language;
  final String? theme;
  final bool? notifications;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (language != null && language!.trim().isNotEmpty) {
      json['language'] = language;
    }

    if (theme != null && theme!.trim().isNotEmpty) {
      json['theme'] = theme;
    }

    if (notifications != null) {
      json['notifications'] = notifications;
    }

    return json;
  }
}