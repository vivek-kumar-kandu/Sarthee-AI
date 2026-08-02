import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/auth/state/auth_startup_state.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/location/pages/location_page.dart';
import '../../features/profile/pages/edit_profile_page.dart';
import '../../features/profile/pages/complete_profile_page.dart';
import '../../features/profile/setup/profile_setup_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/controllers/onboarding_controller.dart';
import '../../shared/navigation/app_shell.dart';
import '../../shared/navigation/navigation_config.dart';
import 'route_guards.dart';
import 'route_names.dart';
import 'route_observer.dart';
import 'route_paths.dart';
import '../../features/profile/setup/profile_completion_provider.dart';
import '../../features/smart_journey/presentation/pages/smart_journey_planner_page.dart';
import '../../features/smart_journey/presentation/pages/journey_details_page.dart';
import '../../features/smart_journey/presentation/pages/active_journey_guide_page.dart';
import '../../features/smart_journey/domain/entities/journey_plan.dart';
import '../../features/trip_planner/presentation/pages/trip_planner_page.dart';
import '../../features/safety/presentation/pages/emergency_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';


// =============================================================================
// SARTHEE AI — APPLICATION ROUTER
// =============================================================================
//
// Production navigation foundation.
//
// Architecture:
//
// SartheeApp
//   ↓
// MaterialApp.router
//   ↓
// GoRouter
//   ↓
// Global Route Guards
//   ↓
// Splash / Onboarding / Authentication
//   ↓
// StatefulShellRoute.indexedStack
//   ├── Home
//   ├── Explore
//   ├── Sarthee AI
//   ├── Trips
//   └── Profile
//
// Each primary branch owns an independent Navigator stack.
// =============================================================================

// =============================================================================
// NAVIGATOR KEYS
// =============================================================================

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'SartheeRootNavigator',
);

final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'SartheeHomeNavigator',
);

final GlobalKey<NavigatorState> exploreNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'SartheeExploreNavigator',
);

final GlobalKey<NavigatorState> aiNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'SartheeAINavigator',
);

final GlobalKey<NavigatorState> tripsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'SartheeTripsNavigator',
);

final GlobalKey<NavigatorState> profileNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'SartheeProfileNavigator',
);

// =============================================================================
// ROUTE GUARD STATE
// =============================================================================

/// Produces the state consumed by [RouteGuards].
///
// =============================================================================
// ROUTE GUARD STATE
// =============================================================================

/// Produces the state consumed by [RouteGuards].
///
/// Splash/bootstrap progress updates should not rebuild the router unless
/// application readiness itself changes.
///
/// Authentication and onboarding are currently temporary integration values.
/// They can later be replaced by their dedicated Riverpod providers without
/// changing the router architecture.
final routeGuardStateProvider = Provider<RouteGuardState>((ref) {
  final AuthStartupState startup = ref.watch(authStartupProvider);

  final AuthenticationStatus authenticationStatus;
  if (startup.phase.isBootstrapping) {
    authenticationStatus = AuthenticationStatus.unknown;
  } else if (startup.isAuthenticated) {
    authenticationStatus = AuthenticationStatus.authenticated;
  } else if (startup.hasError && startup.isOffline) {
    authenticationStatus = AuthenticationStatus.unknown;
  } else {
    authenticationStatus = AuthenticationStatus.unauthenticated;
  }

  final bool isProfileComplete = startup.isAuthenticated
      ? (startup.isProfileComplete || ref.watch(profileCompletionProvider))
      : false;

  return RouteGuardState(
    authenticationStatus: authenticationStatus,
    onboardingCompleted: ref.watch(hasCompletedOnboardingProvider),
    isMaintenanceMode: false,
    isUpdateRequired: false,
    isOnline: !startup.isOffline,
    isInitialized: startup.bootstrapComplete,
    isProfileComplete: isProfileComplete,
  );
});
// =============================================================================
// ROUTER PROVIDER
// =============================================================================

