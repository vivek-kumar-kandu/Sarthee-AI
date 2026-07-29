import '../models/home_content_model.dart';

/// ============================================================================
/// SARTHEE AI — HOME LOCAL DATA SOURCE
/// ============================================================================
///
/// Defines the local persistence boundary for the Home feature.
///
/// Architecture:
///
/// HomeRepositoryImpl
///        ↓
/// HomeLocalDataSource
///        ↓
/// Concrete Local Data Source
///        ↓
/// SharedPreferences / Hive / Isar / SQLite / File Cache
///
/// Responsibilities:
///
/// • Read cached Home content
/// • Persist Home content
/// • Clear Home cache
/// • Determine whether cached content exists
/// • Expose cache timestamp
///
/// This abstraction intentionally contains no:
///
/// • Flutter widgets
/// • Riverpod state
/// • GoRouter logic
/// • HTTP/network logic
/// • repository orchestration
/// • business use-case logic
///
/// Cache freshness policy is intentionally separated from storage mechanics.
abstract interface class HomeLocalDataSource {
  // ===========================================================================
  // READ
  // ===========================================================================

  /// Returns the locally cached Home payload.
  ///
  /// Returns `null` when:
  ///
  /// • no cache exists
  /// • the cache was cleared
  /// • the implementation cannot restore a valid cached payload
  Future<HomeContentModel?> getCachedHomeContent();

  // ===========================================================================
  // WRITE
  // ===========================================================================

  /// Persists the latest valid Home payload.
  ///
  /// Concrete implementations should prefer atomic replacement where the
  /// underlying persistence technology supports it.
  Future<void> cacheHomeContent(HomeContentModel content);

  // ===========================================================================
  // CLEAR
  // ===========================================================================

  /// Removes persisted Home content.
  Future<void> clearHomeContent();

  // ===========================================================================
  // CACHE METADATA
  // ===========================================================================

  /// Returns whether a Home cache entry currently exists.
  ///
  /// Concrete implementations may override this with a lightweight metadata
  /// lookup instead of deserializing the complete cached payload.
  Future<bool> hasCachedHomeContent();

  /// Returns the timestamp associated with the cached Home payload.
  ///
  /// Used by repository-level cache strategies such as:
  ///
  /// • cache-first
  /// • network-first
  /// • stale-while-revalidate
  /// • offline fallback
  /// • background refresh
  ///
  /// Returns `null` when no reliable timestamp is available.
  Future<DateTime?> getCacheTimestamp();
}

/// ============================================================================
/// SARTHEE AI — HOME CACHE POLICY
/// ============================================================================
///
/// Immutable policy describing the lifecycle of locally cached Home content.
///
/// Cache lifecycle:
///
///        fresh
///          │
///          ▼
/// ┌───────────────────────┐
/// │ freshnessDuration     │
/// └───────────────────────┘
///          │
///          ▼
///    stale but usable
///          │
///          ▼
/// ┌───────────────────────┐
/// │ maximumStaleDuration  │
/// └───────────────────────┘
///          │
///          ▼
///        expired
///
/// Default policy:
///
/// • Fresh cache:      15 minutes
/// • Maximum fallback: 24 hours
///
/// The policy contains no persistence implementation and can therefore be
/// reused with SharedPreferences, Hive, Isar, SQLite, or another local store.
class HomeCachePolicy {
  const HomeCachePolicy({
    this.freshnessDuration = const Duration(minutes: 15),
    this.maximumStaleDuration = const Duration(hours: 24),
  }) : assert(
         freshnessDuration >= Duration.zero,
         'freshnessDuration cannot be negative.',
       ),
       assert(
         maximumStaleDuration >= Duration.zero,
         'maximumStaleDuration cannot be negative.',
       ),
       assert(
         maximumStaleDuration >= freshnessDuration,
         'maximumStaleDuration must be greater than or equal to '
         'freshnessDuration.',
       );

  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================

  /// Duration during which cached content is considered fresh.
  final Duration freshnessDuration;

  /// Maximum duration during which stale cached content may still be used as
  /// an offline or recoverable fallback.
  final Duration maximumStaleDuration;

  // ===========================================================================
  // CACHE STATE
  // ===========================================================================

  /// Returns whether the cached payload is still fresh.
  bool isFresh(DateTime cachedAt, {DateTime? now}) {
    final Duration cacheAge = age(cachedAt, now: now);

    return cacheAge <= freshnessDuration;
  }

