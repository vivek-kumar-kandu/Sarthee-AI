import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'route_paths.dart';

/// ============================================================================
/// SARTHEE AI — ADVANCED ROUTE GUARDS
/// ============================================================================
///
/// Central navigation protection layer.
///
/// Supports:
/// • Authentication guards
/// • Guest-only routes
/// • Onboarding guards
/// • Maintenance mode
/// • Forced app updates
/// • Offline routing
/// • Redirect-loop protection
/// • Safe return URLs
/// • Future role/permission support
///
/// IMPORTANT:
/// This layer does not depend directly on Firebase/Auth/API services.
/// App state is supplied through [RouteGuardState].
/// ============================================================================

// ============================================================================
// AUTHENTICATION STATUS
// ============================================================================

enum AuthenticationStatus { unknown, unauthenticated, authenticated }

// ============================================================================
// ROUTE GUARD STATE
// ============================================================================

@immutable
final class RouteGuardState {
  const RouteGuardState({
    this.authenticationStatus = AuthenticationStatus.unknown,
    this.onboardingCompleted = false,
    this.isMaintenanceMode = false,
    this.isUpdateRequired = false,
    this.isOnline = true,
    this.isInitialized = false,
    this.isProfileComplete = false,
  });

  final AuthenticationStatus authenticationStatus;

  final bool onboardingCompleted;

  final bool isMaintenanceMode;

  final bool isUpdateRequired;

  final bool isOnline;

  /// True after critical startup state has been loaded.
  ///
  /// Example:
  /// • local preferences
  /// • auth session
  /// • remote configuration
  /// • onboarding state
  final bool isInitialized;
  final bool isProfileComplete;

  bool get isAuthenticated =>
      authenticationStatus == AuthenticationStatus.authenticated;

  bool get isUnauthenticated =>
      authenticationStatus == AuthenticationStatus.unauthenticated;

  bool get isAuthenticationUnknown =>
      authenticationStatus == AuthenticationStatus.unknown;