final appRouterProvider = Provider<GoRouter>((ref) {
  final RouteGuardState guardState = ref.watch(routeGuardStateProvider);

  // ---------------------------------------------------------------------------
  // DEVELOPMENT VALIDATION
  // ---------------------------------------------------------------------------

  assert(() {
    RouteGuards.debugValidate();
    NavigationConfig.debugValidate();
    return true;
  }());

  // ---------------------------------------------------------------------------
  // ROUTER
  // ---------------------------------------------------------------------------

  final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,

    debugLogDiagnostics: false,

    initialLocation: RoutePaths.splash,

    observers: <NavigatorObserver>[sartheeNavigationObserver],

    // =========================================================================
    // GLOBAL REDIRECT / ROUTE GUARDS
    // =========================================================================
    redirect: (BuildContext context, GoRouterState state) {
      return RouteGuards.redirect(state: state, guardState: guardState);
    },

    // =========================================================================
    // ROUTES
    // =========================================================================
    routes: <RouteBase>[
      // =======================================================================
      // ROOT
      // =======================================================================
      GoRoute(
        path: RoutePaths.root,
        name: RouteNames.root,
        redirect: (BuildContext context, GoRouterState state) {
          if (!guardState.isInitialized || guardState.isAuthenticationUnknown) {
            return RoutePaths.splash;
          }

          if (guardState.isAuthenticated) {
            if (!guardState.isProfileComplete) {
              return RoutePaths.profileSetup;
            }
            return RoutePaths.home;
          }

          return RoutePaths.login;
        },
      ),

      // =======================================================================
      // SPLASH
      // =======================================================================
      //
      // Unlike the other foundation routes, splash uses the real SplashPage.
      //
      // SplashController:
      //   ↓
      // performs bootstrap work
      //   ↓
      // updates SplashState
      //   ↓
      // routeGuardStateProvider observes isReady
      //   ↓
      // GoRouter redirects to the appropriate destination.
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildSplashPage(state: state, child: const SplashPage());
        },
      ),

      // =======================================================================
      // ONBOARDING
      // =======================================================================
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildAdaptivePage<void>(
            state: state,
            child: const OnboardingPage(),
          );
        },
      ),

      // =======================================================================
      // AUTHENTICATION
      // =======================================================================
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildAdaptivePage<void>(
            state: state,
            child: LoginPage(redirectTo: state.uri.queryParameters['redirect']),
          );
        },
      ),

      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildAdaptivePage<void>(
            state: state,
            child: SignupPage(
              redirectTo: state.uri.queryParameters['redirect'],
            ),
          );
        },
      ),

      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        redirect: (BuildContext context, GoRouterState state) {
          final redirect = state.uri.queryParameters['redirect'];
          if (redirect == null || redirect.isEmpty) {
            return RoutePaths.signup;
          }

          return Uri(
            path: RoutePaths.signup,
            queryParameters: <String, String>{'redirect': redirect},
          ).toString();
        },
      ),

      _buildRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        title: 'Forgot Password',
        subtitle: 'Recover access to your account',
        icon: Icons.lock_reset_rounded,
      ),

      _buildRoute(
        path: RoutePaths.verifyOtp,
        name: RouteNames.verifyOtp,
        title: 'Verify OTP',
        subtitle: 'Verify your identity securely',
        icon: Icons.verified_user_rounded,
      ),

      _buildRoute(
        path: RoutePaths.resetPassword,
        name: RouteNames.resetPassword,
        title: 'Reset Password',
        subtitle: 'Create a new secure password',
        icon: Icons.password_rounded,
      ),

      // =======================================================================
      // SMART JOURNEY ENGINE ROUTES
      // =======================================================================
      GoRoute(
        path: '/smart-journey',
        name: 'smartJourney',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildAdaptivePage<void>(
            state: state,
            child: const SmartJourneyPlannerPage(),
          );
        },
      ),

      GoRoute(
        path: '/journey-details',
        name: 'journeyDetails',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final plan = state.extra as JourneyPlan;
          return _buildAdaptivePage<void>(
            state: state,
            child: JourneyDetailsPage(plan: plan),
          );
        },
      ),

      GoRoute(
        path: '/active-trip',
        name: 'activeTrip',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildAdaptivePage<void>(
            state: state,
            child: const ActiveJourneyGuidePage(),
          );
        },
      ),

      // =======================================================================
      // PRIMARY APPLICATION SHELL
      // =======================================================================
      //
      // Indexed stack preserves:
      //
      // • branch navigation history
      // • scroll position
      // • nested route state
      // • feature state
      //
      // when switching between primary destinations.
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return AppShell(navigationShell: navigationShell);
            },

        branches: <StatefulShellBranch>[
          // ===================================================================
          // BRANCH 0 — HOME
          // ===================================================================
          StatefulShellBranch(
            navigatorKey: homeNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return _buildAdaptivePage<void>(
                    state: state,
                    child: const HomePage(),
                  );
                },
              ),
            ],
          ),

          // ===================================================================
          // BRANCH 1 — EXPLORE
          // ===================================================================
          StatefulShellBranch(
            navigatorKey: exploreNavigatorKey,
            routes: <RouteBase>[
              _buildRoute(
                path: RoutePaths.destinations,
                name: RouteNames.destinations,
                title: 'Destinations',
                subtitle: 'Discover places worth exploring',
                icon: Icons.explore_rounded,
              ),

              _buildRoute(
                path: RoutePaths.culture,
                name: RouteNames.culture,
                title: 'Culture',
                subtitle: 'Explore local heritage and traditions',
                icon: Icons.temple_hindu_rounded,
              ),

              _buildRoute(
                path: RoutePaths.food,
                name: RouteNames.food,
                title: 'Food',
                subtitle: 'Discover authentic local cuisine',
                icon: Icons.restaurant_rounded,
              ),

              _buildRoute(
                path: RoutePaths.hotels,
                name: RouteNames.hotels,
                title: 'Hotels',
                subtitle: 'Find the right place to stay',
                icon: Icons.hotel_rounded,
              ),
            ],
          ),

          // ===================================================================
          // BRANCH 2 — SARTHEE AI
          // ===================================================================
          StatefulShellBranch(
            navigatorKey: aiNavigatorKey,
            routes: <RouteBase>[
              _buildRoute(
                path: RoutePaths.aiChat,
                name: RouteNames.aiChat,
                title: 'Sarthee AI Assistant',
                subtitle: 'Ask anything about your journey',
                icon: Icons.auto_awesome_rounded,
              ),
            ],
          ),

          // ===================================================================
          // BRANCH 3 — TRIPS
          // ===================================================================
          StatefulShellBranch(
            navigatorKey: tripsNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.tripPlanner,
                name: RouteNames.tripPlanner,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return _buildAdaptivePage<void>(
                    state: state,
                    child: const TripPlannerPage(),
                  );
                },
              ),


              _buildRoute(
                path: RoutePaths.navigation,
                name: RouteNames.navigation,
                title: 'Navigation',
                subtitle: 'Navigate your journey intelligently',
                icon: Icons.navigation_rounded,
              ),
            ],
          ),

          // ===================================================================
