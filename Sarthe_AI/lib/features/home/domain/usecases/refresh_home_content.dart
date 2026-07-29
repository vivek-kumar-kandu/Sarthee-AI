import '../entities/home_action.dart';
import '../entities/home_content.dart';
import '../entities/home_section.dart';
import '../repositories/home_repository.dart';

/// ============================================================================
/// SARTHEE AI — REFRESH HOME CONTENT USE CASE
/// ============================================================================
///
/// Forces the Sarthee AI Home experience to refresh through the domain
/// repository.
///
/// Architecture:
///
/// HomeController
///      ↓
/// RefreshHomeContent
///      ↓
/// HomeRepository
///      ↓
/// HomeRepositoryImpl
///      ↓
/// Remote DataSource
///      ↓
/// Cache update
///
/// Typical usage:
///
/// • Pull-to-refresh
/// • Manual refresh
/// • Location change
/// • User/session change
/// • Personalization refresh
/// • Retry after a recoverable loading failure
///
/// Unlike the normal Home loading flow, this use case explicitly requests
/// fresh content from the repository's authoritative source.
///
/// Responsibilities:
///
/// • Normalize request parameters
/// • Protect against incomplete coordinate pairs
/// • Normalize locale identifiers
/// • Request authoritative Home content
/// • Normalize returned collections
/// • Provide deterministic ordering
/// • Expose immutable section/action collections
///
/// This use case intentionally contains no:
///
/// • Flutter widgets
/// • Riverpod state
/// • GoRouter logic
/// • HTTP implementation
/// • JSON serialization
/// • Local-storage implementation
/// • Cache implementation
///
/// Infrastructure concerns remain behind [HomeRepository].
class RefreshHomeContent {
  const RefreshHomeContent({required this.repository});

  // ===========================================================================
  // DEPENDENCIES
  // ===========================================================================

  /// Repository abstraction used to refresh Home content.
  ///
  /// Keeping the dependency typed as [HomeRepository] ensures the domain
  /// layer remains independent from concrete API, database, cache, and
  /// persistence implementations.
  final HomeRepository repository;

  // ===========================================================================
  // EXECUTION
  // ===========================================================================

  /// Forces Home content to refresh.
  ///
  /// The repository implementation is responsible for:
  ///
  /// • requesting authoritative/fresh content
  /// • updating the configured cache
  /// • applying connectivity/error policy
  /// • converting data-layer models into domain entities
  ///
  /// This use case additionally:
  ///
  /// • sanitizes contextual request values
  /// • validates coordinate completeness
  /// • normalizes locale identifiers
  /// • guarantees deterministic collection ordering
  /// • returns immutable collection views
  Future<HomeContent> call([
    HomeContentRequest request = const HomeContentRequest(),
  ]) async {
    final HomeContentRequest normalizedRequest = _normalizeRequest(request);

    final HomeContent content = await repository.refreshHomeContent(
      request: normalizedRequest,
    );

    return _normalizeContent(content);
  }

  // ===========================================================================
  // REQUEST NORMALIZATION
  // ===========================================================================

