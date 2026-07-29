import 'package:flutter/foundation.dart';

/// ============================================================================
/// SARTHEE AI — HOME ACTION ENTITY
/// ============================================================================
///
/// Represents a quick action exposed by the Sarthee AI Home experience.
///
/// Examples:
///
/// • Explore destinations
/// • Ask Sarthee AI
/// • Plan a trip
/// • Discover nearby places
/// • Open favorites
/// • Explore food
/// • Discover culture
///
/// This is a pure domain entity.
///
/// It intentionally contains no dependency on:
///
/// • Flutter widgets / IconData
/// • GoRouter
/// • Riverpod
/// • Navigator
/// • REST / JSON
/// • Firebase
/// • Platform-specific APIs
///
/// Navigation flow:
///
/// HomeAction
///      ↓
/// HomeController / HomePage
///      ↓
/// action callback
///      ↓
/// App routing layer
///
/// The entity describes WHAT an action represents.
/// It does not decide HOW navigation is performed.
@immutable
class HomeAction {
  const HomeAction({
    required this.id,
    required this.label,
    required this.type,
    this.subtitle,
    this.target,
    this.iconKey,
    this.badgeLabel,
    this.priority = 0,
    this.isEnabled = true,
    this.requiresAuthentication = false,
    this.metadata = const <String, String>{},
  }) : assert(priority >= 0, 'HomeAction priority cannot be negative.');

  // ===========================================================================
  // IDENTITY
  // ===========================================================================

  /// Stable identifier for this action.
  ///
  /// Examples:
  ///
  /// explore
  /// ask-ai
  /// plan-trip
  /// nearby
  /// favorites
  final String id;

  /// Primary user-visible action label.
  ///
  /// Example:
  ///
  /// "Ask Sarthee AI"
  final String label;

  /// Semantic action category.
  ///
  /// Presentation should use this instead of comparing user-visible labels.
  final HomeActionType type;

  // ===========================================================================
  // PRESENTATION METADATA
  // ===========================================================================

  /// Optional supporting text.
  ///
  /// Example:
  ///
  /// "Get personalized travel guidance"
  final String? subtitle;

  /// Logical navigation/action target.
  ///
  /// Examples:
  ///
  /// /explore
  /// /ai
  /// /trips
  ///
  /// The domain layer stores this value but never performs navigation.
  final String? target;

  /// Platform-independent icon identifier.
  ///
  /// Example:
  ///
  /// travel_explore
  /// auto_awesome
  /// route
  /// near_me
  ///
  /// The presentation layer is responsible for converting this into IconData.
  final String? iconKey;

  /// Optional badge.
  ///
  /// Examples:
  ///
  /// NEW
  /// 3
  /// AI
  final String? badgeLabel;

  // ===========================================================================
  // BEHAVIOR
  // ===========================================================================

  /// Lower values should generally be displayed first.
  final int priority;

  /// Whether this action can currently be selected.
  final bool isEnabled;

  /// Whether the action requires an authenticated session.
  ///
  /// Authentication enforcement belongs to routing/application layers.
  final bool requiresAuthentication;

  /// Lightweight extensible action metadata.
  ///
  /// Avoid storing complex feature business state here.
  final Map<String, String> metadata;

  // ===========================================================================
  // DERIVED STATE
  // ===========================================================================

  bool get hasId => id.trim().isNotEmpty;

  bool get hasLabel => label.trim().isNotEmpty;

  bool get hasSubtitle => subtitle?.trim().isNotEmpty ?? false;

  bool get hasTarget => target?.trim().isNotEmpty ?? false;

  bool get hasIcon => iconKey?.trim().isNotEmpty ?? false;

  bool get hasBadge => badgeLabel?.trim().isNotEmpty ?? false;

  bool get hasMetadata => metadata.isNotEmpty;

  /// Whether this action contains enough information to be displayed.
  bool get isVisible => hasId && hasLabel;

  /// Whether the action may be interacted with.
  bool get isInteractive => isVisible && isEnabled;

  /// Whether this action represents Sarthee AI assistant access.
  bool get isAiAction => type.isAi;

  /// Whether this action represents trip planning.
  bool get isTripPlanningAction => type.isTripPlanner;

  // ===========================================================================
  // METADATA
  // ===========================================================================

