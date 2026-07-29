import '../entities/home_content.dart';

/// ============================================================================
/// SARTHEE AI — HOME REPOSITORY CONTRACT
/// ============================================================================
///
/// Domain-level contract for retrieving Sarthee AI Home content.
///
/// The repository defines WHAT the Home feature needs without knowing HOW
/// that data is obtained.
///
/// Possible implementations may use:
///
/// • REST APIs
/// • Firebase
/// • Local cache
/// • SQLite / Hive / SharedPreferences
/// • Mock data
/// • Offline-first strategies
///
/// Architecture:
///
/// HomeController
///      ↓
/// Use Case
///      ↓
/// HomeRepository
///      ↓
/// HomeRepositoryImpl
///      ↓
/// Local / Remote DataSources
///
/// The domain layer depends only on this abstraction.
/// Infrastructure details remain inside the data layer.
abstract interface class HomeRepository {
  /// Retrieves Home content.
  ///
  /// Implementations may choose between:
  ///
  /// • cached content
  /// • remote content
  /// • offline fallback
  ///
  /// depending on application state and caching strategy.
  Future<HomeContent> getHomeContent({
    HomeContentRequest request = const HomeContentRequest(),
  });

  /// Forces Home content to be refreshed from the authoritative source.
  ///
  /// A successful refresh should normally update any configured cache before
  /// returning the latest domain entity.
  Future<HomeContent> refreshHomeContent({
    HomeContentRequest request = const HomeContentRequest(),
  });

  /// Returns cached Home content when available.
  ///
  /// This operation must not require network access.
  ///
  /// Null indicates that no usable cached content currently exists.
  Future<HomeContent?> getCachedHomeContent();

  /// Removes persisted/cached Home content.
  ///
  /// Useful for:
  ///
  /// • logout
  /// • account switching
  /// • cache invalidation
  /// • corrupted-cache recovery
  Future<void> clearHomeCache();
}

/// ============================================================================
/// HOME CONTENT REQUEST
/// ============================================================================
///
/// Domain-level query describing which Home experience should be loaded.
///
/// This avoids passing infrastructure-specific API parameters directly into
/// use cases or presentation code.
///
/// Example:
///
/// HomeContentRequest(
///   locationName: 'Delhi',
///   latitude: 28.6139,
///   longitude: 77.2090,
///   locale: 'en',
/// )
///
/// The data layer is responsible for converting this object into API query
/// parameters, database queries, Firebase requests, etc.
class HomeContentRequest {
  const HomeContentRequest({
    this.locationName,
    this.latitude,
    this.longitude,
    this.locale,
    this.userId,
    this.forcePersonalization = false,
  }) : assert(
         latitude == null || (latitude >= -90 && latitude <= 90),
         'Latitude must be between -90 and 90.',
       ),
       assert(
         longitude == null || (longitude >= -180 && longitude <= 180),
         'Longitude must be between -180 and 180.',
       );

  // ===========================================================================
  // LOCATION
  // ===========================================================================

  /// Human-readable location.
  ///
  /// Example:
  ///
  /// Delhi
  /// Mathura
  /// Vrindavan
  final String? locationName;

  /// Geographic latitude.
  final double? latitude;

  /// Geographic longitude.
  final double? longitude;

  // ===========================================================================
  // PERSONALIZATION
  // ===========================================================================

  /// Preferred application locale.
  ///
  /// Examples:
  ///
  /// en
  /// hi
  final String? locale;

  /// Optional application user identifier used for personalized content.
  ///
  /// Authentication itself does not belong to this repository.
  final String? userId;

  /// Requests personalized content even when the repository would normally
  /// return generic/cached Home data.
  final bool forcePersonalization;

  // ===========================================================================
  // DERIVED STATE
  // ===========================================================================

  bool get hasLocationName => _hasText(locationName);

  bool get hasLatitude => latitude != null;

  bool get hasLongitude => longitude != null;

  /// True only when both coordinates are available.
  bool get hasCoordinates => hasLatitude && hasLongitude;

  /// Detects an incomplete coordinate pair.
  ///
  /// This can be useful for telemetry or defensive handling in the data layer.
  bool get hasPartialCoordinates => hasLatitude != hasLongitude;

  bool get hasLocale => _hasText(locale);

  bool get hasUserId => _hasText(userId);

  bool get canPersonalize => hasUserId || forcePersonalization;

  /// Whether the request contains no contextual parameters.
  bool get isDefault =>
      !hasLocationName &&
      !hasCoordinates &&
      !hasPartialCoordinates &&
      !hasLocale &&
      !hasUserId &&
      !forcePersonalization;

  // ===========================================================================
  // COPY
  // ===========================================================================

  HomeContentRequest copyWith({
    String? locationName,
    double? latitude,
    double? longitude,
    String? locale,
    String? userId,
    bool? forcePersonalization,
    bool clearLocationName = false,
    bool clearLatitude = false,
    bool clearLongitude = false,
    bool clearLocale = false,
    bool clearUserId = false,
  }) {
    return HomeContentRequest(
      locationName: clearLocationName
          ? null
          : locationName ?? this.locationName,
      latitude: clearLatitude ? null : latitude ?? this.latitude,
      longitude: clearLongitude ? null : longitude ?? this.longitude,
      locale: clearLocale ? null : locale ?? this.locale,
      userId: clearUserId ? null : userId ?? this.userId,
      forcePersonalization: forcePersonalization ?? this.forcePersonalization,
    );
  }

  // ===========================================================================
  // VALUE SEMANTICS
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is HomeContentRequest &&
        other.locationName == locationName &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.locale == locale &&
        other.userId == userId &&
        other.forcePersonalization == forcePersonalization;
  }

  @override
  int get hashCode => Object.hash(
    locationName,
    latitude,
    longitude,
    locale,
    userId,
    forcePersonalization,
  );

  @override
  String toString() {
    return 'HomeContentRequest('
        'locationName: $locationName, '
        'hasCoordinates: $hasCoordinates, '
        'locale: $locale, '
        'hasUserId: $hasUserId, '
        'forcePersonalization: $forcePersonalization'
        ')';
  }

  // ===========================================================================
  // INTERNAL
  // ===========================================================================

  static bool _hasText(String? value) {
    return value?.trim().isNotEmpty ?? false;
  }
}
