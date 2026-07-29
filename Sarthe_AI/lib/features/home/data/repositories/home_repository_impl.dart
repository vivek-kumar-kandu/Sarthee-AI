import '../models/home_content_model.dart';

/// ============================================================================
/// SARTHEE AI — HOME LOCAL DATA SOURCE
/// ============================================================================
///
/// Contract responsible for local persistence of Home feature data.
///
/// Architecture:
///
/// HomeRepositoryImpl
///        ↓
/// HomeLocalDataSource
///        ↓
/// Concrete Local Implementation
///        ↓
/// SharedPreferences / Hive / Isar / SQLite / File Cache
///
/// Responsibilities:
///
/// • Read cached Home content
/// • Persist Home content
/// • Clear Home cache
/// • Detect whether cached content exists
/// • Expose cache timestamp metadata
///
/// The repository owns cache/fallback decisions.
///
/// The local data source only owns persistence.
///
/// This layer intentionally contains no:
///
/// • Flutter widgets
/// • Riverpod state
/// • GoRouter logic
/// • Domain use-case orchestration
/// • Remote networking
/// • Cache business orchestration
abstract interface class HomeLocalDataSource {
  // ===========================================================================
  // READ
  // ===========================================================================

  /// Returns locally cached Home content.
  ///
  /// Returns null when:
  ///
  /// • no cache exists
  /// • persisted content cannot be restored
  /// • cache has been cleared
  Future<HomeContentModel?> getCachedHomeContent();

  // ===========================================================================
  // WRITE
  // ===========================================================================

  /// Persists the latest valid Home payload.
  ///
  /// Concrete implementations should update the associated cache timestamp
  /// whenever this operation succeeds.
  ///
  /// When supported by the underlying storage engine, the write should be
  /// atomic to avoid partially persisted Home state.
  Future<void> cacheHomeContent(HomeContentModel content);

  // ===========================================================================
  // CLEAR
  // ===========================================================================

  /// Removes all persisted Home content and associated cache metadata.
  Future<void> clearHomeContent();

  // ===========================================================================
  // EXISTENCE
  // ===========================================================================

  /// Returns whether a Home cache entry currently exists.
  ///
  /// Implementations may override this efficiently without deserializing the
  /// entire Home payload.
  Future<bool> hasCachedHomeContent();

  // ===========================================================================
  // CACHE METADATA
  // ===========================================================================

  /// Returns the timestamp at which the current Home payload was cached.
  ///
  /// Returns null when:
  ///
  /// • no cache exists
  /// • timestamp metadata is unavailable
  /// • timestamp metadata is corrupted
  ///
  /// This timestamp allows [HomeRepositoryImpl] to implement:
  ///
  /// • cache TTL
  /// • stale-while-revalidate
  /// • offline fallback
  /// • expiration
  /// • refresh decisions
  Future<DateTime?> getCacheTimestamp();
}

/// ============================================================================
/// HOME CACHE STATE
/// ============================================================================
///
/// Represents the lifecycle state of locally cached Home content.
///
/// State model:
///
/// fresh
///   Cache is inside [HomeCachePolicy.freshnessDuration].
///
/// stale
///   Cache exceeded normal freshness but remains inside
///   [HomeCachePolicy.maximumStaleDuration].
///
/// expired
///   Cache exceeded the maximum allowed stale duration.
///
/// Typical repository behavior:
///
/// fresh
///      ↓
/// return cache
///
/// stale
///      ↓
/// try remote
///      ↓
/// remote failure
///      ↓
/// stale fallback
///
/// expired
///      ↓
/// remote required
enum HomeCacheState {
  fresh,
  stale,
  expired;

  // ===========================================================================
  // DERIVED STATE
  // ===========================================================================

  bool get isFresh => this == HomeCacheState.fresh;

  bool get isStale => this == HomeCacheState.stale;

  bool get isExpired => this == HomeCacheState.expired;

  /// Fresh and stale cache are both technically usable.
  ///
  /// Expired cache must not normally be returned.
  bool get isUsable => !isExpired;

  /// Whether a remote refresh should normally be attempted.
  bool get requiresRefresh => !isFresh;
}

/// ============================================================================
/// HOME CACHE POLICY
/// ============================================================================
///
/// Pure cache policy used by the repository.
///
/// This class does not read or write storage.
///
/// It only answers questions such as:
///
/// • Is this cache fresh?
/// • Is this cache stale?
/// • Is this cache expired?
/// • Can this cache be used as an offline fallback?
/// • Should a remote refresh be attempted?
///
/// Default strategy:
///
/// 0 ─────────────── 15 min ───────────────────── 24 h ─────────────>
///
///       FRESH                    STALE                 EXPIRED
///
///       use                      refresh               reject
///       directly                 + fallback
///
/// IMPORTANT:
///
/// Constructor assertions intentionally avoid Duration relational operators.
///
/// Dart does not define operators such as:
///
///     durationA >= durationB
///
/// for Duration objects.
///
/// Runtime validation is therefore performed using [validate].
class HomeCachePolicy {
  const HomeCachePolicy({
    this.freshnessDuration = const Duration(minutes: 15),
    this.maximumStaleDuration = const Duration(hours: 24),
  });

  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================

