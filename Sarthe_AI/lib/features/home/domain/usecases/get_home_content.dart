import '../entities/home_action.dart';
import '../entities/home_content.dart';
import '../entities/home_section.dart';
import '../repositories/home_repository.dart';

/// ============================================================================
/// SARTHEE AI — GET HOME CONTENT USE CASE
/// ============================================================================
///
/// Domain use case responsible for retrieving the Sarthee AI Home experience.
///
/// Architecture:
///
/// HomeController
///      ↓
/// GetHomeContent
///      ↓
/// HomeRepository
///      ↓
/// HomeRepositoryImpl
///      ↓
/// Local / Remote DataSources
///
/// Responsibilities:
///
/// • Provide a stable domain entry point for Home content
/// • Normalize contextual request parameters
/// • Protect against incomplete coordinate pairs
/// • Normalize locale identifiers
/// • Delegate retrieval strategy to HomeRepository
/// • Produce deterministic section/action ordering
/// • Defensively expose immutable collections
/// • Support cached/offline Home restoration
///
/// This use case intentionally contains no:
///
/// • Flutter widgets
/// • Riverpod state
/// • GoRouter logic
/// • HTTP implementation
/// • JSON serialization
/// • Database/cache implementation
class GetHomeContent {
  const GetHomeContent({required this.repository});

  /// Repository abstraction used by this use case.
  ///
  /// The concrete implementation remains hidden behind [HomeRepository],
  /// keeping the domain layer independent from APIs, local persistence,
  /// caching mechanisms, and other infrastructure concerns.
  final HomeRepository repository;

  // ===========================================================================
  // EXECUTION
  // ===========================================================================

  /// Retrieves Home content using the repository's normal loading strategy.
  ///
  /// Depending on the repository implementation, this may return:
  ///
  /// • fresh remote content
  /// • valid cached content
  /// • offline fallback content
  ///
  /// Example:
  ///
  /// ```dart
  /// final HomeContent content = await getHomeContent(
  ///   const HomeContentRequest(
  ///     locationName: 'Delhi',
  ///     locale: 'en-IN',
  ///   ),
  /// );
  /// ```
  Future<HomeContent> call([
    HomeContentRequest request = const HomeContentRequest(),
  ]) async {
    final HomeContentRequest normalizedRequest = _normalizeRequest(request);

    final HomeContent content = await repository.getHomeContent(
      request: normalizedRequest,
    );

    return _normalizeContent(content);
  }

  // ===========================================================================
  // CACHE ACCESS
  // ===========================================================================

  /// Retrieves cached Home content without requiring network access.
  ///
  /// Useful for:
  ///
  /// • fast application startup
  /// • offline restoration
  /// • stale-while-revalidate flows
  /// • optimistic Home rendering
  ///
  /// Returns null when no usable cached Home content exists.
  Future<HomeContent?> cached() async {
    final HomeContent? content = await repository.getCachedHomeContent();

    if (content == null) {
      return null;
    }

    return _normalizeContent(content);
  }

  // ===========================================================================
  // REQUEST NORMALIZATION
  // ===========================================================================

  /// Sanitizes contextual request values before crossing the repository
  /// boundary.
  ///
  /// [HomeContentRequest] already validates coordinate ranges.
  ///
  /// This method additionally:
  ///
  /// • trims textual values
  /// • converts blank strings to null
  /// • normalizes locale identifiers
  /// • rejects incomplete coordinate pairs
  HomeContentRequest _normalizeRequest(HomeContentRequest request) {
    final String? locationName = _normalizeOptionalText(request.locationName);

    final String? locale = _normalizeLocale(request.locale);

    final String? userId = _normalizeOptionalText(request.userId);

    // Coordinates are useful only when latitude and longitude are both
    // available.
    //
    // Partial coordinates are discarded to prevent downstream data sources
    // from interpreting incomplete geographic information as a valid request.
    final bool hasCompleteCoordinates = request.hasCoordinates;

    return HomeContentRequest(
      locationName: locationName,
      latitude: hasCompleteCoordinates ? request.latitude : null,
      longitude: hasCompleteCoordinates ? request.longitude : null,
      locale: locale,
      userId: userId,
      forcePersonalization: request.forcePersonalization,
    );
  }

  // ===========================================================================
  // CONTENT NORMALIZATION
  // ===========================================================================

  /// Produces deterministic and presentation-safe Home content.
  ///
  /// Sections and quick actions are:
  ///
  /// • defensively copied
  /// • sorted deterministically
  /// • exposed as unmodifiable collections
  ///
  /// This prevents presentation code from accidentally mutating repository
  /// output.
  HomeContent _normalizeContent(HomeContent content) {
    final List<HomeSection> sections = List<HomeSection>.of(content.sections)
      ..sort(_compareSections);

    final List<HomeAction> quickActions = List<HomeAction>.of(
      content.quickActions,
    )..sort(_compareActions);

    return content.copyWith(
      sections: List<HomeSection>.unmodifiable(sections),
      quickActions: List<HomeAction>.unmodifiable(quickActions),
    );
  }

