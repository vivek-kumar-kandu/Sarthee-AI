import 'package:flutter/material.dart';

import '../../app/router/route_names.dart';
import '../../app/router/route_paths.dart';
import 'navigation_item.dart';

/// Central configuration for Sarthee AI's primary application navigation.
///
/// IMPORTANT:
///
/// The order of [primaryItems] MUST exactly match the order of
/// StatefulShellBranch entries inside app_router.dart.
///
/// Branch mapping:
///
/// 0 → Home
/// 1 → Explore
/// 2 → Sarthee AI
/// 3 → Trips
/// 4 → Profile
///
/// Do not reorder these items without updating the router branches.
abstract final class NavigationConfig {
  NavigationConfig._();

  // ===========================================================================
  // BRANCH INDEXES
  // ===========================================================================

  static const int homeIndex = 0;
  static const int exploreIndex = 1;
  static const int aiIndex = 2;
  static const int tripsIndex = 3;
  static const int profileIndex = 4;

  static const int branchCount = 5;

  // ===========================================================================
  // PRIMARY NAVIGATION
  // ===========================================================================

  static const List<NavigationItem> primaryItems = <NavigationItem>[
    // -------------------------------------------------------------------------
    // 0 — HOME
    // -------------------------------------------------------------------------
    NavigationItem(
      id: 'home',
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      routeName: RouteNames.home,
      routePath: RoutePaths.home,
      semanticLabel: 'Home',
      tooltip: 'Home',
      analyticsName: 'navigation_home',
    ),

    // -------------------------------------------------------------------------
    // 1 — EXPLORE
    // -------------------------------------------------------------------------
    NavigationItem(
      id: 'explore',
      label: 'Explore',
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
      routeName: RouteNames.destinations,
      routePath: RoutePaths.destinations,
      semanticLabel: 'Explore destinations',
      tooltip: 'Explore',
      analyticsName: 'navigation_explore',
    ),

    // -------------------------------------------------------------------------
    // 2 — SARTHEE AI
    // -------------------------------------------------------------------------
    NavigationItem(
      id: 'ai',
      label: 'Sarthee AI',
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome_rounded,
      routeName: RouteNames.aiChat,
      routePath: RoutePaths.aiChat,
      semanticLabel: 'Sarthee AI assistant',
      tooltip: 'Ask Sarthee AI',
      analyticsName: 'navigation_ai',
    ),

    // -------------------------------------------------------------------------
    // 3 — TRIPS
    // -------------------------------------------------------------------------
    NavigationItem(
      id: 'trips',
      label: 'Trips',
      icon: Icons.route_outlined,
      selectedIcon: Icons.route_rounded,
      routeName: RouteNames.tripPlanner,
      routePath: RoutePaths.tripPlanner,
      semanticLabel: 'Trip planner',
      tooltip: 'Trips',
      analyticsName: 'navigation_trips',
    ),

    // -------------------------------------------------------------------------
    // 4 — PROFILE
    // -------------------------------------------------------------------------
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      routeName: RouteNames.profile,
      routePath: RoutePaths.profile,
      semanticLabel: 'Profile',
      tooltip: 'Profile',
      requiresAuthentication: true,
      analyticsName: 'navigation_profile',
    ),
  ];

  // ===========================================================================
  // LOOKUPS
  // ===========================================================================

  /// Returns the navigation item for [index].
  ///
  /// Falls back to Home when an invalid index is supplied.
  static NavigationItem itemAt(int index) {
    if (!isValidIndex(index)) {
      return primaryItems[homeIndex];
    }

    return primaryItems[index];
  }

  /// Returns whether [index] represents a valid primary branch.
  static bool isValidIndex(int index) {
    return index >= 0 && index < primaryItems.length;
  }

  /// Finds a navigation item by its stable ID.
  static NavigationItem? findById(String id) {
    final normalizedId = id.trim().toLowerCase();

    for (final item in primaryItems) {
      if (item.id.toLowerCase() == normalizedId) {
        return item;
      }
    }

    return null;
  }

  /// Finds a navigation item by GoRouter route name.
  static NavigationItem? findByRouteName(String routeName) {
    final normalizedName = routeName.trim();

    for (final item in primaryItems) {
      if (item.routeName == normalizedName) {
        return item;
      }
    }

    return null;
  }

  // ===========================================================================
  // ROUTE → BRANCH RESOLUTION
  // ===========================================================================

  /// Resolves a route/location into its primary shell branch.
  ///
  /// This is useful for:
  /// - deep links
  /// - analytics
  /// - tests
  /// - external navigation
  /// - restoring navigation state
  ///
  /// The StatefulNavigationShell remains the source of truth while the app
  /// is running.
  static int indexForPath(String location) {
    final String path = _normalizeLocation(location);

    // -------------------------------------------------------------------------
    // HOME
    // -------------------------------------------------------------------------

    if (_matches(path, RoutePaths.home)) {
      return homeIndex;
    }

    // -------------------------------------------------------------------------
    // EXPLORE
    // -------------------------------------------------------------------------

    if (_matchesAny(path, <String>[
      RoutePaths.destinations,
      RoutePaths.culture,
      RoutePaths.food,
      RoutePaths.hotels,
    ])) {
      return exploreIndex;
    }

    // -------------------------------------------------------------------------
    // AI
    // -------------------------------------------------------------------------

    if (_matches(path, RoutePaths.aiChat)) {
      return aiIndex;
    }

    // -------------------------------------------------------------------------
    // TRIPS
    // -------------------------------------------------------------------------

    if (_matchesAny(path, <String>[
      RoutePaths.tripPlanner,
      RoutePaths.navigation,
    ])) {
      return tripsIndex;
    }

    // -------------------------------------------------------------------------
    // PROFILE
    // -------------------------------------------------------------------------

    if (_matchesAny(path, <String>[
      RoutePaths.profile,
      RoutePaths.favorites,
      RoutePaths.history,
      RoutePaths.settings,
    ])) {
      return profileIndex;
    }

    return homeIndex;
  }

  /// Returns the navigation item associated with [location].
  static NavigationItem itemForPath(String location) {
    return itemAt(indexForPath(location));
  }

  // ===========================================================================
  // ROUTE MATCHING
  // ===========================================================================

  static bool _matches(String location, String routePath) {
    final String normalizedRoute = _normalizePath(routePath);

    if (location == normalizedRoute) {
      return true;
    }

    if (normalizedRoute == '/') {
      return false;
    }

    return location.startsWith('$normalizedRoute/');
  }

  static bool _matchesAny(String location, Iterable<String> paths) {
    for (final routePath in paths) {
      if (_matches(location, routePath)) {
        return true;
      }
    }

    return false;
  }

  static String _normalizeLocation(String location) {
    final String value = location.trim();

    if (value.isEmpty) {
      return '/';
    }

    final Uri? uri = Uri.tryParse(value);

    return _normalizePath(uri?.path ?? value);
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
  // DEVELOPMENT VALIDATION
  // ===========================================================================

  /// Development-only validation for accidental navigation configuration
  /// mistakes.
  static void debugValidate() {
    assert(() {
      if (primaryItems.length != branchCount) {
        throw StateError(
          'NavigationConfig must contain exactly '
          '$branchCount primary items.',
        );
      }

      final Set<String> ids = <String>{};
      final Set<String> routeNames = <String>{};
      final Set<String> routePaths = <String>{};

      for (final item in primaryItems) {
        if (!ids.add(item.id)) {
          throw StateError('Duplicate navigation id: ${item.id}');
        }

        if (!routeNames.add(item.routeName)) {
          throw StateError(
            'Duplicate navigation route name: '
            '${item.routeName}',
          );
        }

        if (!routePaths.add(item.routePath)) {
          throw StateError(
            'Duplicate navigation route path: '
            '${item.routePath}',
          );
        }
      }

      if (primaryItems[homeIndex].id != 'home') {
        throw StateError('Home must remain branch $homeIndex.');
      }

      if (primaryItems[exploreIndex].id != 'explore') {
        throw StateError('Explore must remain branch $exploreIndex.');
      }

      if (primaryItems[aiIndex].id != 'ai') {
        throw StateError('Sarthee AI must remain branch $aiIndex.');
      }

      if (primaryItems[tripsIndex].id != 'trips') {
        throw StateError('Trips must remain branch $tripsIndex.');
      }

      if (primaryItems[profileIndex].id != 'profile') {
        throw StateError('Profile must remain branch $profileIndex.');
      }

      return true;
    }());
  }
}
