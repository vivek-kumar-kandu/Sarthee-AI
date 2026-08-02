import 'package:flutter/foundation.dart';

import 'home_action.dart';
import 'home_section.dart';

/// ============================================================================
/// SARTHEE AI — HOME CONTENT ENTITY
/// ============================================================================
///
/// Root domain entity representing all content required by the Home feature.
///
/// This entity is intentionally independent from:
///
/// • Flutter widgets
/// • Riverpod
/// • GoRouter
/// • REST / JSON
/// • Firebase
/// • Local storage
/// • API-specific response models
///
/// Data flow:
///
/// Remote / Local DataSource
///        ↓
/// HomeContentModel
///        ↓
/// HomeRepository
///        ↓
/// HomeContent
///        ↓
/// HomeController
///        ↓
/// HomePage
///
/// Keeping this entity infrastructure-independent allows the Home domain layer
/// to remain stable even if the backend or persistence implementation changes.
@immutable
class HomeContent {
  const HomeContent({
    required this.sections,
    required this.quickActions,
    this.greeting,
    this.subtitle,
    this.locationName,
    this.lastUpdatedAt,
  });

  /// Main sections displayed on the Home screen.
  ///
  /// Examples:
  ///
  /// • Recommended destinations
  /// • Nearby places
  /// • Cultural experiences
  /// • Popular food
  /// • Trending attractions
  final List<HomeSection> sections;

  /// Primary actions exposed near the top of the Home screen.
  ///
  /// Examples:
  ///
  /// • Explore
  /// • Ask Sarthee AI
  /// • Plan Trip
  /// • Nearby
  final List<HomeAction> quickActions;

  /// Optional personalized greeting.
  ///
  /// Example:
  ///
  /// "Good evening"
  final String? greeting;

  /// Optional supporting message.
  ///
  /// Example:
  ///
  /// "Where would you like to explore today?"
  final String? subtitle;

  /// Current human-readable location.
  ///
  /// This remains presentation-friendly and does not contain coordinates.
  final String? locationName;

  /// Timestamp describing when this Home content was last refreshed.
  final DateTime? lastUpdatedAt;

  // ===========================================================================
  // FACTORIES
  // ===========================================================================

  /// Empty Home content.
  ///
  /// Useful for:
  ///
  /// • initial controller state
  /// • offline fallback
  /// • tests
  /// • defensive repository behavior
  const HomeContent.empty()
    : sections = const <HomeSection>[],
      quickActions = const <HomeAction>[],
      greeting = null,
      subtitle = null,
      locationName = null,
      lastUpdatedAt = null;

  // ===========================================================================
  // DERIVED STATE
  // ===========================================================================

  /// Whether any Home section is available.
  bool get hasSections => sections.isNotEmpty;

  /// Whether quick actions are available.
  bool get hasQuickActions => quickActions.isNotEmpty;

  /// Whether the Home screen contains any meaningful content.
  bool get hasContent => hasSections || hasQuickActions;

  /// Whether a greeting can safely be displayed.
  bool get hasGreeting => _hasText(greeting);

  /// Whether supporting subtitle text is available.
  bool get hasSubtitle => _hasText(subtitle);

  /// Whether location information is available.
  bool get hasLocation => _hasText(locationName);

  /// Number of visible sections.
  int get sectionCount => sections.length;

  /// Number of available quick actions.
  int get quickActionCount => quickActions.length;

  /// Whether this represents the completely empty domain state.
  bool get isEmpty =>
      sections.isEmpty &&
      quickActions.isEmpty &&
      !hasGreeting &&
      !hasSubtitle &&
      !hasLocation;

  /// Returns only sections that contain displayable content.
  ///
  /// The actual visibility contract belongs to [HomeSection].
  List<HomeSection> get visibleSections {
    return List<HomeSection>.unmodifiable(
      sections.where((HomeSection section) => section.isVisible),
    );
  }

  /// Returns only enabled quick actions.
  List<HomeAction> get enabledQuickActions {
    return List<HomeAction>.unmodifiable(
      quickActions.where((HomeAction action) => action.isEnabled),
    );
  }

  // ===========================================================================
  // LOOKUPS
  // ===========================================================================

  /// Finds a section by its stable identifier.
  ///
  /// Returns null when no matching section exists.
  HomeSection? sectionById(String id) {
    final String normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final HomeSection section in sections) {
      if (section.id == normalizedId) {
        return section;
      }
    }

    return null;
  }

  /// Finds a quick action by its stable identifier.
  ///
  /// Returns null when no matching action exists.
  HomeAction? actionById(String id) {
    final String normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final HomeAction action in quickActions) {
      if (action.id == normalizedId) {
        return action;
      }
    }

    return null;
  }

  // ===========================================================================
  // COPY
  // ===========================================================================

  HomeContent copyWith({
    List<HomeSection>? sections,
    List<HomeAction>? quickActions,
    String? greeting,
    String? subtitle,
    String? locationName,
    DateTime? lastUpdatedAt,
    bool clearGreeting = false,
    bool clearSubtitle = false,
    bool clearLocation = false,
    bool clearLastUpdatedAt = false,
  }) {
    return HomeContent(
      sections: sections ?? this.sections,
      quickActions: quickActions ?? this.quickActions,
      greeting: clearGreeting ? null : greeting ?? this.greeting,
      subtitle: clearSubtitle ? null : subtitle ?? this.subtitle,
      locationName: clearLocation ? null : locationName ?? this.locationName,
      lastUpdatedAt: clearLastUpdatedAt
          ? null
          : lastUpdatedAt ?? this.lastUpdatedAt,
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

    return other is HomeContent &&
        listEquals(other.sections, sections) &&
        listEquals(other.quickActions, quickActions) &&
        other.greeting == greeting &&
        other.subtitle == subtitle &&
        other.locationName == locationName &&
        other.lastUpdatedAt == lastUpdatedAt;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(sections),
    Object.hashAll(quickActions),
    greeting,
    subtitle,
    locationName,
    lastUpdatedAt,
  );

  @override
  String toString() {
    return 'HomeContent('
        'sections: ${sections.length}, '
        'quickActions: ${quickActions.length}, '
        'greeting: $greeting, '
        'subtitle: $subtitle, '
        'locationName: $locationName, '
        'lastUpdatedAt: $lastUpdatedAt'
        ')';
  }

  // ===========================================================================
  // INTERNAL HELPERS
  // ===========================================================================

  static bool _hasText(String? value) {
    return value?.trim().isNotEmpty ?? false;
  }
}
