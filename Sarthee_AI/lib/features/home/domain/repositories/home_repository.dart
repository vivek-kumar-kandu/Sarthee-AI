import '../entities/home_entity.dart';

/// Central Repository Contract for Home Dashboard (Phase 1).
abstract interface class IHomeRepository {
  /// Fetches home dashboard data executing Stale-While-Revalidate pattern.
  Future<HomeEntity> getHomeData({bool forceRefresh = false});

  /// Reads locally cached home data for instant 10ms first paint.
  Future<HomeEntity?> getCachedHomeData();

  /// Persists home entity to local cache.
  Future<void> cacheHomeData(HomeEntity entity);
}