  /// Returns whether the cached payload is stale but still acceptable as a
  /// fallback.
  bool isStaleButUsable(DateTime cachedAt, {DateTime? now}) {
    final Duration cacheAge = age(cachedAt, now: now);

    return cacheAge > freshnessDuration && cacheAge <= maximumStaleDuration;
  }

  /// Returns whether the cached payload exceeded its maximum allowed age.
  bool isExpired(DateTime cachedAt, {DateTime? now}) {
    final Duration cacheAge = age(cachedAt, now: now);

    return cacheAge > maximumStaleDuration;
  }

  /// Returns whether cached content may currently be served.
  ///
  /// Both fresh and stale-but-usable cache entries are considered usable.
  bool isUsable(DateTime cachedAt, {DateTime? now}) {
    return !isExpired(cachedAt, now: now);
  }

  /// Returns whether a background/remote refresh should be attempted.
  ///
  /// Fresh cache does not require refresh.
  ///
  /// Stale or expired cache does.
  bool shouldRefresh(DateTime cachedAt, {DateTime? now}) {
    return !isFresh(cachedAt, now: now);
  }

  // ===========================================================================
  // CACHE AGE
  // ===========================================================================

  /// Calculates the age of a cached payload.
  ///
  /// A future timestamp can occur because of:
  ///
  /// • device clock changes
  /// • timezone/system corrections
  /// • corrupted metadata
  ///
  /// In such situations the cache age is defensively treated as zero.
  Duration age(DateTime cachedAt, {DateTime? now}) {
    final DateTime currentTime = now ?? DateTime.now();

    final Duration difference = currentTime.difference(cachedAt);

    if (difference.isNegative) {
      return Duration.zero;
    }

    return difference;
  }

  // ===========================================================================
  // REMAINING FRESHNESS
  // ===========================================================================

  /// Returns how much fresh-cache lifetime remains.
  ///
  /// Returns [Duration.zero] when the cache is already stale.
  Duration remainingFreshness(DateTime cachedAt, {DateTime? now}) {
    final Duration cacheAge = age(cachedAt, now: now);

    if (cacheAge >= freshnessDuration) {
      return Duration.zero;
    }

    return freshnessDuration - cacheAge;
  }

  /// Returns how much total usable lifetime remains before the cache becomes
  /// expired.
  Duration remainingUsableLifetime(DateTime cachedAt, {DateTime? now}) {
    final Duration cacheAge = age(cachedAt, now: now);

    if (cacheAge >= maximumStaleDuration) {
      return Duration.zero;
    }

    return maximumStaleDuration - cacheAge;
  }

  // ===========================================================================
  // CACHE STATE RESOLUTION
  // ===========================================================================

  /// Resolves the current lifecycle state of a cache entry.
  HomeCacheState resolveState(DateTime cachedAt, {DateTime? now}) {
    final Duration cacheAge = age(cachedAt, now: now);

    if (cacheAge <= freshnessDuration) {
      return HomeCacheState.fresh;
    }

    if (cacheAge <= maximumStaleDuration) {
      return HomeCacheState.stale;
    }

    return HomeCacheState.expired;
  }

  // ===========================================================================
  // VALUE SEMANTICS
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is HomeCachePolicy &&
        other.freshnessDuration == freshnessDuration &&
        other.maximumStaleDuration == maximumStaleDuration;
  }

  @override
  int get hashCode => Object.hash(freshnessDuration, maximumStaleDuration);

  @override
  String toString() {
    return 'HomeCachePolicy('
        'freshnessDuration: $freshnessDuration, '
        'maximumStaleDuration: $maximumStaleDuration'
        ')';
  }
}

/// ============================================================================
/// SARTHEE AI — HOME CACHE STATE
/// ============================================================================
///
/// High-level lifecycle state of cached Home content.
///
/// This enum allows repository code to avoid repeatedly comparing durations.
enum HomeCacheState {
  /// Cache is inside [HomeCachePolicy.freshnessDuration].
  fresh,

  /// Cache is older than the freshness duration but still inside
  /// [HomeCachePolicy.maximumStaleDuration].
  stale,

  /// Cache exceeded [HomeCachePolicy.maximumStaleDuration].
  expired;

  // ===========================================================================
  // DERIVED STATE
  // ===========================================================================

  bool get isFresh => this == HomeCacheState.fresh;

  bool get isStale => this == HomeCacheState.stale;

  bool get isExpired => this == HomeCacheState.expired;

  /// Fresh and stale cache may both be served depending on repository policy.
  bool get isUsable => !isExpired;

  /// Stale/expired cache indicates that a remote refresh should be attempted.
  bool get requiresRefresh => !isFresh;
}
