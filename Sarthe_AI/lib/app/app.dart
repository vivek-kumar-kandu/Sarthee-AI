import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import 'router/app_router.dart';

/// ============================================================================
/// SARTHEE AI — ROOT APPLICATION
/// ============================================================================
///
/// Production-level root widget for Sarthee AI.
///
/// Responsibilities:
///
/// • Material 3 application configuration
/// • Riverpod integration
/// • GoRouter integration
/// • Light / Dark / System theme support
/// • Persistent theme preference
/// • Localization foundation
/// • Locale resolution
/// • Accessibility-safe text scaling
/// • Global application wrappers
///
/// Navigation architecture:
///
/// SartheeApp
///   ↓
/// MaterialApp.router
///   ↓
/// appRouterProvider
///   ↓
/// GoRouter
///   ↓
/// Root Redirect
///   ├── Splash
///   ├── Onboarding
///   ├── Authentication
///   │
///   └── StatefulShellRoute.indexedStack
///       ├── Home
///       ├── Explore
///       ├── Sarthee AI
///       ├── Trips
///       └── Profile
///
/// Business logic and feature-specific UI must never be placed here.
class SartheeApp extends ConsumerWidget {
  const SartheeApp({super.key});

  // ==========================================================================
  // APPLICATION METADATA
  // ==========================================================================

  static const String appTitle = 'Sarthee AI';

  // ==========================================================================
  // LOCALIZATION CONFIGURATION
  // ==========================================================================

  static const Locale fallbackLocale = Locale('en');

  static const List<Locale> supportedAppLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  static const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ------------------------------------------------------------------------
    // THEME
    // ------------------------------------------------------------------------
    //
    // Watch only ThemeMode instead of the entire ThemeState.
    //
    // This prevents unnecessary root-level rebuilds when unrelated properties
    // such as persistence status or error state change.

    final ThemeMode themeMode = ref.watch(themeModeProvider);

    // ------------------------------------------------------------------------
    // ROUTER
    // ------------------------------------------------------------------------
    //
    // GoRouter is managed by Riverpod.
    //
    // This allows the routing layer to react to:
    //
    // • authentication
    // • onboarding
    // • maintenance mode
    // • forced updates
    // • connectivity
    // • session state
    //
    // without coupling those concerns to SartheeApp.

    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // ======================================================================
      // APPLICATION IDENTITY
      // ======================================================================
      title: appTitle,

      debugShowCheckedModeBanner: false,

      // ======================================================================
      // ROUTER
      // ======================================================================
      routerConfig: router,

      // ======================================================================
      // MATERIAL 3 THEME
      // ======================================================================
      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: themeMode,

      // ======================================================================
      // LOCALIZATION
      // ======================================================================
      supportedLocales: supportedAppLocales,

      localizationsDelegates: appLocalizationsDelegates,

      localeResolutionCallback: _resolveLocale,

      // ======================================================================
      // GLOBAL APPLICATION BUILDER
      // ======================================================================
      //
      // Keep global presentation-level behavior here.
      //
      // Suitable future additions:
      //
      // • connectivity banner
      // • maintenance overlay
      // • update-required overlay
      // • global loading overlay
      // • session-expired overlay
      // • accessibility wrappers
      // • analytics wrappers
      // • lifecycle wrappers
      //
      // Do not place feature-specific UI here.
      builder: _buildApplicationRoot,
    );
  }

  // ==========================================================================
  // APPLICATION ROOT BUILDER
  // ==========================================================================

  static Widget _buildApplicationRoot(BuildContext context, Widget? child) {
    return _AppRoot(child: child ?? const SizedBox.shrink());
  }

  // ==========================================================================
  // LOCALE RESOLUTION
  // ==========================================================================

  /// Resolves the most appropriate application locale.
  ///
  /// Resolution strategy:
  ///
  /// 1. Use device locale when supported.
  /// 2. Match using language code.
  /// 3. Fall back safely to English.
  static Locale _resolveLocale(
    Locale? deviceLocale,
    Iterable<Locale> supportedLocales,
  ) {
    if (deviceLocale == null) {
      return fallbackLocale;
    }

    // ------------------------------------------------------------------------
    // EXACT MATCH
    // ------------------------------------------------------------------------

    for (final Locale supportedLocale in supportedLocales) {
      if (supportedLocale == deviceLocale) {
        return supportedLocale;
      }
    }

    // ------------------------------------------------------------------------
    // LANGUAGE MATCH
    // ------------------------------------------------------------------------
    //
    // Example:
    //
    // Device:
    // en_IN
    //
    // Supported:
    // en
    //
    // Result:
    // en

    for (final Locale supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == deviceLocale.languageCode) {
        return supportedLocale;
      }
    }

    return fallbackLocale;
  }
}

// ============================================================================
// GLOBAL APPLICATION ROOT
// ============================================================================

/// Global wrapper around the application's Navigator tree.
///
/// This widget intentionally remains independent from GoRouter.
///
/// It provides a single controlled location for application-wide presentation
/// and accessibility behavior.
class _AppRoot extends StatelessWidget {
  const _AppRoot({required this.child});

  final Widget child;

  // ==========================================================================
  // ACCESSIBILITY CONFIGURATION
  // ==========================================================================

  static const double minimumTextScaleFactor = 0.8;

  static const double maximumTextScaleFactor = 2.0;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: minimumTextScaleFactor,
      maxScaleFactor: maximumTextScaleFactor,
      child: child,
    );
  }
}
