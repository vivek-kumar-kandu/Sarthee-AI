import '../models/home_content_model.dart';

/// ============================================================================
/// SARTHEE AI — HOME REMOTE DATA SOURCE
/// ============================================================================
///
/// Contract responsible for retrieving Home content from an authoritative
/// remote source.
///
/// Architecture:
///
/// HomeRepositoryImpl
///        ↓
/// HomeRemoteDataSource
///        ↓
/// Concrete implementation
///        ↓
/// REST API / Firebase / Cloud Function / Backend Service
///
/// Responsibilities:
///
/// • Retrieve fresh Home content
/// • Accept contextual request information
/// • Keep transport details outside repositories
/// • Provide a stable boundary between repository and network infrastructure
///
/// This abstraction intentionally contains no:
///
/// • Flutter widgets
/// • Riverpod state
/// • GoRouter logic
/// • cache implementation
/// • repository fallback policy
/// • domain use-case orchestration
abstract interface class HomeRemoteDataSource {
  /// Retrieves authoritative Home content.
  ///
  /// Implementations may use:
  ///
  /// • REST
  /// • GraphQL
  /// • Firebase
  /// • Cloud Functions
  /// • custom backend services
  ///
  /// Transport-specific failures should be converted into infrastructure
  /// exceptions by the concrete implementation.
  Future<HomeContentModel> getHomeContent({
    HomeRemoteRequest request = const HomeRemoteRequest(),
  });
}

/// ============================================================================
/// SARTHEE AI — HOME REMOTE REQUEST
/// ============================================================================
///
/// Transport-friendly contextual request used by [HomeRemoteDataSource].
///
/// This is deliberately separate from the domain's HomeContentRequest.
///
/// Why:
///
/// Domain:
///
/// HomeContentRequest
///        ↓
/// Repository
///
/// Data:
///
/// HomeRemoteRequest
///        ↓
/// RemoteDataSource
///
/// This prevents API/transport requirements from leaking into the domain.
class HomeRemoteRequest {
  const HomeRemoteRequest({
    this.locationName,
    this.latitude,
    this.longitude,
    this.locale,
    this.userId,
    this.forcePersonalization = false,
  }) : assert(
         latitude == null || (latitude >= -90.0 && latitude <= 90.0),
         'Latitude must be between -90 and 90.',
       ),
       assert(
         longitude == null || (longitude >= -180.0 && longitude <= 180.0),
         'Longitude must be between -180 and 180.',
       );

  // ===========================================================================
  // LOCATION
  // ===========================================================================

  final String? locationName;

  final double? latitude;

  final double? longitude;

  // ===========================================================================
  // CONTEXT
  // ===========================================================================

  final String? locale;

  final String? userId;

  final bool forcePersonalization;

  // ===========================================================================
  // DERIVED STATE
  // ===========================================================================

  /// True only when both geographic coordinates are available.
  bool get hasCoordinates {
    return latitude != null && longitude != null;
  }

  bool get hasLocationName {
    return locationName?.trim().isNotEmpty ?? false;
  }

  bool get hasLocale {
    return locale?.trim().isNotEmpty ?? false;
  }

  bool get hasUserId {
    return userId?.trim().isNotEmpty ?? false;
  }

  bool get hasLocationContext {
    return hasCoordinates || hasLocationName;
  }

  bool get hasUserContext {
    return hasUserId || forcePersonalization;
  }

  bool get isEmpty {
    return !hasLocationContext && !hasLocale && !hasUserContext;
  }

  // ===========================================================================
  // SERIALIZATION
  // ===========================================================================

  /// Converts the request into transport-safe query parameters.
  ///
  /// Null/blank values are omitted.
  Map<String, String> toQueryParameters() {
    final Map<String, String> parameters = <String, String>{};

    final String? normalizedLocation = _normalizeText(locationName);

    final String? normalizedLocale = _normalizeText(locale);

    final String? normalizedUserId = _normalizeText(userId);

    if (normalizedLocation != null) {
      parameters['location'] = normalizedLocation;
    }

    if (hasCoordinates) {
      parameters['latitude'] = latitude!.toString();
      parameters['longitude'] = longitude!.toString();
    }

    if (normalizedLocale != null) {
      parameters['locale'] = normalizedLocale;
    }

    if (normalizedUserId != null) {
      parameters['userId'] = normalizedUserId;
    }

    if (forcePersonalization) {
      parameters['personalized'] = 'true';
    }

    return Map<String, String>.unmodifiable(parameters);
  }

  /// Converts the request into a JSON-compatible payload.
  ///
  /// Useful when the future Home endpoint uses POST instead of GET.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    final String? normalizedLocation = _normalizeText(locationName);

    final String? normalizedLocale = _normalizeText(locale);

    final String? normalizedUserId = _normalizeText(userId);

    if (normalizedLocation != null) {
      json['locationName'] = normalizedLocation;
    }

    if (hasCoordinates) {
      json['latitude'] = latitude;
      json['longitude'] = longitude;
    }

    if (normalizedLocale != null) {
      json['locale'] = normalizedLocale;
    }

    if (normalizedUserId != null) {
      json['userId'] = normalizedUserId;
    }

    json['forcePersonalization'] = forcePersonalization;

    return json;
  }

  // ===========================================================================
  // COPY
  // ===========================================================================

  HomeRemoteRequest copyWith({
    String? locationName,
    double? latitude,
    double? longitude,
    String? locale,
    String? userId,
    bool? forcePersonalization,
    bool clearLocationName = false,
    bool clearCoordinates = false,
    bool clearLocale = false,
    bool clearUserId = false,
  }) {
    return HomeRemoteRequest(
      locationName: clearLocationName
          ? null
          : locationName ?? this.locationName,
      latitude: clearCoordinates ? null : latitude ?? this.latitude,
      longitude: clearCoordinates ? null : longitude ?? this.longitude,
      locale: clearLocale ? null : locale ?? this.locale,
      userId: clearUserId ? null : userId ?? this.userId,
      forcePersonalization: forcePersonalization ?? this.forcePersonalization,
    );
  }

  // ===========================================================================
  // NORMALIZATION
  // ===========================================================================

  static String? _normalizeText(String? value) {
    if (value == null) {
      return null;
    }

    final String normalized = value.trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  // ===========================================================================
  // VALUE SEMANTICS
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is HomeRemoteRequest &&
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
    return 'HomeRemoteRequest('
        'locationName: $locationName, '
        'latitude: $latitude, '
        'longitude: $longitude, '
        'locale: $locale, '
        'hasUserId: $hasUserId, '
        'forcePersonalization: $forcePersonalization'
        ')';
  }
}