  /// Duration during which cached Home content is considered fresh.
  final Duration freshnessDuration;

  /// Maximum duration during which stale Home content may still be used as a
  /// recoverable/offline fallback.
  final Duration maximumStaleDuration;

  // ===========================================================================
  // VALIDATION
  // ===========================================================================

  /// Validates this policy.
  ///
  /// This method is intentionally runtime-based so the policy can retain a
  /// const constructor without causing const-expression analyzer failures.
  void validate() {
    if (freshnessDuration.isNegative) {
      throw ArgumentError.value(
        freshnessDuration,
        'freshnessDuration',
        'Home cache freshness duration cannot be negative.',
      );
    }

    if (maximumStaleDuration.isNegative) {
      throw ArgumentError.value(
        maximumStaleDuration,
        'maximumStaleDuration',
        'Home cache maximum stale duration cannot be negative.',
      );
    }

    if (maximumStaleDuration.compareTo(freshnessDuration) < 0) {
      throw ArgumentError.value(
        maximumStaleDuration,
        'maximumStaleDuration',
        'maximumStaleDuration must be greater than or equal to '
            'freshnessDuration.',
      );
    }
  }

  /// Returns whether this policy contains valid duration configuration.
  bool get isValid {
    if (freshnessDuration.isNegative || maximumStaleDuration.isNegative) {
      return false;
    }

    return maximumStaleDuration.compareTo(freshnessDuration) >= 0;
  }

  // ===========================================================================
  // STATE RESOLUTION
  // ===========================================================================

  /// Resolves the lifecycle state of cached Home content.
  HomeCacheState resolveState(DateTime cachedAt, {DateTime? now}) {
    final Duration cacheAge = age(cachedAt, now: now);

    if (cacheAge.compareTo(freshnessDuration) <= 0) {
      return HomeCacheState.fresh;
    }

    if (cacheAge.compareTo(maximumStaleDuration) <= 0) {
      return HomeCacheState.stale;
    }

    return HomeCacheState.expired;
  }

  // ===========================================================================
  // FRESHNESS
  // ===========================================================================

  /// Returns whether the cache is still inside the normal freshness window.
  bool isFresh(DateTime cachedAt, {DateTime? now}) {
    return resolveState(cachedAt, now: now).isFresh;
  }

  /// Returns whether cache is stale but still safe as a recoverable fallback.
  bool isStaleButUsable(DateTime cachedAt, {DateTime? now}) {
    return resolveState(cachedAt, now: now).isStale;
  }

  /// Returns whether cache exceeded the maximum stale lifetime.
  bool isExpired(DateTime cachedAt, {DateTime? now}) {
    return resolveState(cachedAt, now: now).isExpired;
  }

  /// Returns whether cache may still be returned.
  ///
  /// Both fresh and stale cache are usable.
  ///
  /// Expired cache is rejected.
  bool isUsable(DateTime cachedAt, {DateTime? now}) {
    return resolveState(cachedAt, now: now).isUsable;
  }

  /// Returns whether the repository should attempt remote refresh.
  bool shouldRefresh(DateTime cachedAt, {DateTime? now}) {
    return resolveState(cachedAt, now: now).requiresRefresh;
  }

  // ===========================================================================
  // AGE
  // ===========================================================================

  /// Calculates the age of a cache entry.
  ///
  /// Device clocks can move backwards.
  ///
  /// If [cachedAt] appears to be in the future, the cache is treated as
  /// zero-age instead of returning a negative duration.
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
  /// Returns [Duration.zero] when the cache is already stale or expired.
  Duration remainingFreshness(DateTime cachedAt, {DateTime? now}) {
    final Duration cacheAge = age(cachedAt, now: now);

    if (cacheAge.compareTo(freshnessDuration) >= 0) {
      return Duration.zero;
    }

    return freshnessDuration - cacheAge;
  }

  // ===========================================================================
  // REMAINING USABLE LIFETIME
  // ===========================================================================

  /// Returns how much usable cache lifetime remains before expiration.
  Duration remainingUsableLifetime(DateTime cachedAt, {DateTime? now}) {
    final Duration cacheAge = age(cachedAt, now: now);

    if (cacheAge.compareTo(maximumStaleDuration) >= 0) {
      return Duration.zero;
    }

    return maximumStaleDuration - cacheAge;
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