// BRANCH 4 — PROFILE
// ===================================================================
StatefulShellBranch(
  navigatorKey: profileNavigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: RoutePaths.profile,
      name: RouteNames.profile,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return _buildAdaptivePage<void>(
          state: state,
          child: const ProfilePage(),
        );
      },
    ),

    GoRoute(
      path: RoutePaths.profileSetup,
      name: RouteNames.profileSetup,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return _buildAdaptivePage<void>(
          state: state,
          child: const ProfileSetupPage(),
        );
      },
    ),

    GoRoute(
      path: RoutePaths.editProfile,
      name: RouteNames.editProfile,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return _buildAdaptivePage<void>(
          state: state,
          child: const EditProfilePage(),
        );
      },
    ),

    GoRoute(
      path: RoutePaths.completeProfile,
      name: RouteNames.completeProfile,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return _buildAdaptivePage<void>(
          state: state,
          child: const CompleteProfilePage(),
        );
      },
    ),
              _buildRoute(
                path: RoutePaths.favorites,
                name: RouteNames.favorites,
                title: 'Favorites',
                subtitle: 'Your saved places and experiences',
                icon: Icons.favorite_rounded,
              ),

              _buildRoute(
                path: RoutePaths.history,
                name: RouteNames.history,
                title: 'History',
                subtitle: 'Review your recent activity',
                icon: Icons.history_rounded,
              ),

              _buildRoute(
                path: RoutePaths.settings,
                name: RouteNames.settings,
                title: 'Settings',
                subtitle: 'Customize your Sarthee AI experience',
                icon: Icons.settings_rounded,
              ),
            ],
          ),
        ],
      ),

      // =======================================================================
      // SUPPORTING ROUTES
      // =======================================================================
      GoRoute(
        path: RoutePaths.weather,
        name: RouteNames.weather,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildAdaptivePage<void>(
            state: state,
            child: const LocationPage(),
          );
        },
      ),

      _buildRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        title: 'Notifications',
        subtitle: 'Travel updates, reminders and alerts',
        icon: Icons.notifications_rounded,
      ),

      GoRoute(
        path: RoutePaths.safety,
        name: RouteNames.safety,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildAdaptivePage<void>(
            state: state,
            child: const EmergencyPage(),
          );
        },
      ),

      GoRoute(
        path: RoutePaths.emergency,
        name: RouteNames.emergency,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildAdaptivePage<void>(
            state: state,
            child: const EmergencyPage(),
          );
        },
      ),

      GoRoute(
        path: '/admin',
        name: 'adminDashboard',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildAdaptivePage<void>(
            state: state,
            child: const AdminDashboardPage(),
          );
        },
      ),


      _buildRoute(
        path: RoutePaths.budget,
        name: RouteNames.budget,
        title: 'Budget',
        subtitle: 'Manage your travel expenses',
        icon: Icons.account_balance_wallet_rounded,
      ),

      // =======================================================================
      // SYSTEM ROUTES
      // =======================================================================
      _buildSystemRoute(
        path: RoutePaths.offline,
        name: RouteNames.offline,
        title: 'You are offline',
        subtitle: 'Some Sarthee AI features require an internet connection.',
        icon: Icons.wifi_off_rounded,
      ),

      _buildSystemRoute(
        path: RoutePaths.maintenance,
        name: RouteNames.maintenance,
        title: 'Maintenance',
        subtitle: 'Sarthee AI is temporarily undergoing maintenance.',
        icon: Icons.engineering_rounded,
      ),

      _buildSystemRoute(
        path: RoutePaths.updateRequired,
        name: RouteNames.updateRequired,
        title: 'Update Required',
        subtitle: 'Please update Sarthee AI to continue.',
        icon: Icons.system_update_rounded,
      ),

      _buildSystemRoute(
        path: RoutePaths.error,
        name: RouteNames.error,
        title: 'Something went wrong',
        subtitle: 'Sarthee AI encountered an unexpected problem.',
        icon: Icons.error_outline_rounded,
      ),
    ],

    // =========================================================================
    // GLOBAL ROUTER ERROR PAGE
    // =========================================================================
    errorPageBuilder: (BuildContext context, GoRouterState state) {
      return MaterialPage<void>(
        key: state.pageKey,
        name: 'router-error',
        child: SartheeRouteErrorPage(
          location: state.uri.toString(),
          error: state.error,
        ),
      );
    },
  );

  // Router lifecycle follows Riverpod provider lifecycle.
  ref.onDispose(router.dispose);

  return router;
});