  // ===========================================================================
  // SECTION ORDERING
  // ===========================================================================

  /// Provides deterministic ordering for Home sections.
  ///
  /// Ordering:
  ///
  /// 1. priority
  /// 2. stable ID
  ///
  /// The ID acts as a secondary key so equal-priority sections never depend on
  /// arbitrary API/cache ordering.
  int _compareSections(HomeSection first, HomeSection second) {
    final int priorityComparison = first.priority.compareTo(second.priority);

    if (priorityComparison != 0) {
      return priorityComparison;
    }

    return first.id.compareTo(second.id);
  }

  // ===========================================================================
  // ACTION ORDERING
  // ===========================================================================

  /// Provides deterministic ordering for Home quick actions.
  ///
  /// Ordering:
  ///
  /// 1. priority
  /// 2. stable ID
  int _compareActions(HomeAction first, HomeAction second) {
    final int priorityComparison = first.priority.compareTo(second.priority);

    if (priorityComparison != 0) {
      return priorityComparison;
    }

    return first.id.compareTo(second.id);
  }

  // ===========================================================================
  // TEXT NORMALIZATION
  // ===========================================================================

  /// Trims optional text and converts blank values to null.
  String? _normalizeOptionalText(String? value) {
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
  // LOCALE NORMALIZATION
  // ===========================================================================

  /// Normalizes common locale representations.
  ///
  /// Examples:
  ///
  /// ```text
  /// EN          → en
  /// HI          → hi
  /// en_us       → en-US
  /// hi_in       → hi-IN
  /// zh_hans     → zh-Hans
  /// zh_hans_cn  → zh-Hans-CN
  /// ```
  ///
  /// Supported handling includes:
  ///
  /// • language subtags
  /// • script subtags
  /// • alphabetic region subtags
  /// • numeric region subtags
  /// • additional variant subtags
  String? _normalizeLocale(String? locale) {
    final String? normalized = _normalizeOptionalText(locale);

    if (normalized == null) {
      return null;
    }

    final List<String> parts = normalized
        .replaceAll('_', '-')
        .split('-')
        .map((String part) => part.trim())
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return null;
    }

    final List<String> normalizedParts = <String>[parts.first.toLowerCase()];

    for (int index = 1; index < parts.length; index++) {
      final String part = parts[index];

      // -----------------------------------------------------------------------
      // SCRIPT
      // -----------------------------------------------------------------------
      //
      // ISO 15924 examples:
      //
      // Latn
      // Deva
      // Hans
      // Hant

      if (_looksLikeScript(part)) {
        normalizedParts.add(_normalizeScript(part));

        continue;
      }

      // -----------------------------------------------------------------------
      // REGION
      // -----------------------------------------------------------------------
      //
      // Examples:
      //
      // IN
      // US
      // GB
      // 001
      // 419

      if (_looksLikeRegion(part)) {
        normalizedParts.add(part.toUpperCase());

        continue;
      }

      // -----------------------------------------------------------------------
      // OTHER / VARIANT SUBTAG
      // -----------------------------------------------------------------------

      normalizedParts.add(part.toLowerCase());
    }

    return normalizedParts.join('-');
  }

  // ===========================================================================
  // LOCALE HELPERS
  // ===========================================================================

  /// Returns true when [value] resembles an ISO 15924 script identifier.
  bool _looksLikeScript(String value) {
    return value.length == 4 && _containsOnlyLetters(value);
  }

  /// Returns true when [value] resembles a region identifier.
  ///
  /// Supports:
  ///
  /// • ISO 3166 alpha-2 regions
  /// • UN M49 three-digit regions
  bool _looksLikeRegion(String value) {
    if (value.length == 2) {
      return _containsOnlyLetters(value);
    }

    if (value.length == 3) {
      return _containsOnlyDigits(value);
    }

    return false;
  }

  /// Converts a script identifier to title case.
  ///
  /// Example:
  ///
  /// ```text
  /// hans → Hans
  /// DEVA → Deva
  /// ```
  String _normalizeScript(String value) {
    return '${value[0].toUpperCase()}'
        '${value.substring(1).toLowerCase()}';
  }

  /// Checks whether every character in [value] is an ASCII letter.
  bool _containsOnlyLetters(String value) {
    if (value.isEmpty) {
      return false;
    }

    for (final int codeUnit in value.codeUnits) {
      final bool isUppercase = codeUnit >= 65 && codeUnit <= 90;

      final bool isLowercase = codeUnit >= 97 && codeUnit <= 122;

      if (!isUppercase && !isLowercase) {
        return false;
      }
    }

    return true;
  }

  /// Checks whether every character in [value] is an ASCII digit.
  bool _containsOnlyDigits(String value) {
    if (value.isEmpty) {
      return false;
    }

    for (final int codeUnit in value.codeUnits) {
      if (codeUnit < 48 || codeUnit > 57) {
        return false;
      }
    }

    return true;
  }
}
