import 'package:flutter/foundation.dart';

/// ============================================================================
/// SARTHEE AI — HOME SECTION ENTITY
/// ============================================================================
///
/// Represents one logical content section displayed on the Sarthee AI Home
/// screen.
///
/// Examples:
///
/// • Recommended destinations
/// • Nearby places
/// • Cultural experiences
/// • Popular food
/// • Trending attractions
/// • AI recommendations
///
/// This entity belongs to the pure domain layer and therefore contains no:
///
/// • Flutter widgets
/// • Riverpod providers
/// • GoRouter logic
/// • JSON serialization
/// • API-specific implementation
/// • Database implementation
@immutable
class HomeSection {
  const HomeSection({
    required this.id,
    required this.title,
    required this.type,
    this.items = const <HomeSectionItem>[],
    this.subtitle,
    this.actionLabel,
    this.actionTarget,
    this.priority = 0,
    this.isEnabled = true,
    this.showWhenEmpty = false,
  }) : assert(priority >= 0, 'HomeSection priority cannot be negative.');

  // ===========================================================================
  // IDENTITY
  // ===========================================================================

  /// Stable section identifier.
  ///
  /// Examples:
  ///
  /// nearby
  /// recommended
  /// culture
  /// food
  final String id;

  /// Main user-visible section title.
  final String title;

  /// Determines the semantic purpose of this section.
  final HomeSectionType type;

  // ===========================================================================
  // CONTENT
  // ===========================================================================

  /// Content displayed inside this section.
  final List<HomeSectionItem> items;

  /// Optional supporting text displayed below the section title.
  final String? subtitle;

  // ===========================================================================
  // SECTION ACTION
  // ===========================================================================

  /// Optional CTA label.
  ///
  /// Example:
  ///
  /// "See all"
  final String? actionLabel;

  /// Navigation/application target associated with [actionLabel].
  ///
  /// The domain layer stores only the target identifier.
  ///
  /// It does not perform navigation.
  final String? actionTarget;

  // ===========================================================================
  // DISPLAY CONFIGURATION
  // ===========================================================================

  /// Ordering priority.
  ///
  /// Lower values should generally appear first.
  final int priority;

  /// Whether this section is enabled.
  final bool isEnabled;

  /// Whether the section should remain visible when no items are available.
  final bool showWhenEmpty;

  // ===========================================================================
  // DERIVED STATE
  // ===========================================================================

  bool get hasId => id.trim().isNotEmpty;

  bool get hasTitle => title.trim().isNotEmpty;

  bool get hasSubtitle => subtitle?.trim().isNotEmpty ?? false;

  bool get hasItems => items.isNotEmpty;

  bool get isEmpty => items.isEmpty;

  bool get hasAction => actionLabel?.trim().isNotEmpty ?? false;

  bool get hasActionTarget => actionTarget?.trim().isNotEmpty ?? false;

  /// Determines whether the section should be presented to the user.
  bool get isVisible {
    if (!isEnabled) {
      return false;
    }

    if (!hasTitle) {
      return false;
    }

    if (hasItems) {
      return true;
    }

    return showWhenEmpty;
  }

  /// Number of items contained by this section.
  int get itemCount => items.length;

  /// Only enabled section items.
  List<HomeSectionItem> get enabledItems {
    return List<HomeSectionItem>.unmodifiable(
      items.where((HomeSectionItem item) => item.isEnabled),
    );
  }

  /// Only visible section items.
  List<HomeSectionItem> get visibleItems {
    return List<HomeSectionItem>.unmodifiable(
      items.where((HomeSectionItem item) => item.isVisible),
    );
  }

  // ===========================================================================
  // LOOKUP
  // ===========================================================================

  /// Finds an item by stable ID.
  HomeSectionItem? itemById(String id) {
    final String normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final HomeSectionItem item in items) {
      if (item.id == normalizedId) {
        return item;
      }
    }

    return null;
  }

  // ===========================================================================
  // COPY
  // ===========================================================================

  HomeSection copyWith({
    String? id,
    String? title,
    HomeSectionType? type,
    List<HomeSectionItem>? items,
    String? subtitle,
    String? actionLabel,
    String? actionTarget,
    int? priority,
    bool? isEnabled,
    bool? showWhenEmpty,
    bool clearSubtitle = false,
    bool clearActionLabel = false,
    bool clearActionTarget = false,
  }) {
    return HomeSection(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      items: items ?? this.items,
      subtitle: clearSubtitle ? null : subtitle ?? this.subtitle,
      actionLabel: clearActionLabel ? null : actionLabel ?? this.actionLabel,
      actionTarget: clearActionTarget
          ? null
          : actionTarget ?? this.actionTarget,
      priority: priority ?? this.priority,
      isEnabled: isEnabled ?? this.isEnabled,
      showWhenEmpty: showWhenEmpty ?? this.showWhenEmpty,
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

    return other is HomeSection &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        listEquals(other.items, items) &&
        other.subtitle == subtitle &&
        other.actionLabel == actionLabel &&
        other.actionTarget == actionTarget &&
        other.priority == priority &&
        other.isEnabled == isEnabled &&
        other.showWhenEmpty == showWhenEmpty;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    Object.hashAll(items),
    subtitle,
    actionLabel,
    actionTarget,
    priority,
    isEnabled,
    showWhenEmpty,
  );

  @override
  String toString() {
    return 'HomeSection('
        'id: $id, '
        'title: $title, '
        'type: $type, '
        'items: ${items.length}, '
        'priority: $priority, '
        'isEnabled: $isEnabled'
        ')';
  }
}

