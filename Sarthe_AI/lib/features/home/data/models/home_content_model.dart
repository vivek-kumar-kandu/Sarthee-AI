import '../../domain/entities/home_action.dart';
import '../../domain/entities/home_content.dart';
import 'home_section_model.dart';

/// ============================================================================
/// SARTHEE AI — HOME CONTENT MODEL
/// ============================================================================
///
/// Data-layer representation of [HomeContent].
///
/// Responsibilities:
///
/// • JSON → data model
/// • data model → JSON
/// • domain entity → data model
/// • data model → domain entity
/// • defensive API/cache parsing
/// • immutable collection boundaries
/// • backward-compatible JSON key parsing
///
/// Domain mapping:
///
/// HomeContentModel
///      ↓
/// HomeContent
///
/// HomeActionModel
///      ↓
/// HomeAction
class HomeContentModel {
  const HomeContentModel({
    required this.sections,
    required this.quickActions,
    this.greeting,
    this.subtitle,
    this.locationName,
    this.lastUpdatedAt,
  });

  // ===========================================================================
  // DATA
  // ===========================================================================

  final List<HomeSectionModel> sections;

  final List<HomeActionModel> quickActions;

  final String? greeting;

  final String? subtitle;

  final String? locationName;

  final DateTime? lastUpdatedAt;

  // ===========================================================================
  // JSON → MODEL
  // ===========================================================================

  factory HomeContentModel.fromJson(Map<String, dynamic> json) {
    return HomeContentModel(
      sections: _parseSections(json['sections']),
      quickActions: _parseActions(
        json['quickActions'] ?? json['quick_actions'],
      ),
      greeting: _readString(json['greeting']),
      subtitle: _readString(json['subtitle']),
      locationName: _readString(json['locationName'] ?? json['location_name']),
      lastUpdatedAt: _parseDateTime(
        json['lastUpdatedAt'] ??
            json['last_updated_at'] ??
            json['updatedAt'] ??
            json['updated_at'],
      ),
    );
  }

  // ===========================================================================
  // DOMAIN → MODEL
  // ===========================================================================

  factory HomeContentModel.fromEntity(HomeContent entity) {
    return HomeContentModel(
      sections: List<HomeSectionModel>.unmodifiable(
        entity.sections.map(HomeSectionModel.fromEntity),
      ),
      quickActions: List<HomeActionModel>.unmodifiable(
        entity.quickActions.map(HomeActionModel.fromEntity),
      ),
      greeting: entity.greeting,
      subtitle: entity.subtitle,
      locationName: entity.locationName,
      lastUpdatedAt: entity.lastUpdatedAt,
    );
  }

  // ===========================================================================
  // MODEL → DOMAIN
  // ===========================================================================

  HomeContent toEntity() {
    return HomeContent(
      sections: List.unmodifiable(
        sections.map((HomeSectionModel section) => section.toEntity()),
      ),
      quickActions: List.unmodifiable(
        quickActions.map((HomeActionModel action) => action.toEntity()),
      ),
      greeting: _normalizeOptionalString(greeting),
      subtitle: _normalizeOptionalString(subtitle),
      locationName: _normalizeOptionalString(locationName),
      lastUpdatedAt: lastUpdatedAt,
    );
  }