  /// Normalizes contextual information before forwarding it to the repository.
  ///
  /// Rules:
  ///
  /// • blank strings become null
  /// • surrounding whitespace is removed
  /// • locale identifiers are normalized
  /// • incomplete coordinate pairs are discarded
  ///
  /// Coordinate range validation should remain owned by
  /// [HomeContentRequest].
  HomeContentRequest _normalizeRequest(HomeContentRequest request) {
    final String? locationName = _normalizeOptionalText(request.locationName);

    final String? locale = _normalizeLocale(request.locale);

    final String? userId = _normalizeOptionalText(request.userId);

    // Geographic context is valid only when latitude and longitude are both
    // available.
    //
    // Sending only one coordinate could result in ambiguous downstream
    // behavior, therefore partial coordinate information is discarded.
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
  /// Repository implementations are free to retrieve content from different
  /// infrastructure sources. This normalization step guarantees that the
  /// presentation layer receives predictable ordering regardless of whether
  /// the data came from:
  ///
  /// • remote API
  /// • cache
  /// • fallback storage
  /// • development fixtures
  ///
  /// Sections and quick actions are defensively copied before sorting so the
  /// original repository-owned collections are never mutated.
  HomeContent _normalizeContent(HomeContent content) {
    final List<HomeSection> sections = List<HomeSection>.of(
      content.sections,
      growable: true,
    )..sort(_compareSections);

    final List<HomeAction> quickActions = List<HomeAction>.of(
      content.quickActions,
      growable: true,
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
  /// 2. normalized title
  /// 3. stable ID
  ///
  /// The additional comparison keys prevent equal-priority sections from
  /// depending on arbitrary network/cache ordering.
  int _compareSections(HomeSection first, HomeSection second) {
    final int priorityComparison = first.priority.compareTo(second.priority);

    if (priorityComparison != 0) {
      return priorityComparison;
    }

    final int titleComparison = _compareNormalizedText(
      first.title,
      second.title,
    );

    if (titleComparison != 0) {
      return titleComparison;
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
  /// 2. normalized label
  /// 3. stable ID
  int _compareActions(HomeAction first, HomeAction second) {
    final int priorityComparison = first.priority.compareTo(second.priority);

    if (priorityComparison != 0) {
      return priorityComparison;
    }

    final int labelComparison = _compareNormalizedText(
      first.label,
      second.label,
    );

    if (labelComparison != 0) {
      return labelComparison;
    }

    return first.id.compareTo(second.id);
  }

  // ===========================================================================
  // TEXT ORDERING
  // ===========================================================================

  /// Performs deterministic case-insensitive text comparison.
  ///
  /// A second comparison using the original value is used as a tie-breaker so
  /// values differing only by character case still have stable ordering.
  int _compareNormalizedText(String first, String second) {
    final String normalizedFirst = first.trim().toLowerCase();
    final String normalizedSecond = second.trim().toLowerCase();

    final int normalizedComparison = normalizedFirst.compareTo(
      normalizedSecond,
    );

    if (normalizedComparison != 0) {
      return normalizedComparison;
    }

    return first.compareTo(second);
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

  /// Normalizes commonly used locale representations.
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
  /// en_001      → en-001
  /// ```
  ///
  /// Locale subtags are normalized according to their common representation:
  ///
  /// • language → lowercase
  /// • script → TitleCase
  /// • alpha region → UPPERCASE
  /// • numeric region → unchanged
  /// • variants → lowercase
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
      // ISO 3166 alpha-2:
      //
      // IN
      // US
      // GB
      //
      // UN M49 numeric:
      //
      // 001
      // 419

      if (_looksLikeRegion(part)) {
        normalizedParts.add(_normalizeRegion(part));

        continue;
      }

      // -----------------------------------------------------------------------
      // VARIANT / OTHER SUBTAG
      // -----------------------------------------------------------------------

      normalizedParts.add(part.toLowerCase());
    }

    return normalizedParts.join('-');
  }

  // ===========================================================================
  // LOCALE — SCRIPT
  // ===========================================================================

  /// Returns true when [value] resembles an ISO 15924 script identifier.
  bool _looksLikeScript(String value) {
    return value.length == 4 && _containsOnlyLetters(value);
  }

  /// Converts a script identifier to its conventional title-case form.
  ///
  /// Examples:
  ///
  /// ```text
  /// hans → Hans
  /// HANS → Hans
  /// deva → Deva
  /// ```
  String _normalizeScript(String value) {
    return '${value[0].toUpperCase()}'
        '${value.substring(1).toLowerCase()}';
  }

  // ===========================================================================
  // LOCALE — REGION
  // ===========================================================================

  /// Returns true when [value] resembles a valid region subtag.
  ///
  /// Supported forms:
  ///
  /// • two alphabetic characters
  /// • three numeric characters
  bool _looksLikeRegion(String value) {
    if (value.length == 2) {
      return _containsOnlyLetters(value);
    }

    if (value.length == 3) {
      return _containsOnlyDigits(value);
    }

    return false;
  }

  /// Normalizes region identifiers.
  ///
  /// Alphabetic regions become uppercase while numeric UN M49 identifiers
  /// remain unchanged.
  String _normalizeRegion(String value) {
    if (_containsOnlyDigits(value)) {
      return value;
    }

    return value.toUpperCase();
  }

  // ===========================================================================
  // CHARACTER VALIDATION
  // ===========================================================================

  /// Returns true when every character in [value] is an ASCII letter.
  ///
  /// Locale identifiers are ASCII-based, therefore this deliberately avoids
  /// locale-sensitive or Unicode text transformations.
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

  /// Returns true when every character in [value] is an ASCII digit.
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
