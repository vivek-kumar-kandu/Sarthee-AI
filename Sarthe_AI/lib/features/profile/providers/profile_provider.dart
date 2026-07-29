import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// ============================================================================
/// PROFILE PROVIDER
/// ============================================================================
///
/// Clean Architecture
///
/// UI
///   ↓
/// ProfileNotifier (AsyncNotifier)
///   ↓
/// ProfileRepository
///   ↓
/// ProfileService
///   ↓
/// Backend
///
/// ============================================================================

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepository();
});

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileEntity?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<ProfileEntity?> {
  late final IProfileRepository _repository;

  @override
  Future<ProfileEntity?> build() async {
    _repository = ref.read(profileRepositoryProvider);

    // Load cached profile first
    return await _repository.getCachedProfile();
  }

  // ===========================================================================
  // LOAD PROFILE
  // ===========================================================================

  Future<void> loadProfile({bool forceRefresh = false}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return await _repository.getProfile(forceRefresh: forceRefresh);
    });
  }

  // ===========================================================================
  // REFRESH PROFILE
  // ===========================================================================

  Future<void> refreshProfile() async {
    await loadProfile(forceRefresh: true);
  }

  // ===========================================================================
  // UPDATE PROFILE
  // ===========================================================================

  Future<void> updateProfile(ProfileEntity profile) async {
    final previous = state.valueOrNull;

    // Optimistic UI update
    state = AsyncData(profile);

    final result = await AsyncValue.guard(() async {
      return await _repository.updateProfile(profile);
    });

    result.when(
      data: (updatedProfile) {
        state = AsyncData(updatedProfile);
      },
      loading: () {},
      error: (error, stackTrace) {
        if (previous != null) {
          state = AsyncData(previous);
        } else {
          state = AsyncError(error, stackTrace);
        }
      },
    );
  }

  // ===========================================================================
  // SET PROFILE
  // ===========================================================================

  void setProfile(ProfileEntity profile) {
    state = AsyncData(profile);
  }

  // ===========================================================================
  // LOAD CACHE
  // ===========================================================================

  Future<void> loadCachedProfile() async {
    final cached = await _repository.getCachedProfile();

    if (cached != null) {
      state = AsyncData(cached);
    }
  }

  // ===========================================================================
  // CLEAR PROFILE
  // ===========================================================================

  Future<void> clearProfile() async {
    await _repository.clearCache();

    state = const AsyncData(null);
  }

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  ProfileEntity? get profile => state.valueOrNull;

  bool get hasProfile => profile != null;

  bool get isLoading => state.isLoading;

  bool get hasError => state.hasError;

  Object? get error => state.error;
}
