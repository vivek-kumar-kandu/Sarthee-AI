import '../../domain/entities/home_section.dart';

/// ============================================================================
/// SARTHEE AI — HOME SECTION MODEL
/// ============================================================================
///
/// Data-layer representation of [HomeSection].
///
/// Responsibilities:
///
/// • Parse Home section JSON
/// • Serialize Home section data
/// • Convert data models into pure domain entities
/// • Safely handle malformed or missing API fields
/// • Keep JSON/API concerns outside the domain layer
///
/// Architecture:
///
/// API / Local Cache
///       ↓
/// HomeSectionModel
///       ↓
/// HomeSection
///       ↓
/// Repository
///       ↓
/// Use Case
///
/// The domain layer never needs to know how JSON is structured.
class HomeSectionModel {
  const HomeSectionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.items,
    this.subtitle,
    this.actionLabel,
    this.actionTarget,
    this.priority = 0,
    this.isEnabled = true,
    this.showWhenEmpty = false,
  });

  // ===========================================================================
  // DATA
  // ===========================================================================

  final String id;

  final String title;

  final HomeSectionType type;

  final List<HomeSectionItemModel> items;

  final String? subtitle;

  final String? actionLabel;

  final String? actionTarget;

  final int priority;

  final bool isEnabled;

  final bool showWhenEmpty;

  // ===========================================================================
  // JSON → MODEL
  // ===========================================================================

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    return HomeSectionModel(
      id: _readString(json['id']) ?? '',
      title: _readString(json['title']) ?? '',
      type: _parseSectionType(_readString(json['type'])),
      items: _parseItems(json['items']),
      subtitle: _readString(json['subtitle']),
      actionLabel: _readString(json['actionLabel'] ?? json['action_label']),
      actionTarget: _readString(json['actionTarget'] ?? json['action_target']),
      priority: _readNonNegativeInt(json['priority']),
      isEnabled: _readBool(
        json['isEnabled'] ?? json['is_enabled'],
        fallback: true,
      ),
      showWhenEmpty: _readBool(
        json['showWhenEmpty'] ?? json['show_when_empty'],
        fallback: false,
      ),
    );
  }

  // ===========================================================================
  // DOMAIN → MODEL
  // ===========================================================================

  factory HomeSectionModel.fromEntity(HomeSection entity) {
    return HomeSectionModel(
      id: entity.id,
      title: entity.title,
      type: entity.type,
      items: entity.items
          .map(HomeSectionItemModel.fromEntity)
          .toList(growable: false),
      subtitle: entity.subtitle,
      actionLabel: entity.actionLabel,
      actionTarget: entity.actionTarget,
      priority: entity.priority,
      isEnabled: entity.isEnabled,
      showWhenEmpty: entity.showWhenEmpty,
    );
  }

  // ===========================================================================
  // MODEL → DOMAIN
  // ===========================================================================

  HomeSection toEntity() {
    return HomeSection(
      id: id.trim(),
      title: title.trim(),
      type: type,
      items: List<HomeSectionItem>.unmodifiable(
        items.map((HomeSectionItemModel item) => item.toEntity()),
      ),
      subtitle: _normalizeOptionalString(subtitle),
      actionLabel: _normalizeOptionalString(actionLabel),
      actionTarget: _normalizeOptionalString(actionTarget),
      priority: priority < 0 ? 0 : priority,
      isEnabled: isEnabled,
      showWhenEmpty: showWhenEmpty,
    );
  }

  // ===========================================================================
  // MODEL → JSON
  // ===========================================================================

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'type': type.name,
      'items': items
          .map((HomeSectionItemModel item) => item.toJson())
          .toList(growable: false),
      if (_hasText(subtitle)) 'subtitle': subtitle!.trim(),
      if (_hasText(actionLabel)) 'actionLabel': actionLabel!.trim(),
      if (_hasText(actionTarget)) 'actionTarget': actionTarget!.trim(),
      'priority': priority,
      'isEnabled': isEnabled,
      'showWhenEmpty': showWhenEmpty,
    };
  }

  // ===========================================================================
  // COPY
  // ===========================================================================

  HomeSectionModel copyWith({
    String? id,
    String? title,
    HomeSectionType? type,
    List<HomeSectionItemModel>? items,
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
    return HomeSectionModel(
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
  // PARSING HELPERS
  // ===========================================================================

  static List<HomeSectionItemModel> _parseItems(dynamic value) {
    if (value is! List) {
      return const <HomeSectionItemModel>[];
    }

    final List<HomeSectionItemModel> result = <HomeSectionItemModel>[];

    for (final dynamic item in value) {
      if (item is Map<String, dynamic>) {
        result.add(HomeSectionItemModel.fromJson(item));
        continue;
      }

      if (item is Map) {
        try {
          result.add(
            HomeSectionItemModel.fromJson(Map<String, dynamic>.from(item)),
          );
        } on Object {
          // Ignore malformed individual items instead of rejecting the
          // complete Home response.
        }
      }
    }

    return List<HomeSectionItemModel>.unmodifiable(result);
  }

  static HomeSectionType _parseSectionType(String? value) {
    final String normalized = _normalizeEnumValue(value);

    switch (normalized) {
      case 'recommended':
        return HomeSectionType.recommended;

      case 'nearby':
        return HomeSectionType.nearby;

      case 'destinations':
      case 'destination':
        return HomeSectionType.destinations;

      case 'culture':
      case 'cultural':
        return HomeSectionType.culture;

      case 'food':
        return HomeSectionType.food;

      case 'hotels':
      case 'hotel':
        return HomeSectionType.hotels;

      case 'experiences':
      case 'experience':
        return HomeSectionType.experiences;

      case 'trending':
        return HomeSectionType.trending;

      case 'airecommendations':
      case 'airecommendation':
      case 'ai':
        return HomeSectionType.aiRecommendations;

      case 'favorites':
      case 'favourites':
        return HomeSectionType.favorites;

      default:
        return HomeSectionType.custom;
    }
  }

  static String _normalizeEnumValue(String? value) {
    if (value == null) {
      return '';
    }

    return value
        .trim()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');
  }

  static String? _readString(dynamic value) {
    if (value is! String) {
      return null;
    }

    return _normalizeOptionalString(value);
  }

  static int _readNonNegativeInt(dynamic value) {
    int? parsed;

    if (value is int) {
      parsed = value;
    } else if (value is num) {
      parsed = value.toInt();
    } else if (value is String) {
      parsed = int.tryParse(value.trim());
    }

    if (parsed == null || parsed < 0) {
      return 0;
    }

    return parsed;
  }

  static bool _readBool(dynamic value, {required bool fallback}) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      if (value == 1) {
        return true;
      }

      if (value == 0) {
        return false;
      }
    }

    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
        case 'yes':
          return true;

        case 'false':
        case '0':
        case 'no':
          return false;
      }
    }

    return fallback;
  }

  static bool _hasText(String? value) {
    return value?.trim().isNotEmpty ?? false;
  }

  static String? _normalizeOptionalString(String? value) {
    if (value == null) {
      return null;
    }

    final String normalized = value.trim();

    return normalized.isEmpty ? null : normalized;
  }
}

