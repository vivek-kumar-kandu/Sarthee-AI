import '../../domain/entities/profile_entity.dart';
import 'profile_response_model.dart';
import 'profile_update_request.dart';

/// ============================================================================
/// PROFILE MAPPER
/// ============================================================================
///
/// Single Responsibility:
///
/// Converts between:
///
/// Backend Response
///        ↓
/// ProfileEntity
///        ↓
/// Update Request
///
/// This is the ONLY place where conversion logic should exist.
///
/// Repository
/// Provider
/// UI
/// Service
///
/// never perform manual mapping.
/// ============================================================================

final class ProfileMapper {
  const ProfileMapper._();

  /// --------------------------------------------------------------------------
  /// Backend Response → Entity
  /// --------------------------------------------------------------------------

  static ProfileEntity toEntity(ProfileResponseModel response) {
    return response.toEntity();
  }

  /// --------------------------------------------------------------------------
  /// Entity → Update Request
  /// --------------------------------------------------------------------------

  static ProfileUpdateRequest toUpdateRequest(ProfileEntity entity) {
    return ProfileUpdateRequest.fromEntity(entity);
  }

  /// --------------------------------------------------------------------------
  /// Copy existing entity with updated values
  ///
  /// Useful for Edit Profile Screen.
  /// --------------------------------------------------------------------------

  static ProfileEntity merge({
    required ProfileEntity original,
    String? name,
    String? picture,

    UserProfile? profile,
    UserLocation? location,
    UserPreferences? preferences,
  }) {
    return original.copyWith(
      name: name,
      picture: picture,
      profile: profile ?? original.profile,
      location: location ?? original.location,
      preferences: preferences ?? original.preferences,
    );
  }

  /// --------------------------------------------------------------------------
  /// Check Profile Completion
  ///
  /// Can be used for:
  ///
  /// ✔ onboarding
  /// ✔ progress bar
  /// ✔ profile completion badge
  /// --------------------------------------------------------------------------

  static bool isProfileComplete(ProfileEntity entity) {
    return entity.name.trim().isNotEmpty &&
        entity.email.trim().isNotEmpty &&
        (entity.profile.gender?.isNotEmpty ?? false) &&
        (entity.profile.dob?.isNotEmpty ?? false) &&
        (entity.location.city?.isNotEmpty ?? false);
  }

  /// --------------------------------------------------------------------------
  /// Profile Completion Percentage
  ///
  /// Future:
  /// Home Screen
  /// Dashboard
  /// Gamification
  /// --------------------------------------------------------------------------

  static double completion(ProfileEntity entity) {
    int total = 8;
    int completed = 0;

    if (entity.name.trim().isNotEmpty) completed++;
    if (entity.email.trim().isNotEmpty) completed++;
    if (entity.picture?.isNotEmpty ?? false) completed++;
    if (entity.profile.dob?.isNotEmpty ?? false) completed++;
    if (entity.profile.gender?.isNotEmpty ?? false) completed++;
    if (entity.profile.bio?.isNotEmpty ?? false) completed++;
    if (entity.location.city?.isNotEmpty ?? false) completed++;
    if (entity.preferences.language?.isNotEmpty ?? false) completed++;

    return completed / total;
  }
}