// =============================================================================
// SPLASH PAGE BUILDER
// =============================================================================

Page<void> _buildSplashPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,

    transitionDuration: const Duration(milliseconds: 350),

    reverseTransitionDuration: const Duration(milliseconds: 220),

    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          // Respect reduced-motion accessibility preferences.
          final bool disableAnimations =
              MediaQuery.maybeOf(context)?.disableAnimations ?? false;

          if (disableAnimations) {
            return child;
          }

          final Animation<double> fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          final Animation<double> scaleAnimation = Tween<double>(
            begin: 0.985,
            end: 1.0,
          ).animate(fadeAnimation);

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(scale: scaleAnimation, child: child),
          );
        },
  );
}

// =============================================================================
// STANDARD ROUTE BUILDER
// =============================================================================

GoRoute _buildRoute({
  required String path,
  required String name,
  required String title,
  required IconData icon,
  String? subtitle,
}) {
  return GoRoute(
    path: path,
    name: name,

    pageBuilder: (BuildContext context, GoRouterState state) {
      return _buildAdaptivePage<void>(
        state: state,
        child: SartheeRoutePlaceholderPage(
          title: title,
          subtitle: subtitle,
          icon: icon,
          routePath: state.uri.toString(),
        ),
      );
    },
  );
}

// =============================================================================
// SYSTEM ROUTE BUILDER
// =============================================================================