  RouteGuardState copyWith({
    AuthenticationStatus? authenticationStatus,
    bool? onboardingCompleted,
    bool? isMaintenanceMode,
    bool? isUpdateRequired,
    bool? isOnline,
    bool? isInitialized,
    bool? isProfileComplete,
  }) {
    return RouteGuardState(
      authenticationStatus: authenticationStatus ?? this.authenticationStatus,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isMaintenanceMode: isMaintenanceMode ?? this.isMaintenanceMode,
      isUpdateRequired: isUpdateRequired ?? this.isUpdateRequired,
      isOnline: isOnline ?? this.isOnline,
      isInitialized: isInitialized ?? this.isInitialized,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  @override
  String toString() {
    return 'RouteGuardState('
        'authenticationStatus: $authenticationStatus, '
        'onboardingCompleted: $onboardingCompleted, '
        'maintenance: $isMaintenanceMode, '
        'updateRequired: $isUpdateRequired, '
        'online: $isOnline, '
        'initialized: $isInitialized, '
        'profileComplete: $isProfileComplete'
        ')';
  }
}

// ============================================================================
// GUARD RESULT
// ============================================================================

@immutable
final class RouteGuardResult {
  const RouteGuardResult._({
    required this.allowed,
    this.redirectLocation,
    this.reason,
  });

  const RouteGuardResult.allow() : this._(allowed: true);

  const RouteGuardResult.redirect({required String location, String? reason})
    : this._(allowed: false, redirectLocation: location, reason: reason);

  final bool allowed;

  final String? redirectLocation;

  final String? reason;

  bool get shouldRedirect => !allowed && redirectLocation != null;
}

// ============================================================================
// ROUTE GUARDS
// ============================================================================

abstract final class RouteGuards {
  RouteGuards._();

  // ==========================================================================
  // ROUTE GROUPS
  // ==========================================================================

  /// Routes that never require authentication.
  static const Set<String> publicRoutes = <String>{
    RoutePaths.root,
    RoutePaths.splash,
    RoutePaths.onboarding,
    RoutePaths.login,
    RoutePaths.signup,
    RoutePaths.register,
    RoutePaths.forgotPassword,
    RoutePaths.verifyOtp,
    RoutePaths.resetPassword,
  };

  /// Routes intended only for unauthenticated users.
  static const Set<String> guestOnlyRoutes = <String>{
    RoutePaths.login,
    RoutePaths.signup,
    RoutePaths.register,
    RoutePaths.forgotPassword,
    RoutePaths.verifyOtp,
    RoutePaths.resetPassword,
  };

  /// Routes that should remain accessible in guest mode so the app shell can
  /// render and users can browse core content before authenticating.
  static const Set<String> guestAccessibleRoutes = <String>{
    RoutePaths.home,
    RoutePaths.destinations,
    RoutePaths.culture,
    RoutePaths.food,
    RoutePaths.hotels,
    RoutePaths.aiChat,
    RoutePaths.tripPlanner,
    RoutePaths.navigation,
    RoutePaths.weather,
    RoutePaths.notifications,
    RoutePaths.safety,
    RoutePaths.budget,
  };

  /// System routes must remain accessible regardless of normal guards.
  static const Set<String> systemRoutes = <String>{
    RoutePaths.offline,
    RoutePaths.maintenance,
    RoutePaths.updateRequired,
    RoutePaths.error,
  };

  /// Routes that may require network connectivity.
  ///
  /// More routes can be added later without touching guard logic.
  static const Set<String> networkRequiredRoutes = <String>{
    RoutePaths.aiChat,
    RoutePaths.hotels,
    RoutePaths.weather,
  };

  // ==========================================================================
  // MAIN REDIRECT
  // ==========================================================================

  /// Main GoRouter redirect handler.
  ///
  /// Usage:
  ///
  /// redirect: (context, state) {
  ///   return RouteGuards.redirect(
  ///     state: state,
  ///     guardState: currentGuardState,
  ///   );
  /// }
  static String? redirect({
    required GoRouterState state,
    required RouteGuardState guardState,
  }) {
    return redirectForPath(
      path: normalizePath(state.uri.path),
      guardState: guardState,
    );
  }

  /// Test-friendly redirect helper without requiring [GoRouterState].
  @visibleForTesting
  static String? redirectForPath({
    required String path,
    required RouteGuardState guardState,
  }) {
    if (kDebugMode) {
      debugPrint(
        '[RouteGuards] AUTH STATE: '
        'authentication=${guardState.authenticationStatus}, '
        'profileComplete=${guardState.isProfileComplete}, '
        'initialized=${guardState.isInitialized}',
      );
    }

    final result = _evaluatePath(path: path, guardState: guardState);

    if (!result.shouldRedirect) {
      if (kDebugMode) debugPrint('[RouteGuards] final: allow');
      return null;
    }

    final destination = result.redirectLocation;

    if (destination == null) {
      if (kDebugMode) debugPrint('[RouteGuards] final: no destination');
      return null;
    }

    final currentPath = normalizePath(path);
    final destinationPath = normalizePath(destination);

    if (currentPath == destinationPath) {
      if (kDebugMode) debugPrint('[RouteGuards] final: loop prevention');
      return null;
    }

    if (kDebugMode) {
      debugPrint(
        '[RouteGuards] ROUTER_REDIRECT: '
        'from: $currentPath '
        'to: $destination '
        'reason: ${result.reason ?? 'redirect'}',
      );
    }

    return destination;
  }

  static RouteGuardResult evaluate({
    required GoRouterState state,
    required RouteGuardState guardState,
  }) {
    return _evaluatePath(
      path: normalizePath(state.uri.path),
      guardState: guardState,
    );
  }

  static RouteGuardResult _evaluatePath({
    required String path,
    required RouteGuardState guardState,
  }) {
    // ------------------------------------------------------------------------
    // 1. FORCED UPDATE
    // ------------------------------------------------------------------------

    if (guardState.isUpdateRequired) {
      if (path != RoutePaths.updateRequired) {
        return const RouteGuardResult.redirect(
          location: RoutePaths.updateRequired,
          reason: 'Application update required.',
        );
      }

      return const RouteGuardResult.allow();
    }

    // ------------------------------------------------------------------------
    // 2. MAINTENANCE
    // ------------------------------------------------------------------------

    if (guardState.isMaintenanceMode) {
      if (path != RoutePaths.maintenance) {
        return const RouteGuardResult.redirect(
          location: RoutePaths.maintenance,
          reason: 'Application is under maintenance.',
        );
      }

      return const RouteGuardResult.allow();
    }

    // ------------------------------------------------------------------------
    // 3. STARTUP INITIALIZATION
    // ------------------------------------------------------------------------

    if (!guardState.isInitialized) {
      if (path != RoutePaths.splash) {
        return const RouteGuardResult.redirect(
          location: RoutePaths.splash,
          reason: 'Application initialization pending.',
        );
      }

      return const RouteGuardResult.allow();
    }

    // ------------------------------------------------------------------------
    // 4. LEAVE SYSTEM SCREENS AFTER RECOVERY
    // ------------------------------------------------------------------------

    if (path == RoutePaths.updateRequired && !guardState.isUpdateRequired) {
      return const RouteGuardResult.redirect(
        location: RoutePaths.root,
        reason: 'Update restriction cleared.',
      );
    }

    if (path == RoutePaths.maintenance && !guardState.isMaintenanceMode) {
      return const RouteGuardResult.redirect(
        location: RoutePaths.root,
        reason: 'Maintenance mode cleared.',
      );
    }

    if (path == RoutePaths.offline && guardState.isOnline) {
      return const RouteGuardResult.redirect(
        location: RoutePaths.root,
        reason: 'Network connection restored.',
      );
    }

    // ------------------------------------------------------------------------
    // 5. ONBOARDING
    // ------------------------------------------------------------------------

    if (!guardState.onboardingCompleted) {
      final canVisitBeforeOnboarding =
          path == RoutePaths.splash || path == RoutePaths.onboarding;

      if (!canVisitBeforeOnboarding) {
        return const RouteGuardResult.redirect(
          location: RoutePaths.onboarding,
          reason: 'Onboarding has not been completed.',
        );
      }

      return const RouteGuardResult.allow();
    }

    // User already completed onboarding.
    if (path == RoutePaths.onboarding) {
      return RouteGuardResult.redirect(
        location: _postOnboardingDestination(guardState),
        reason: 'Onboarding already completed.',
      );
    }

    // ------------------------------------------------------------------------
    // 6. AUTHENTICATION PROGRESS
    // ------------------------------------------------------------------------

    if (guardState.isAuthenticationUnknown) {
      if (path == RoutePaths.splash) {
        return const RouteGuardResult.allow();
      }

      if (isGuestOnly(path)) {
        return const RouteGuardResult.redirect(
          location: RoutePaths.splash,
          reason: 'Authentication in progress.',
        );
      }

      if (requiresAuthentication(path)) {
        return const RouteGuardResult.redirect(
          location: RoutePaths.splash,
          reason: 'Authentication in progress.',
        );
      }

      return const RouteGuardResult.allow();
    }

    if (path == RoutePaths.splash) {
      if (guardState.isAuthenticated) {
        if (!guardState.isProfileComplete) {
          return const RouteGuardResult.redirect(
            location: RoutePaths.profileSetup,
            reason: 'Authenticated user with incomplete profile.',
          );
        }
        return const RouteGuardResult.redirect(
          location: RoutePaths.home,
          reason: 'Authenticated users must not stay on splash.',
        );
      }

      if (guardState.isUnauthenticated) {
        return const RouteGuardResult.redirect(
          location: RoutePaths.login,
          reason: 'Bootstrap complete — unauthenticated.',
        );
      }

      return const RouteGuardResult.allow();
    }

    // ------------------------------------------------------------------------
    // 7. PROTECTED ROUTES
    // ------------------------------------------------------------------------

    // If user is authenticated but profile is incomplete, force profile setup
    if (guardState.isAuthenticated && !guardState.isProfileComplete) {
      final allowedPaths = <String>{
        RoutePaths.profileSetup,
        RoutePaths.editProfile,
        RoutePaths.profile,
      };

      if (!allowedPaths.contains(path)) {
        return RouteGuardResult.redirect(
          location: RoutePaths.profileSetup,
          reason: 'Profile incomplete.',
        );
      }
    }

    final protectedRoute = requiresAuthentication(path);

    if (protectedRoute && !guardState.isAuthenticated) {
      return RouteGuardResult.redirect(
        location: buildLoginRedirect(Uri.parse(path)),
        reason: 'Authentication required.',
      );
    }

    // ------------------------------------------------------------------------
    // 8. GUEST-ONLY ROUTES
    // ------------------------------------------------------------------------

    if (guardState.isAuthenticated && isGuestOnly(path)) {
      final Uri requestUri = Uri.parse(path);
      final returnLocation = sanitizeReturnLocation(
        requestUri.queryParameters['redirect'],
      );

      return RouteGuardResult.redirect(
        location: returnLocation ?? RoutePaths.home,
        reason: 'Authenticated user opened a guest-only route.',
      );
    }

    // ------------------------------------------------------------------------
    // 9. NETWORK REQUIREMENT
    // ------------------------------------------------------------------------

    if (!guardState.isOnline && requiresNetwork(path)) {
      return RouteGuardResult.redirect(
        location: buildOfflineRedirect(Uri.parse(path)),
        reason: 'Network connection required.',
      );
    }

    // ------------------------------------------------------------------------
    // ALLOW
    // ------------------------------------------------------------------------

    return const RouteGuardResult.allow();
  }

  // ==========================================================================
  // AUTHORIZATION HELPERS
  // ==========================================================================

  static bool requiresAuthentication(String location) {
    final path = normalizePath(location);

    if (isPublic(path)) {
      return false;
    }

    if (isSystem(path)) {
      return false;
    }

    return true;
  }

  static bool isPublic(String location) {
    return publicRoutes.contains(normalizePath(location));
  }

  static bool isGuestOnly(String location) {
    return guestOnlyRoutes.contains(normalizePath(location));
  }

  static bool isSystem(String location) {
    return systemRoutes.contains(normalizePath(location));
  }

  static bool requiresNetwork(String location) {
    final path = normalizePath(location);

    // Exact match.
    if (networkRequiredRoutes.contains(path)) {
      return true;
    }

    // Dynamic route support.
    //
    // Example:
    // /ai/chat/123
    if (path.startsWith('${RoutePaths.aiChat}/')) {
      return true;
    }

    if (path.startsWith('${RoutePaths.hotels}/')) {
      return true;
    }

    return false;
  }

  // ==========================================================================
  // LOGIN REDIRECT
  // ==========================================================================

  /// Creates:
  ///
  /// /login?redirect=%2Ftrip-planner
  ///
  /// allowing navigation to resume after authentication.
  static String buildLoginRedirect(Uri requestedUri) {
    final returnLocation = sanitizeReturnLocation(requestedUri.toString());

    if (returnLocation == null ||
        returnLocation == RoutePaths.root ||
        returnLocation == RoutePaths.login) {
      return RoutePaths.login;
    }

    return Uri(
      path: RoutePaths.login,
      queryParameters: <String, String>{'redirect': returnLocation},
    ).toString();
  }

  // ==========================================================================
  // OFFLINE REDIRECT
  // ==========================================================================

  static String buildOfflineRedirect(Uri requestedUri) {
    final returnLocation = sanitizeReturnLocation(requestedUri.toString());

    if (returnLocation == null || returnLocation == RoutePaths.offline) {
      return RoutePaths.offline;
    }

    return Uri(
      path: RoutePaths.offline,
      queryParameters: <String, String>{'redirect': returnLocation},
    ).toString();
  }

  // ==========================================================================
  // RETURN URL SECURITY
  // ==========================================================================

  /// Prevents unsafe/external redirect values.
  ///
  /// Accepted:
  ///
  /// /home
  /// /trip-planner
  /// /destination/123
  ///
  /// Rejected:
  ///
  /// https://evil.example
  /// //evil.example
  /// javascript:...
  static String? sanitizeReturnLocation(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    Uri uri;

    try {
      uri = Uri.parse(trimmed);
    } catch (_) {
      return null;
    }

    // External redirects are forbidden.
    if (uri.hasScheme || uri.hasAuthority || uri.host.isNotEmpty) {
      return null;
    }

    if (!trimmed.startsWith('/')) {
      return null;
    }

    if (trimmed.startsWith('//')) {
      return null;
    }

    return uri.toString();
  }

  // ==========================================================================
  // PATH NORMALIZATION
  // ==========================================================================

  static String normalizePath(String location) {
    if (location.trim().isEmpty) {
      return RoutePaths.root;
    }

    try {
      final uri = Uri.parse(location);

      var path = uri.path;

      if (path.isEmpty) {
        return RoutePaths.root;
      }

      // Remove trailing slash except root.
      while (path.length > 1 && path.endsWith('/')) {
        path = path.substring(0, path.length - 1);
      }

      return path;
    } catch (_) {
      return location;
    }
  }

  // ==========================================================================
  // POST-ONBOARDING DESTINATION
  // ==========================================================================

  static String _postOnboardingDestination(RouteGuardState state) {
    if (state.isAuthenticated) {
      return RoutePaths.home;
    }

    return RoutePaths.login;
  }

  // ==========================================================================
  // DEBUG VALIDATION
  // ==========================================================================

  static void debugValidate() {
    assert(() {
      for (final path in guestOnlyRoutes) {
        if (!publicRoutes.contains(path)) {
          throw StateError('Guest-only route must also be public: $path');
        }
      }

      for (final path in systemRoutes) {
        if (guestOnlyRoutes.contains(path)) {
          throw StateError('System route cannot be guest-only: $path');
        }
      }

      return true;
    }());
  }
}