  // ===========================================================================
  // MODEL → JSON
  // ===========================================================================

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sections': sections
          .map((HomeSectionModel section) => section.toJson())
          .toList(growable: false),
      'quickActions': quickActions
          .map((HomeActionModel action) => action.toJson())
          .toList(growable: false),
      if (_hasText(greeting)) 'greeting': greeting!.trim(),
      if (_hasText(subtitle)) 'subtitle': subtitle!.trim(),
      if (_hasText(locationName)) 'locationName': locationName!.trim(),
      if (lastUpdatedAt != null)
        'lastUpdatedAt': lastUpdatedAt!.toUtc().toIso8601String(),
    };
  }

  // ===========================================================================
  // COPY
  // ===========================================================================

  HomeContentModel copyWith({
    List<HomeSectionModel>? sections,
    List<HomeActionModel>? quickActions,
    String? greeting,
    String? subtitle,
    String? locationName,
    DateTime? lastUpdatedAt,
    bool clearGreeting = false,
    bool clearSubtitle = false,
    bool clearLocation = false,
    bool clearLastUpdatedAt = false,
  }) {
    return HomeContentModel(
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
  // SECTION PARSING
  // ===========================================================================

  static List<HomeSectionModel> _parseSections(dynamic value) {
    if (value is! List) {
      return const <HomeSectionModel>[];
    }

    final List<HomeSectionModel> result = <HomeSectionModel>[];

    for (final dynamic item in value) {
      final Map<String, dynamic>? map = _asJsonMap(item);

      if (map == null) {
        continue;
      }

      try {
        result.add(HomeSectionModel.fromJson(map));
      } on Object {
        // Ignore a malformed individual section instead of invalidating
        // the entire Home payload.
      }
    }

    return List<HomeSectionModel>.unmodifiable(result);
  }

  // ===========================================================================
  // ACTION PARSING
  // ===========================================================================

  static List<HomeActionModel> _parseActions(dynamic value) {
    if (value is! List) {
      return const <HomeActionModel>[];
    }

    final List<HomeActionModel> result = <HomeActionModel>[];

    for (final dynamic item in value) {
      final Map<String, dynamic>? map = _asJsonMap(item);

      if (map == null) {
        continue;
      }

      try {
        result.add(HomeActionModel.fromJson(map));
      } on Object {
        // Preserve valid actions even when one backend/cache entry is
        // malformed.
      }
    }

    return List<HomeActionModel>.unmodifiable(result);
  }

  // ===========================================================================
  // JSON MAP
  // ===========================================================================

  static Map<String, dynamic>? _asJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } on Object {
        return null;
      }
    }

    return null;
  }

  // ===========================================================================
  // STRING PARSING
  // ===========================================================================

  static String? _readString(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return _normalizeOptionalString(value);
    }

    return null;
  }

  static String? _normalizeOptionalString(String? value) {
    if (value == null) {
      return null;
    }

    final String normalized = value.trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  static bool _hasText(String? value) {
    return value?.trim().isNotEmpty ?? false;
  }

  // ===========================================================================
  // DATE PARSING
  // ===========================================================================

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final String normalized = value.trim();

      if (normalized.isEmpty) {
        return null;
      }

      return DateTime.tryParse(normalized);
    }

    if (value is int) {
      return _parseTimestamp(value);
    }

    if (value is num) {
      return _parseTimestamp(value.toInt());
    }

    return null;
  }

  static DateTime? _parseTimestamp(int timestamp) {
    if (timestamp <= 0) {
      return null;
    }

    try {
      final int milliseconds = timestamp < 100000000000
          ? timestamp * 1000
          : timestamp;

      return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
    } on Object {
      return null;
    }
  }

  // ===========================================================================
  // VALUE SEMANTICS
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is HomeContentModel &&
        _listEquals(other.sections, sections) &&
        _listEquals(other.quickActions, quickActions) &&
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

  static bool _listEquals<T>(List<T> first, List<T> second) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (int index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }

    return true;
  }

  @override
  String toString() {
    return 'HomeContentModel('
        'sections: ${sections.length}, '
        'quickActions: ${quickActions.length}, '
        'greeting: $greeting, '
        'subtitle: $subtitle, '
        'locationName: $locationName, '
        'lastUpdatedAt: $lastUpdatedAt'
        ')';
  }
}

/// ============================================================================
/// SARTHEE AI — HOME ACTION MODEL
/// ============================================================================
///
/// Data-layer representation of [HomeAction].
///
/// Domain-safe properties are retained instead of exposing Flutter-specific
/// navigation/icon objects.
class HomeActionModel {
  const HomeActionModel({
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
  }) : assert(priority >= 0, 'HomeActionModel priority cannot be negative.');

  // ===========================================================================
  // IDENTITY
  // ===========================================================================

  final String id;

  final String label;

  final HomeActionType type;

  // ===========================================================================
  // PRESENTATION METADATA
  // ===========================================================================

  final String? subtitle;

  final String? target;

  final String? iconKey;

  final String? badgeLabel;

  // ===========================================================================
  // BEHAVIOR
  // ===========================================================================

  final int priority;

  final bool isEnabled;

  final bool requiresAuthentication;

  final Map<String, String> metadata;

  // ===========================================================================
  // JSON → MODEL
  // ===========================================================================