GoRoute _buildSystemRoute({
  required String path,
  required String name,
  required String title,
  required String subtitle,
  required IconData icon,
}) {
  return GoRoute(
    path: path,
    name: name,

    pageBuilder: (BuildContext context, GoRouterState state) {
      return _buildAdaptivePage<void>(
        state: state,
        child: SartheeSystemRoutePage(
          title: title,
          subtitle: subtitle,
          icon: icon,
        ),
      );
    },
  );
}

// =============================================================================
// ADAPTIVE PAGE TRANSITIONS
// =============================================================================

Page<T> _buildAdaptivePage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    name: state.name,
    child: child,

    transitionDuration: const Duration(milliseconds: 260),

    reverseTransitionDuration: const Duration(milliseconds: 220),

    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final bool disableAnimations =
              MediaQuery.maybeOf(context)?.disableAnimations ?? false;

          if (disableAnimations) {
            return child;
          }

          final Animation<double> curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          final Animation<Offset> offsetAnimation = Tween<Offset>(
            begin: const Offset(0.025, 0),
            end: Offset.zero,
          ).animate(curvedAnimation);

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
  );
}

// =============================================================================
// TEMPORARY FEATURE PLACEHOLDER
// =============================================================================
//
// These pages are intentionally temporary.
//
// As each feature receives its real presentation page, replace:
//
// _buildRoute(...)
//
// with:
//
// GoRoute(
//   ...
//   builder: (...) => const ActualFeaturePage(),
// )
//
// without changing the global router architecture.
// =============================================================================