/// ============================================================================
/// HOME SECTION TYPE
/// ============================================================================
///
/// Semantic categories supported by the Sarthee AI Home screen.
///
/// UI presentation should be selected based on this type rather than relying
/// on fragile title comparisons.
enum HomeSectionType {
  recommended,
  nearby,
  destinations,
  culture,
  food,
  hotels,
  experiences,
  trending,
  aiRecommendations,
  favorites,
  custom;

  bool get isRecommended => this == HomeSectionType.recommended;

  bool get isNearby => this == HomeSectionType.nearby;

  bool get isDestination => this == HomeSectionType.destinations;

  bool get isCulture => this == HomeSectionType.culture;

  bool get isFood => this == HomeSectionType.food;

  bool get isHotel => this == HomeSectionType.hotels;

  bool get isExperience => this == HomeSectionType.experiences;

  bool get isTrending => this == HomeSectionType.trending;

  bool get isAiRecommendation => this == HomeSectionType.aiRecommendations;

  bool get isFavorites => this == HomeSectionType.favorites;
}

/// ============================================================================
/// HOME SECTION ITEM
/// ============================================================================
///
/// Generic lightweight domain representation of a card/item displayed inside
/// a Home section.
///
/// More complex feature-specific information should continue to live in its
/// respective feature domain.
///
/// For example:
///
/// destinations/
/// food/
/// hotels/
/// culture/
///
/// Home should aggregate and reference these experiences rather than owning
/// their complete business models.
@immutable
class HomeSectionItem {
  const HomeSectionItem({
    required this.id,
    required this.title,
    required this.type,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.target,
    this.metadata = const <String, String>{},
    this.isEnabled = true,
  });

  /// Stable item identifier.
  final String id;

  /// Main display title.
  final String title;

  /// Semantic item category.
  final HomeSectionItemType type;

  /// Optional short supporting text.
  final String? subtitle;

  /// Optional longer description.
  final String? description;

  /// Optional remote/local image reference.
  final String? imageUrl;

  /// Optional application navigation target.
  ///
  /// Domain entities do not execute navigation.
  final String? target;

  /// Lightweight extensible metadata.
  ///
  /// Examples:
  ///
  /// distance → "1.2 km"
  /// rating   → "4.8"
  /// category → "Historical"
  ///
  /// Keep complex business data in the owning feature domain instead.
  final Map<String, String> metadata;

  /// Whether interaction with this item is allowed.
  final bool isEnabled;

  // ===========================================================================
  // DERIVED STATE
  // ===========================================================================

  bool get hasId => id.trim().isNotEmpty;

  bool get hasTitle => title.trim().isNotEmpty;

  bool get hasSubtitle => subtitle?.trim().isNotEmpty ?? false;

  bool get hasDescription => description?.trim().isNotEmpty ?? false;

  bool get hasImage => imageUrl?.trim().isNotEmpty ?? false;

  bool get hasTarget => target?.trim().isNotEmpty ?? false;

  bool get hasMetadata => metadata.isNotEmpty;

  /// Basic domain-level visibility validation.
  bool get isVisible => isEnabled && hasId && hasTitle;

  // ===========================================================================
  // METADATA
  // ===========================================================================

  String? metadataValue(String key) {
    final String normalizedKey = key.trim();

    if (normalizedKey.isEmpty) {
      return null;
    }

    final String? value = metadata[normalizedKey];

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value;
  }

  // ===========================================================================
  // COPY
  // ===========================================================================

  HomeSectionItem copyWith({
    String? id,
    String? title,
    HomeSectionItemType? type,
    String? subtitle,
    String? description,
    String? imageUrl,
    String? target,
    Map<String, String>? metadata,
    bool? isEnabled,
    bool clearSubtitle = false,
    bool clearDescription = false,
    bool clearImageUrl = false,
    bool clearTarget = false,
  }) {
    return HomeSectionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      subtitle: clearSubtitle ? null : subtitle ?? this.subtitle,
      description: clearDescription ? null : description ?? this.description,
      imageUrl: clearImageUrl ? null : imageUrl ?? this.imageUrl,
      target: clearTarget ? null : target ?? this.target,
      metadata: metadata ?? this.metadata,
      isEnabled: isEnabled ?? this.isEnabled,
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

    return other is HomeSectionItem &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.subtitle == subtitle &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.target == target &&
        mapEquals(other.metadata, metadata) &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    subtitle,
    description,
    imageUrl,
    target,
    Object.hashAll(
      metadata.entries.map(
        (MapEntry<String, String> entry) => Object.hash(entry.key, entry.value),
      ),
    ),
    isEnabled,
  );

  @override
  String toString() {
    return 'HomeSectionItem('
        'id: $id, '
        'title: $title, '
        'type: $type, '
        'isEnabled: $isEnabled'
        ')';
  }
}

/// Semantic category of an item presented by Home.
enum HomeSectionItemType {
  destination,
  place,
  culture,
  food,
  hotel,
  experience,
  event,
  aiRecommendation,
  custom,
}