  factory HomeActionModel.fromJson(Map<String, dynamic> json) {
    return HomeActionModel(
      id: HomeContentModel._readString(json['id']) ?? '',
      label: HomeContentModel._readString(json['label']) ?? '',
      type: _parseType(
        json['type'] ?? json['actionType'] ?? json['action_type'],
      ),
      subtitle: HomeContentModel._readString(json['subtitle']),
      target: HomeContentModel._readString(json['target']),
      iconKey: HomeContentModel._readString(
        json['iconKey'] ?? json['icon_key'] ?? json['icon'],
      ),
      badgeLabel: HomeContentModel._readString(
        json['badgeLabel'] ?? json['badge_label'] ?? json['badge'],
      ),
      priority: _readNonNegativeInt(json['priority']),
      isEnabled: _readBool(
        json['isEnabled'] ?? json['is_enabled'],
        fallback: true,
      ),
      requiresAuthentication: _readBool(
        json['requiresAuthentication'] ?? json['requires_authentication'],
        fallback: false,
      ),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  // ===========================================================================
  // DOMAIN → MODEL
  // ===========================================================================

  factory HomeActionModel.fromEntity(HomeAction entity) {
    return HomeActionModel(
      id: entity.id,
      label: entity.label,
      type: entity.type,
      subtitle: entity.subtitle,
      target: entity.target,
      iconKey: entity.iconKey,
      badgeLabel: entity.badgeLabel,
      priority: entity.priority,
      isEnabled: entity.isEnabled,
      requiresAuthentication: entity.requiresAuthentication,
      metadata: Map<String, String>.unmodifiable(entity.metadata),
    );
  }

  // ===========================================================================
  // MODEL → DOMAIN
  // ===========================================================================

  HomeAction toEntity() {
    return HomeAction(
      id: id.trim(),
      label: label.trim(),
      type: type,
      subtitle: HomeContentModel._normalizeOptionalString(subtitle),
      target: HomeContentModel._normalizeOptionalString(target),
      iconKey: HomeContentModel._normalizeOptionalString(iconKey),
      badgeLabel: HomeContentModel._normalizeOptionalString(badgeLabel),
      priority: priority,
      isEnabled: isEnabled,
      requiresAuthentication: requiresAuthentication,
      metadata: Map<String, String>.unmodifiable(metadata),
    );
  }

  // ===========================================================================
  // MODEL → JSON
  // ===========================================================================

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id.trim(),
      'label': label.trim(),
      'type': type.name,
      if (HomeContentModel._hasText(subtitle)) 'subtitle': subtitle!.trim(),
      if (HomeContentModel._hasText(target)) 'target': target!.trim(),
      if (HomeContentModel._hasText(iconKey)) 'iconKey': iconKey!.trim(),
      if (HomeContentModel._hasText(badgeLabel))
        'badgeLabel': badgeLabel!.trim(),
      'priority': priority,
      'isEnabled': isEnabled,
      'requiresAuthentication': requiresAuthentication,
      if (metadata.isNotEmpty) 'metadata': Map<String, String>.from(metadata),
    };
  }

  // ===========================================================================
  // COPY
  // ===========================================================================

  HomeActionModel copyWith({
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
    return HomeActionModel(
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
  // ACTION TYPE PARSING
  // ===========================================================================

  static HomeActionType _parseType(dynamic value) {
    if (value is HomeActionType) {
      return value;
    }

    if (value is! String) {
      return HomeActionType.custom;
    }

    final String normalized = value
        .trim()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .toLowerCase();

    switch (normalized) {
      case 'explore':
      case 'destination':
      case 'destinations':
        return HomeActionType.explore;

      case 'ai':
      case 'aiassistant':
      case 'assistant':
      case 'sartheeai':
        return HomeActionType.aiAssistant;

      case 'trip':
      case 'trips':
      case 'tripplanner':
      case 'plantrip':
        return HomeActionType.tripPlanner;

      case 'nearby':
      case 'nearme':
        return HomeActionType.nearby;

      case 'favorite':
      case 'favorites':
      case 'saved':
        return HomeActionType.favorites;

      case 'food':
      case 'foods':
        return HomeActionType.food;

      case 'culture':
      case 'cultural':
        return HomeActionType.culture;

      case 'hotel':
      case 'hotels':
        return HomeActionType.hotels;

      case 'weather':
        return HomeActionType.weather;

      case 'profile':
      case 'account':
        return HomeActionType.profile;

      case 'notification':
      case 'notifications':
        return HomeActionType.notifications;

      case 'custom':
      default:
        return HomeActionType.custom;
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

    value.forEach((dynamic rawKey, dynamic rawValue) {
      if (rawKey == null || rawValue == null) {
        return;
      }

      final String key = rawKey.toString().trim();
      final String metadataValue = rawValue.toString().trim();

      if (key.isEmpty || metadataValue.isEmpty) {
        return;
      }

      result[key] = metadataValue;
    });

    return Map<String, String>.unmodifiable(result);
  }

  // ===========================================================================
  // INTEGER PARSING
  // ===========================================================================

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

  // ===========================================================================
  // BOOLEAN PARSING
  // ===========================================================================

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
        case 'y':
          return true;

        case 'false':
        case '0':
        case 'no':
        case 'n':
          return false;
      }
    }

    return fallback;
  }

  // ===========================================================================
  // VALUE SEMANTICS
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is HomeActionModel &&
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
        _mapEquals(other.metadata, metadata);
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

  static bool _mapEquals(
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
    if (metadata.isEmpty) {
      return 0;
    }

    final List<MapEntry<String, String>> entries =
        metadata.entries.toList(growable: false)..sort((
          MapEntry<String, String> first,
          MapEntry<String, String> second,
        ) {
          return first.key.compareTo(second.key);
        });

    return Object.hashAll(
      entries.map((MapEntry<String, String> entry) {
        return Object.hash(entry.key, entry.value);
      }),
    );
  }

  @override
  String toString() {
    return 'HomeActionModel('
        'id: $id, '
        'label: $label, '
        'type: $type, '
        'priority: $priority, '
        'isEnabled: $isEnabled, '
        'requiresAuthentication: '
        '$requiresAuthentication'
        ')';
  }
}