class SartheeRoutePlaceholderPage extends StatelessWidget {
  const SartheeRoutePlaceholderPage({
    required this.title,
    required this.icon,
    required this.routePath,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String routePath;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // -----------------------------------------------------------
                  // ICON
                  // -----------------------------------------------------------
                  Container(
                    width: 88,
                    height: 88,

                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),

                    child: Icon(
                      icon,
                      size: 42,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // -----------------------------------------------------------
                  // TITLE
                  // -----------------------------------------------------------
                  Text(
                    title,
                    textAlign: TextAlign.center,

                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // -----------------------------------------------------------
                  // SUBTITLE
                  // -----------------------------------------------------------
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),

                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,

                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // -----------------------------------------------------------
                  // FOUNDATION STATUS
                  // -----------------------------------------------------------
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(100),
                    ),

                    child: Text(
                      'Feature foundation ready',
                      style: theme.textTheme.labelLarge,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -----------------------------------------------------------
                  // ROUTE DEBUG INFO
                  // -----------------------------------------------------------
                  Text(
                    routePath,
                    textAlign: TextAlign.center,

                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SYSTEM PAGE
// =============================================================================

class SartheeSystemRoutePage extends StatelessWidget {
  const SartheeSystemRoutePage({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 72, color: colorScheme.primary),

                  const SizedBox(height: 24),

                  Text(
                    title,
                    textAlign: TextAlign.center,

                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,

                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 32),

                  FilledButton.icon(
                    onPressed: () {
                      context.go(RoutePaths.home);
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to Sarthee AI'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ROUTER ERROR PAGE
// =============================================================================

class SartheeRouteErrorPage extends StatelessWidget {
  const SartheeRouteErrorPage({required this.location, this.error, super.key});

  final String location;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.travel_explore_rounded,
                    size: 72,
                    color: colorScheme.primary,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Page not found',
                    textAlign: TextAlign.center,

                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Sarthee AI could not find this destination.',
                    textAlign: TextAlign.center,

                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    location,
                    textAlign: TextAlign.center,

                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),

                  const SizedBox(height: 32),

                  FilledButton.icon(
                    onPressed: () {
                      context.go(RoutePaths.home);
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to Sarthee AI'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// NAVIGATION EXTENSIONS
// =============================================================================
//
// Centralized semantic navigation helpers.
//
// Feature code can use:
//
// context.goHome();
// context.goToAIChat();
// context.goToDestinations();
//
// instead of manually knowing route paths.
// =============================================================================

extension SartheeNavigationX on BuildContext {
  // ---------------------------------------------------------------------------
  // PRIMARY
  // ---------------------------------------------------------------------------

  void goHome() {
    goNamed(RouteNames.home);
  }

  void goToAIChat() {
    goNamed(RouteNames.aiChat);
  }

  void goToDestinations() {
    goNamed(RouteNames.destinations);
  }

  // ---------------------------------------------------------------------------
  // DISCOVERY
  // ---------------------------------------------------------------------------

  void goToCulture() {
    goNamed(RouteNames.culture);
  }

  void goToFood() {
    goNamed(RouteNames.food);
  }

  void goToHotels() {
    goNamed(RouteNames.hotels);
  }

  // ---------------------------------------------------------------------------
  // TRAVEL
  // ---------------------------------------------------------------------------

  void goToTripPlanner() {
    goNamed(RouteNames.tripPlanner);
  }

  void goToNavigation() {
    goNamed(RouteNames.navigation);
  }

  void goToWeather() {
    goNamed(RouteNames.weather);
  }

  // ---------------------------------------------------------------------------
  // USER
  // ---------------------------------------------------------------------------

  void goToFavorites() {
    goNamed(RouteNames.favorites);
  }

  void goToHistory() {
    goNamed(RouteNames.history);
  }

  void goToNotifications() {
    goNamed(RouteNames.notifications);
  }

  void goToProfile() {
    goNamed(RouteNames.profile);
  }

  void goToSettings() {
    goNamed(RouteNames.settings);
  }

  // ---------------------------------------------------------------------------
  // AUTHENTICATION
  // ---------------------------------------------------------------------------

  void goToLogin() {
    goNamed(RouteNames.login);
  }

  void goToRegister() {
    goNamed(RouteNames.register);
  }

  void goToForgotPassword() {
    goNamed(RouteNames.forgotPassword);
  }

  // ---------------------------------------------------------------------------
  // SAFETY / BUDGET
  // ---------------------------------------------------------------------------

  void goToSafety() {
    goNamed(RouteNames.safety);
  }

  void goToBudget() {
    goNamed(RouteNames.budget);
  }

  // ---------------------------------------------------------------------------
  // SAFE BACK
  // ---------------------------------------------------------------------------

  void goBackSafely() {
    if (canPop()) {
      pop();
      return;
    }

    goHome();
  }
}