  /// Returns normalized metadata for [key].
  ///
  /// Null is returned when:
  ///
  /// • key is empty
  /// • key does not exist
  /// • stored value is empty
  String? metadataValue(String key) {
    final String normalizedKey = key.trim();

    if (normalizedKey.isEmpty) {
      return null;
    }

    final String? value = metadata[normalizedKey];

    if (value == null) {
      return null;
    }

    final String normalizedValue = value.trim();

    return normalizedValue.isEmpty ? null : normalizedValue;
  }

  // ===========================================================================
  // COPY
  // ===========================================================================

  HomeAction copyWith({
    String? id,
    String? label,
    HomeActionType? type,
    String? subtitle,
    String? target,
    String? iconKey,
    String? badgeLabel,
    int? priority,
    bool? isEnabled,
    bool? requiresAuthentication,
    Map<String, String>? metadata,
    bool clearSubtitle = false,
    bool clearTarget = false,
    bool clearIconKey = false,
    bool clearBadgeLabel = false,
  }) {
    return HomeAction(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      subtitle: clearSubtitle ? null : subtitle ?? this.subtitle,
      target: clearTarget ? null : target ?? this.target,
      iconKey: clearIconKey ? null : iconKey ?? this.iconKey,
      badgeLabel: clearBadgeLabel ? null : badgeLabel ?? this.badgeLabel,
      priority: priority ?? this.priority,
      isEnabled: isEnabled ?? this.isEnabled,
      requiresAuthentication:
          requiresAuthentication ?? this.requiresAuthentication,
      metadata: metadata ?? this.metadata,
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

    return other is HomeAction &&
        other.id == id &&
        other.label == label &&
        other.type == type &&
        other.subtitle == subtitle &&
        other.target == target &&
        other.iconKey == iconKey &&
        other.badgeLabel == badgeLabel &&
        other.priority == priority &&
        other.isEnabled == isEnabled &&
        other.requiresAuthentication == requiresAuthentication &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    type,
    subtitle,
    target,
    iconKey,
    badgeLabel,
    priority,
    isEnabled,
    requiresAuthentication,
    _metadataHash(metadata),
  );

  @override
  String toString() {
    return 'HomeAction('
        'id: $id, '
        'label: $label, '
        'type: $type, '
        'priority: $priority, '
        'isEnabled: $isEnabled, '
        'requiresAuthentication: $requiresAuthentication'
        ')';
  }

  // ===========================================================================
  // INTERNAL HELPERS
  // ===========================================================================

  /// Produces deterministic hash semantics for metadata regardless of map
  /// insertion order.
  static int _metadataHash(Map<String, String> metadata) {
    if (metadata.isEmpty) {
      return 0;
    }

    final List<MapEntry<String, String>> entries =
        metadata.entries.toList(growable: false)..sort(
          (MapEntry<String, String> a, MapEntry<String, String> b) =>
              a.key.compareTo(b.key),
        );

    return Object.hashAll(
      entries.map(
        (MapEntry<String, String> entry) => Object.hash(entry.key, entry.value),
      ),
    );
  }
}

/// ============================================================================
/// HOME ACTION TYPE
/// ============================================================================
///
/// Stable semantic categories for Home quick actions.
///
/// Never use display labels such as "Explore" or "Nearby" for application
/// behavior because those labels can change due to localization or UX updates.
enum HomeActionType {
  /// Main destination/place discovery experience.
  explore,

  /// Sarthee AI conversational assistant.
  aiAssistant,

  /// Trip planning experience.
  tripPlanner,

  /// Location-aware nearby discovery.
  nearby,

  /// Saved/favorite experiences.
  favorites,

  /// Food discovery.
  food,

  /// Cultural discovery.
  culture,

  /// Hotel discovery.
  hotels,

  /// Weather experience.
  weather,

  /// User profile.
  profile,

  /// Notifications.
  notifications,

  /// Extensible backend/config-driven action.
  custom;

  // ===========================================================================
  // CONVENIENCE
  // ===========================================================================

  bool get isExplore => this == HomeActionType.explore;

  bool get isAi => this == HomeActionType.aiAssistant;

  bool get isTripPlanner => this == HomeActionType.tripPlanner;

  bool get isNearby => this == HomeActionType.nearby;

  bool get isFavorites => this == HomeActionType.favorites;

  bool get isFood => this == HomeActionType.food;

  bool get isCulture => this == HomeActionType.culture;

  bool get isHotels => this == HomeActionType.hotels;

  bool get isWeather => this == HomeActionType.weather;

  bool get isProfile => this == HomeActionType.profile;

  bool get isNotifications => this == HomeActionType.notifications;

  bool get isCustom => this == HomeActionType.custom;
}
