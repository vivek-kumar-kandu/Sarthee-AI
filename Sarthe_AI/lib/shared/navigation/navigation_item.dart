import 'package:flutter/material.dart';

/// Represents a single destination in Sarthee AI's primary navigation.
///
/// Designed to work across:
/// - Mobile NavigationBar
/// - Tablet NavigationRail
/// - Desktop navigation
/// - GoRouter
/// - Badges
/// - Authentication
/// - Feature flags
/// - Analytics
/// - Accessibility
///
/// This class contains configuration only.
/// Actual navigation logic belongs in the navigation controller/router.
@immutable
final class NavigationItem {
  const NavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.routeName,
    required this.routePath,
    this.semanticLabel,
    this.tooltip,
    this.badgeCount = 0,
    this.isEnabled = true,
    this.requiresAuthentication = false,
    this.analyticsName,
  }) : assert(id != '', 'Navigation item id cannot be empty.'),
       assert(label != '', 'Navigation item label cannot be empty.'),
       assert(routeName != '', 'Navigation route name cannot be empty.'),
       assert(routePath != '', 'Navigation route path cannot be empty.'),
       assert(badgeCount >= 0, 'Badge count cannot be negative.');

  // ===========================================================================
  // IDENTITY
  // ===========================================================================

  /// Stable internal identifier.
  ///
  /// Example:
  /// `home`
  /// `explore`
  /// `ai`
  /// `trips`
  /// `profile`
  ///
  /// Never use the visible label as the permanent identifier because labels
  /// may later change due to localization.
  final String id;

  /// User-visible navigation label.
  final String label;

  // ===========================================================================
  // ICONS
  // ===========================================================================

  /// Icon shown when this destination is not selected.
  final IconData icon;

  /// Icon shown when this destination is selected.
  final IconData selectedIcon;

  // ===========================================================================
  // ROUTING
  // ===========================================================================

  /// GoRouter route name.
  ///
  /// Example:
  /// `RouteNames.home`
  final String routeName;

  /// Canonical application route path.
  ///
  /// Example:
  /// `/home`
  final String routePath;

  // ===========================================================================
  // ACCESSIBILITY
  // ===========================================================================

  /// Optional accessibility description.
  ///
  /// Falls back to [label].
  final String? semanticLabel;

  /// Optional tooltip.
  ///
  /// Mainly useful for NavigationRail and desktop layouts.
  /// Falls back to [label].
  final String? tooltip;

  // ===========================================================================
  // BADGES
  // ===========================================================================

  /// Number displayed in the navigation badge.
  ///
  /// A value of zero means that no badge should be displayed.
  final int badgeCount;

  // ===========================================================================
  // AVAILABILITY
  // ===========================================================================

  /// Whether the destination can currently be selected.
  ///
  /// Useful for:
  /// - feature flags
  /// - staged releases
  /// - temporary feature disabling
  final bool isEnabled;

  /// Whether this destination requires an authenticated user.
  ///
  /// The actual authentication redirect is handled by RouteGuards.
  final bool requiresAuthentication;

  // ===========================================================================
  // ANALYTICS
  // ===========================================================================

  /// Stable analytics identifier.
  ///
  /// Example:
  /// `navigation_home`
  ///
  /// Falls back to [id] when not supplied.
  final String? analyticsName;

  // ===========================================================================
  // COMPUTED VALUES
  // ===========================================================================

  /// Whether this item currently has a visible badge.
  bool get hasBadge => badgeCount > 0;

  /// Accessibility label with fallback.
  String get effectiveSemanticLabel {
    final value = semanticLabel?.trim();

    if (value == null || value.isEmpty) {
      return label;
    }

    return value;
  }

  /// Tooltip with fallback.
  String get effectiveTooltip {
    final value = tooltip?.trim();

    if (value == null || value.isEmpty) {
      return label;
    }

    return value;
  }

  /// Analytics identifier with fallback.
  String get effectiveAnalyticsName {
    final value = analyticsName?.trim();

    if (value == null || value.isEmpty) {
      return id;
    }

    return value;
  }

  /// Badge text suitable for the UI.
  ///
  /// Examples:
  /// 0   → ''
  /// 4   → '4'
  /// 99  → '99'
  /// 100 → '99+'
  String get badgeLabel {
    if (!hasBadge) {
      return '';
    }

    if (badgeCount > 99) {
      return '99+';
    }

    return badgeCount.toString();
  }

  // ===========================================================================
  // ROUTE MATCHING
  // ===========================================================================

  /// Checks whether [location] belongs to this navigation destination.
  ///
  /// Supports:
  ///
  /// `/home`
  ///
  /// and nested routes such as:
  ///
  /// `/home/details`
  ///
  /// Query parameters and fragments are ignored.
  bool matchesLocation(String location) {
    if (location.trim().isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(location);

    final locationPath = _normalizePath(uri?.path ?? location);

    final itemPath = _normalizePath(routePath);

    if (locationPath == itemPath) {
      return true;
    }

    if (itemPath == '/') {
      return false;
    }

    return locationPath.startsWith('$itemPath/');
  }

  static String _normalizePath(String path) {
    var normalized = path.trim();

    if (normalized.isEmpty) {
      return '/';
    }

    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }

    while (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    return normalized;
  }

  // ===========================================================================
  // COPY
  // ===========================================================================

  NavigationItem copyWith({
    String? id,
    String? label,
    IconData? icon,
    IconData? selectedIcon,
    String? routeName,
    String? routePath,
    String? semanticLabel,
    String? tooltip,
    int? badgeCount,
    bool? isEnabled,
    bool? requiresAuthentication,
    String? analyticsName,
    bool clearSemanticLabel = false,
    bool clearTooltip = false,
    bool clearAnalyticsName = false,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      routeName: routeName ?? this.routeName,
      routePath: routePath ?? this.routePath,
      semanticLabel: clearSemanticLabel
          ? null
          : semanticLabel ?? this.semanticLabel,
      tooltip: clearTooltip ? null : tooltip ?? this.tooltip,
      badgeCount: badgeCount ?? this.badgeCount,
      isEnabled: isEnabled ?? this.isEnabled,
      requiresAuthentication:
          requiresAuthentication ?? this.requiresAuthentication,
      analyticsName: clearAnalyticsName
          ? null
          : analyticsName ?? this.analyticsName,
    );
  }

  // ===========================================================================
  // CONVENIENCE METHODS
  // ===========================================================================

  /// Returns a copy with an updated badge.
  NavigationItem withBadge(int count) {
    assert(count >= 0, 'Badge count cannot be negative.');

    return copyWith(badgeCount: count);
  }

  /// Removes the current badge.
  NavigationItem withoutBadge() {
    if (!hasBadge) {
      return this;
    }

    return copyWith(badgeCount: 0);
  }

  /// Enables this navigation destination.
  NavigationItem enable() {
    if (isEnabled) {
      return this;
    }

    return copyWith(isEnabled: true);
  }

  /// Disables this navigation destination.
  NavigationItem disable() {
    if (!isEnabled) {
      return this;
    }

    return copyWith(isEnabled: false);
  }

  // ===========================================================================
  // OBJECT CONTRACT
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is NavigationItem &&
        other.id == id &&
        other.label == label &&
        other.icon == icon &&
        other.selectedIcon == selectedIcon &&
        other.routeName == routeName &&
        other.routePath == routePath &&
        other.semanticLabel == semanticLabel &&
        other.tooltip == tooltip &&
        other.badgeCount == badgeCount &&
        other.isEnabled == isEnabled &&
        other.requiresAuthentication == requiresAuthentication &&
        other.analyticsName == analyticsName;
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    icon,
    selectedIcon,
    routeName,
    routePath,
    semanticLabel,
    tooltip,
    badgeCount,
    isEnabled,
    requiresAuthentication,
    analyticsName,
  );

  @override
  String toString() {
    return 'NavigationItem('
        'id: $id, '
        'label: $label, '
        'routeName: $routeName, '
        'routePath: $routePath, '
        'badgeCount: $badgeCount, '
        'isEnabled: $isEnabled, '
        'requiresAuthentication: $requiresAuthentication'
        ')';
  }
}
