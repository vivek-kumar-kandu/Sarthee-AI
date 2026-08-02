import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ============================================================================
/// SARTHEE AI — ADVANCED NAVIGATION OBSERVER
/// ============================================================================
///
/// Central observer for application navigation.
///
/// Designed for:
/// • Navigation debugging
/// • Route history
/// • Screen analytics
/// • Screen duration tracking
/// • Crash-reporting context
/// • Deep-link debugging
/// • Future Firebase Analytics integration
/// • Future Sentry / Crashlytics integration
/// • Performance monitoring
///
/// IMPORTANT:
/// This class does NOT directly depend on Firebase/Sentry.
/// External analytics services can later subscribe through [onNavigationEvent].
/// ============================================================================

// ============================================================================
// NAVIGATION EVENT TYPE
// ============================================================================

enum NavigationEventType {
  push,
  pop,
  replace,
  remove,
  startUserGesture,
  stopUserGesture,
}

// ============================================================================
// NAVIGATION EVENT
// ============================================================================

@immutable
final class NavigationEvent {
  const NavigationEvent({
    required this.type,
    required this.timestamp,
    this.routeName,
    this.previousRouteName,
    this.routePath,
    this.arguments,
  });

  final NavigationEventType type;

  final DateTime timestamp;

  final String? routeName;

  final String? previousRouteName;

  final String? routePath;

  final Object? arguments;

  @override
  String toString() {
    return 'NavigationEvent('
        'type: $type, '
        'route: $routeName, '
        'previous: $previousRouteName, '
        'path: $routePath, '
        'timestamp: $timestamp'
        ')';
  }
}

// ============================================================================
// ROUTE HISTORY ENTRY
// ============================================================================

@immutable
final class RouteHistoryEntry {
  const RouteHistoryEntry({
    required this.routeName,
    required this.enteredAt,
    this.routePath,
    this.exitedAt,
  });

  final String routeName;

  final String? routePath;

  final DateTime enteredAt;

  final DateTime? exitedAt;

  Duration? get duration {
    final exit = exitedAt;

    if (exit == null) {
      return null;
    }

    return exit.difference(enteredAt);
  }

  RouteHistoryEntry copyWith({
    String? routeName,
    String? routePath,
    DateTime? enteredAt,
    DateTime? exitedAt,
  }) {
    return RouteHistoryEntry(
      routeName: routeName ?? this.routeName,
      routePath: routePath ?? this.routePath,
      enteredAt: enteredAt ?? this.enteredAt,
      exitedAt: exitedAt ?? this.exitedAt,
    );
  }

  @override
  String toString() {
    return 'RouteHistoryEntry('
        'routeName: $routeName, '
        'routePath: $routePath, '
        'enteredAt: $enteredAt, '
        'exitedAt: $exitedAt, '
        'duration: $duration'
        ')';
  }
}

// ============================================================================
// NAVIGATION OBSERVER
// ============================================================================

final class SartheeNavigationObserver extends NavigatorObserver {
  SartheeNavigationObserver({
    this.enableDebugLogging = kDebugMode,
    this.maxHistoryEntries = 100,
    this.onNavigationEvent,
  }) : assert(
         maxHistoryEntries > 0,
         'maxHistoryEntries must be greater than zero.',
       );

  // ==========================================================================
  // CONFIGURATION
  // ==========================================================================

  final bool enableDebugLogging;

  final int maxHistoryEntries;

  /// External analytics integration hook.
  ///
  /// Later you can connect:
  ///
  /// Firebase Analytics
  /// Sentry
  /// Crashlytics
  /// Custom backend analytics
  ///
  /// without changing this observer.
  final void Function(NavigationEvent event)? onNavigationEvent;

  // ==========================================================================
  // INTERNAL STATE
  // ==========================================================================

  final List<RouteHistoryEntry> _history = <RouteHistoryEntry>[];

  Route<dynamic>? _currentRoute;

  DateTime? _currentRouteEnteredAt;

  // ==========================================================================
  // PUBLIC STATE
  // ==========================================================================

  List<RouteHistoryEntry> get history =>
      List<RouteHistoryEntry>.unmodifiable(_history);

  Route<dynamic>? get currentRoute => _currentRoute;

  String? get currentRouteName => _extractRouteName(_currentRoute);

  String? get currentRoutePath => _extractRoutePath(_currentRoute);

  bool get hasCurrentRoute => _currentRoute != null;

  // ==========================================================================
  // PUSH
  // ==========================================================================

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    _finishCurrentRoute();

    _currentRoute = route;
    _currentRouteEnteredAt = DateTime.now();

    _addHistoryEntry(route);