/// ============================================================================
/// SARTHEE AI — HOME SECTION ITEM MODEL
/// ============================================================================
///
/// Data representation of [HomeSectionItem].
class HomeSectionItemModel {
  const HomeSectionItemModel({
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

  final String id;

  final String title;

  final HomeSectionItemType type;

  final String? subtitle;

  final String? description;

  final String? imageUrl;

  final String? target;

  final Map<String, String> metadata;

  final bool isEnabled;

  // ===========================================================================
  // JSON → MODEL
  // ===========================================================================

  factory HomeSectionItemModel.fromJson(Map<String, dynamic> json) {
    return HomeSectionItemModel(
      id: HomeSectionModel._readString(json['id']) ?? '',
      title: HomeSectionModel._readString(json['title']) ?? '',
      type: _parseItemType(HomeSectionModel._readString(json['type'])),
      subtitle: HomeSectionModel._readString(json['subtitle']),
      description: HomeSectionModel._readString(json['description']),
      imageUrl: HomeSectionModel._readString(
        json['imageUrl'] ?? json['image_url'],
      ),
      target: HomeSectionModel._readString(json['target']),
      metadata: _parseMetadata(json['metadata']),
      isEnabled: HomeSectionModel._readBool(
        json['isEnabled'] ?? json['is_enabled'],
        fallback: true,
      ),
    );
  }

  // ===========================================================================
  // DOMAIN → MODEL
  // ===========================================================================

  factory HomeSectionItemModel.fromEntity(HomeSectionItem entity) {
    return HomeSectionItemModel(
      id: entity.id,
      title: entity.title,
      type: entity.type,
      subtitle: entity.subtitle,
      description: entity.description,
      imageUrl: entity.imageUrl,
      target: entity.target,
      metadata: Map<String, String>.unmodifiable(entity.metadata),
      isEnabled: entity.isEnabled,
    );
  }

  // ===========================================================================
  // MODEL → DOMAIN
  // ===========================================================================

  HomeSectionItem toEntity() {
    return HomeSectionItem(
      id: id.trim(),
      title: title.trim(),
      type: type,
      subtitle: HomeSectionModel._normalizeOptionalString(subtitle),
      description: HomeSectionModel._normalizeOptionalString(description),
      imageUrl: HomeSectionModel._normalizeOptionalString(imageUrl),
      target: HomeSectionModel._normalizeOptionalString(target),
      metadata: Map<String, String>.unmodifiable(metadata),
      isEnabled: isEnabled,
    );
  }

  // ===========================================================================
  // MODEL → JSON
  // ===========================================================================

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'type': type.name,
      if (HomeSectionModel._hasText(subtitle)) 'subtitle': subtitle!.trim(),
      if (HomeSectionModel._hasText(description))
        'description': description!.trim(),
      if (HomeSectionModel._hasText(imageUrl)) 'imageUrl': imageUrl!.trim(),
      if (HomeSectionModel._hasText(target)) 'target': target!.trim(),
      if (metadata.isNotEmpty) 'metadata': Map<String, String>.from(metadata),
      'isEnabled': isEnabled,
    };
  }

