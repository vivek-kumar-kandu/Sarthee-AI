import '../data/models/profile_mapper.dart';
import '../domain/entities/profile_entity.dart';
import '../services/profile_cache_service.dart';
import '../services/profile_service.dart';

/// ============================================================================
/// PROFILE REPOSITORY
/// ============================================================================
///
/// Responsibilities
/// ---------------------------------------------------------------------------
///
/// • Retrieve profile from API
/// • Return ProfileEntity to upper layers
/// • Cache profile locally
/// • Read cached profile when offline
/// • Convert Entity -> Request
/// • Convert Response -> Entity
///
/// UI never touches:
/// - JSON
/// - Response Models
/// - Request Models
///
/// ============================================================================

abstract interface class IProfileRepository {
  Future<ProfileEntity> getProfile({bool forceRefresh = false});

  Future<ProfileEntity> updateProfile(ProfileEntity entity);

  Future<ProfileEntity?> getCachedProfile();

  Future<void> clearCache();
}

class ProfileRepository implements IProfileRepository {
  ProfileRepository({
    IProfileService? profileService,
    IProfileCacheService? cacheService,
  }) : _service = profileService ?? ProfileService(),
       _cache = cacheService ?? ProfileCacheService.instance;

  static const int _maxRetry = 1;

  final IProfileService _service;
  final IProfileCacheService _cache;

  // ===========================================================================
  // GET PROFILE
  // ===========================================================================

  @override
  Future<ProfileEntity> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cache.getCachedProfile();

      if (cached != null) {
        return cached;
      }
    }

    try {
      final response = await _service.getProfile();

      final entity = ProfileMapper.toEntity(response);

      await _cache.saveCachedProfile(entity);

      return entity;
    } on ProfileException {
      final cached = await _cache.getCachedProfile();

      if (cached != null) {
        return cached;
      }

      rethrow;
    }
  }

  // ===========================================================================
  // UPDATE PROFILE
  // ===========================================================================

  @override
  Future<ProfileEntity> updateProfile(ProfileEntity entity) async {
    final request = ProfileMapper.toUpdateRequest(entity);

    int retry = 0;

    while (true) {
      try {
        final response = await _service.updateProfile(request);

        final updatedEntity = ProfileMapper.toEntity(response);

        await _cache.saveCachedProfile(updatedEntity);

        return updatedEntity;
      } on ProfileException catch (e) {
        if (!e.retryable || retry >= _maxRetry) {
          rethrow;
        }

        retry++;
      }
    }
  }

  // ===========================================================================
  // CACHE
  // ===========================================================================

  @override
  Future<ProfileEntity?> getCachedProfile() {
    return _cache.getCachedProfile();
  }

  @override
  Future<void> clearCache() {
    return _cache.clearCache();
  }
}