    _emit(
      type: NavigationEventType.push,
      route: route,
      previousRoute: previousRoute,
    );
  }

  // ==========================================================================
  // POP
  // ==========================================================================

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    _finishCurrentRoute();

    _currentRoute = previousRoute;
    _currentRouteEnteredAt = DateTime.now();

    if (previousRoute != null) {
      _addHistoryEntry(previousRoute);
    }

    _emit(
      type: NavigationEventType.pop,
      route: route,
      previousRoute: previousRoute,
    );
  }

  // ==========================================================================
  // REPLACE
  // ==========================================================================

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    _finishCurrentRoute();

    _currentRoute = newRoute;
    _currentRouteEnteredAt = newRoute == null ? null : DateTime.now();

    if (newRoute != null) {
      _addHistoryEntry(newRoute);
    }

    _emit(
      type: NavigationEventType.replace,
      route: newRoute,
      previousRoute: oldRoute,
    );
  }

  // ==========================================================================
  // REMOVE
  // ==========================================================================

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

    _emit(
      type: NavigationEventType.remove,
      route: route,
      previousRoute: previousRoute,
    );
  }

  // ==========================================================================
  // USER GESTURE
  // ==========================================================================

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    super.didStartUserGesture(route, previousRoute);

    _emit(
      type: NavigationEventType.startUserGesture,
      route: route,
      previousRoute: previousRoute,
    );
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();

    final event = NavigationEvent(
      type: NavigationEventType.stopUserGesture,
      timestamp: DateTime.now(),
      routeName: currentRouteName,
      routePath: currentRoutePath,
    );

    _dispatch(event);
  }

  // ==========================================================================
  // EVENT CREATION
  // ==========================================================================

  void _emit({
    required NavigationEventType type,
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  }) {
    final event = NavigationEvent(
      type: type,
      timestamp: DateTime.now(),
      routeName: _extractRouteName(route),
      previousRouteName: _extractRouteName(previousRoute),
      routePath: _extractRoutePath(route),
      arguments: route?.settings.arguments,
    );

    _dispatch(event);
  }

  // ==========================================================================
  // EVENT DISPATCH
  // ==========================================================================

  void _dispatch(NavigationEvent event) {
    if (enableDebugLogging) {
      debugPrint('[SartheeNavigation] $event');
    }

    try {
      onNavigationEvent?.call(event);
    } catch (error, stackTrace) {
      if (enableDebugLogging) {
        debugPrint(
          '[SartheeNavigation] '
          'Navigation listener failed: $error',
        );

        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  // ==========================================================================
  // HISTORY
  // ==========================================================================

  void _addHistoryEntry(Route<dynamic> route) {
    final now = DateTime.now();

    final entry = RouteHistoryEntry(
      routeName: _extractRouteName(route) ?? 'unknown',
      routePath: _extractRoutePath(route),
      enteredAt: now,
    );

    _history.add(entry);

    _trimHistory();
  }

  void _finishCurrentRoute() {
    if (_history.isEmpty) {
      return;
    }

    final enteredAt = _currentRouteEnteredAt;

    if (enteredAt == null) {
      return;
    }

    final index = _history.length - 1;

    final current = _history[index];

    if (current.exitedAt != null) {
      return;
    }

    _history[index] = current.copyWith(exitedAt: DateTime.now());
  }

  void _trimHistory() {
    if (_history.length <= maxHistoryEntries) {
      return;
    }

    final overflow = _history.length - maxHistoryEntries;

    _history.removeRange(0, overflow);
  }

  // ==========================================================================
  // ROUTE INFORMATION
  // ==========================================================================

  String? _extractRouteName(Route<dynamic>? route) {
    if (route == null) {
      return null;
    }

    final name = route.settings.name;

    if (name == null || name.trim().isEmpty) {
      return route.runtimeType.toString();
    }

    return name;
  }

  String? _extractRoutePath(Route<dynamic>? route) {
    if (route == null) {
      return null;
    }

    final name = route.settings.name;

    if (name == null || name.isEmpty) {
      return null;
    }

    try {
      final uri = Uri.parse(name);

      return uri.path.isEmpty ? name : uri.path;
    } catch (_) {
      return name;
    }
  }

  // ==========================================================================
  // PUBLIC UTILITIES
  // ==========================================================================

  /// Clears stored navigation history.
  ///
  /// Useful after:
  /// • logout
  /// • account switch
  /// • privacy reset
  /// • debug reset
  void clearHistory() {
    _history.clear();

    if (enableDebugLogging) {
      debugPrint('[SartheeNavigation] History cleared.');
    }
  }

  /// Returns the most recent navigation entries.
  List<RouteHistoryEntry> recentHistory([int count = 10]) {
    if (count <= 0 || _history.isEmpty) {
      return const <RouteHistoryEntry>[];
    }

    final start = (_history.length - count).clamp(0, _history.length);

    return List<RouteHistoryEntry>.unmodifiable(_history.sublist(start));
  }

  /// Current screen duration.
  Duration? get currentScreenDuration {
    final enteredAt = _currentRouteEnteredAt;

    if (enteredAt == null) {
      return null;
    }

    return DateTime.now().difference(enteredAt);
  }

  /// Prints navigation history in debug mode.
  void debugPrintHistory() {
    if (!enableDebugLogging) {
      return;
    }

    debugPrint('========== SARTHEE AI NAVIGATION HISTORY ==========');

    if (_history.isEmpty) {
      debugPrint('No navigation history.');

      return;
    }

    for (var index = 0; index < _history.length; index++) {
      debugPrint('${index + 1}. ${_history[index]}');
    }

    debugPrint('===================================================');
  }
}

// ============================================================================
// GLOBAL OBSERVER
// ============================================================================

/// Shared application navigation observer.
///
/// GoRouter can use:
///
/// observers: [sartheeNavigationObserver]
///
/// Later analytics integration can be injected without changing router
/// architecture.
final SartheeNavigationObserver sartheeNavigationObserver =
    SartheeNavigationObserver();