  // ===========================================================================
  // TYPE PARSING
  // ===========================================================================

  static HomeSectionItemType _parseItemType(String? value) {
    final String normalized = HomeSectionModel._normalizeEnumValue(value);

    switch (normalized) {
      case 'destination':
      case 'destinations':
        return HomeSectionItemType.destination;

      case 'place':
      case 'places':
        return HomeSectionItemType.place;

      case 'culture':
      case 'cultural':
        return HomeSectionItemType.culture;

      case 'food':
        return HomeSectionItemType.food;

      case 'hotel':
      case 'hotels':
        return HomeSectionItemType.hotel;

      case 'experience':
      case 'experiences':
        return HomeSectionItemType.experience;

      case 'event':
      case 'events':
        return HomeSectionItemType.event;

      case 'airecommendation':
      case 'airecommendations':
      case 'ai':
        return HomeSectionItemType.aiRecommendation;

      default:
        return HomeSectionItemType.custom;
    }
  }

  // ===========================================================================
  // METADATA PARSING
  // ===========================================================================

  static Map<String, String> _parseMetadata(dynamic value) {
    if (value is! Map) {
      return const <String, String>{};
    }

    final Map<String, String> result = <String, String>{};

    for (final MapEntry<dynamic, dynamic> entry in value.entries) {
      final String key = entry.key.toString().trim();

      if (key.isEmpty || entry.value == null) {
        continue;
      }

      final String metadataValue = entry.value.toString().trim();

      if (metadataValue.isEmpty) {
        continue;
      }

      result[key] = metadataValue;
    }

    return Map<String, String>.unmodifiable(result);
  }

  // ===========================================================================
  // VALUE SEMANTICS
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is HomeSectionItemModel &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.subtitle == subtitle &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.target == target &&
        _mapsEqual(other.metadata, metadata) &&
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
    _metadataHash(metadata),
    isEnabled,
  );

  static bool _mapsEqual(
    Map<String, String> first,
    Map<String, String> second,
  ) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (final MapEntry<String, String> entry in first.entries) {
      if (second[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }

  static int _metadataHash(Map<String, String> metadata) {
    final List<MapEntry<String, String>> entries = metadata.entries.toList()
      ..sort((MapEntry<String, String> first, MapEntry<String, String> second) {
        return first.key.compareTo(second.key);
      });

    return Object.hashAll(
      entries.map((MapEntry<String, String> entry) {
        return Object.hash(entry.key, entry.value);
      }),
    );
  }
}
