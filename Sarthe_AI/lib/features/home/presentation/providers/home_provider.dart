import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/providers/profile_provider.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';

/// Single repository provider for Home Dashboard
final homeRepositoryProvider = Provider<IHomeRepository>((ref) {
  return HomeRepositoryImpl();
});

/// Single AsyncNotifier State Provider for Home Dashboard
final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeEntity>(
  HomeNotifier.new,
);

class HomeNotifier extends AsyncNotifier<HomeEntity> {
  late final IHomeRepository _repository;

  @override
  Future<HomeEntity> build() async {
    _repository = ref.watch(homeRepositoryProvider);

    // 1. Instant 10ms Cache Load
    final cached = await _repository.getCachedHomeData();
    if (cached != null) {
      state = AsyncValue.data(cached);
    }

    // 2. Background Sync for Fresh Data
    final profile = ref.watch(profileProvider).value;
    final freshData = await _repository.getHomeData();

    if (profile != null) {
      // Synchronize dynamic user profile details into home greeting
      return freshData.copyWith(
        greeting: HomeGreeting(
          userName: profile.name,
          city: profile.location.city ?? freshData.greeting.city,
          temperature: freshData.greeting.temperature,
          weatherCondition: freshData.greeting.weatherCondition,
          avatarUrl: profile.picture,
        ),
      );
    }

    return freshData;
  }

  /// Refreshes home dashboard data on Pull-to-Refresh
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final fresh = await _repository.getHomeData(forceRefresh: true);
      final profile = ref.read(profileProvider).value;
      if (profile != null) {
        return fresh.copyWith(
          greeting: HomeGreeting(
            userName: profile.name,
            city: profile.location.city ?? fresh.greeting.city,
            temperature: fresh.greeting.temperature,
            weatherCondition: fresh.greeting.weatherCondition,
            avatarUrl: profile.picture,
          ),
        );
      }
      return fresh;
    });
  }
}
