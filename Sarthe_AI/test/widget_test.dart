import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sarthee_ai/app/app.dart';
import 'package:sarthee_ai/app/router/app_router.dart';
import 'package:sarthee_ai/app/router/route_guards.dart';
import 'package:sarthee_ai/core/theme/theme_controller.dart';
import 'package:sarthee_ai/shared/navigation/app_bottom_nav.dart';
import 'package:sarthee_ai/shared/navigation/app_navigation_rail.dart';
import 'package:sarthee_ai/shared/navigation/responsive_navigation.dart';

late SharedPreferences _sharedPreferences;

const RouteGuardState _testRouteGuardState = RouteGuardState(
  authenticationStatus: AuthenticationStatus.authenticated,
  onboardingCompleted: true,
  isMaintenanceMode: false,
  isUpdateRequired: false,
  isOnline: true,
  isInitialized: true,
  isProfileComplete: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    _sharedPreferences = await SharedPreferences.getInstance();
  });

  group('Sarthee AI — Application Foundation', () {
    // =========================================================================
    // APPLICATION BOOTSTRAP
    // =========================================================================

    testWidgets('boots successfully without framework exceptions', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(390, 844));

      await _pumpSartheeApp(tester);

      expect(
        find.byType(SartheeApp),
        findsOneWidget,
        reason: 'SartheeApp must be mounted exactly once.',
      );

      _expectNoException(
        tester,
        reason: 'Application startup must complete without exceptions.',
      );
    });

    // =========================================================================
    // MATERIAL APPLICATION
    // =========================================================================

    testWidgets('creates the Material application foundation', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(390, 844));

      await _pumpSartheeApp(tester);

      final Finder materialAppFinder = find.byType(MaterialApp);

      expect(
        materialAppFinder,
        findsOneWidget,
        reason: 'SartheeApp must create exactly one MaterialApp.',
      );

      final MaterialApp app = tester.widget<MaterialApp>(materialAppFinder);

      expect(app.title, SartheeApp.appTitle);

      expect(app.debugShowCheckedModeBanner, isFalse);

      _expectNoException(tester);
    });

    // =========================================================================
    // APPLICATION IDENTITY
    // =========================================================================

    testWidgets('exposes the Sarthee AI application identity', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(390, 844));

      await _pumpSartheeApp(tester);

      expect(SartheeApp.appTitle, 'Sarthee AI');

      expect(
        find.text('Sarthee AI'),
        findsAtLeastNWidgets(1),
        reason: 'Sarthee AI branding must be available after startup.',
      );

      _expectNoException(tester);
    });

    // =========================================================================
    // STARTUP ROUTING
    // =========================================================================

    testWidgets('completes bootstrap and renders application content', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(390, 844));

      await _pumpSartheeApp(tester);

      expect(
        find.byType(Scaffold),
        findsAtLeastNWidgets(1),
        reason: 'Splash/bootstrap must eventually render application content.',
      );

      expect(find.text('Sarthee AI'), findsAtLeastNWidgets(1));

      _expectNoException(
        tester,
        reason:
            'Splash-to-application routing must complete without exceptions.',
      );
    });

    // =========================================================================
    // RESPONSIVE ENGINE — PURE BREAKPOINTS
    // =========================================================================

    test('responsive breakpoints classify widths correctly', () {
      expect(ResponsiveNavigation.fromWidth(0), NavigationLayout.compact);

      expect(ResponsiveNavigation.fromWidth(390), NavigationLayout.compact);

      expect(ResponsiveNavigation.fromWidth(599), NavigationLayout.compact);

      expect(ResponsiveNavigation.fromWidth(600), NavigationLayout.medium);

      expect(ResponsiveNavigation.fromWidth(700), NavigationLayout.medium);

      expect(ResponsiveNavigation.fromWidth(839), NavigationLayout.medium);

      expect(ResponsiveNavigation.fromWidth(840), NavigationLayout.expanded);

      expect(ResponsiveNavigation.fromWidth(1280), NavigationLayout.expanded);

      expect(ResponsiveNavigation.fromWidth(1920), NavigationLayout.expanded);
    });

    // =========================================================================
    // WINDOW CLASSIFICATION
    // =========================================================================

    test('advanced window classes follow configured breakpoints', () {
      expect(
        ResponsiveNavigation.windowClassFromWidth(390),
        ResponsiveWindowClass.compact,
      );

      expect(
        ResponsiveNavigation.windowClassFromWidth(700),
        ResponsiveWindowClass.medium,
      );

      expect(
        ResponsiveNavigation.windowClassFromWidth(900),
        ResponsiveWindowClass.expanded,
      );

      expect(
        ResponsiveNavigation.windowClassFromWidth(1280),
        ResponsiveWindowClass.large,
      );

      expect(
        ResponsiveNavigation.windowClassFromWidth(1920),
        ResponsiveWindowClass.extraLarge,
      );
    });

    // =========================================================================
    // COMPACT / MOBILE
    // =========================================================================

    testWidgets('uses bottom navigation on compact mobile viewport', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(390, 844));

      await _pumpSartheeApp(tester);

      expect(
        _logicalViewSize(tester).width,
        390,
        reason: 'The test harness must expose the requested logical width.',
      );

      expect(
        find.byType(AppBottomNavigation),
        findsOneWidget,
        reason: 'Compact layouts must render AppBottomNavigation.',
      );

      expect(
        find.byType(NavigationBar),
        findsOneWidget,
        reason: 'AppBottomNavigation must render a Material NavigationBar.',
      );

      expect(
        find.byType(AppNavigationRail),
        findsNothing,
        reason: 'Compact layouts must not render AppNavigationRail.',
      );

      expect(find.byType(NavigationRail), findsNothing);

      _expectNoException(
        tester,
        reason: 'Compact navigation must render without exceptions.',
      );
    });

    // =========================================================================
    // MEDIUM / TABLET
    // =========================================================================

    testWidgets('uses compact navigation rail on medium viewport', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(700, 1024));

      await _pumpSartheeApp(tester);

      expect(_logicalViewSize(tester).width, 700);

      expect(
        find.byType(AppBottomNavigation),
        findsNothing,
        reason: 'Medium layouts must not render bottom navigation.',
      );

      expect(
        find.byType(AppNavigationRail),
        findsOneWidget,
        reason: 'Medium layouts must render AppNavigationRail.',
      );

      expect(find.byType(NavigationRail), findsOneWidget);

      final AppNavigationRail appRail = tester.widget<AppNavigationRail>(
        find.byType(AppNavigationRail),
      );

      expect(
        appRail.extended,
        isFalse,
        reason: 'Medium layouts must use the compact navigation rail.',
      );

      final NavigationRail materialRail = tester.widget<NavigationRail>(
        find.byType(NavigationRail),
      );

      expect(materialRail.extended, isFalse);

      _expectNoException(
        tester,
        reason: 'Medium navigation must render without exceptions.',
      );
    });

    // =========================================================================
    // EXPANDED / DESKTOP
    // =========================================================================

    testWidgets('uses extended navigation rail on desktop viewport', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(1280, 900));

      await _pumpSartheeApp(tester);

      expect(_logicalViewSize(tester).width, 1280);

      expect(find.byType(AppBottomNavigation), findsNothing);

      expect(
        find.byType(AppNavigationRail),
        findsOneWidget,
        reason: 'Expanded layouts must render AppNavigationRail.',
      );

      final AppNavigationRail appRail = tester.widget<AppNavigationRail>(
        find.byType(AppNavigationRail),
      );

      expect(
        appRail.extended,
        isTrue,
        reason: 'Expanded layouts must enable the extended rail.',
      );

      final NavigationRail materialRail = tester.widget<NavigationRail>(
        find.byType(NavigationRail),
      );

      expect(materialRail.extended, isTrue);

      _expectNoException(
        tester,
        reason: 'Desktop navigation must render without exceptions.',
      );
    });

    // =========================================================================
    // EXTRA-LARGE
    // =========================================================================

    testWidgets('remains extended on extra-large viewport', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(1920, 1080));

      await _pumpSartheeApp(tester);

      expect(_logicalViewSize(tester).width, 1920);

      expect(find.byType(AppNavigationRail), findsOneWidget);

      final AppNavigationRail appRail = tester.widget<AppNavigationRail>(
        find.byType(AppNavigationRail),
      );

      expect(appRail.extended, isTrue);

      expect(find.byType(NavigationBar), findsNothing);

      _expectNoException(
        tester,
        reason: 'Extra-large navigation must render without exceptions.',
      );
    });

    // =========================================================================
    // RESPONSIVE TRANSITION
    // =========================================================================

    testWidgets('adapts from compact navigation to expanded navigation', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(390, 844));

      await _pumpSartheeApp(tester);

      expect(find.byType(AppBottomNavigation), findsOneWidget);

      expect(find.byType(AppNavigationRail), findsNothing);

      // ---------------------------------------------------------------------
      // MOBILE → DESKTOP
      // ---------------------------------------------------------------------

      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pump();
      await tester.pumpAndSettle();

      expect(_logicalViewSize(tester).width, 1280);

      expect(
        find.byType(AppBottomNavigation),
        findsNothing,
        reason:
            'Bottom navigation must disappear after expanding the viewport.',
      );

      expect(
        find.byType(AppNavigationRail),
        findsOneWidget,
        reason: 'Navigation rail must appear after expanding the viewport.',
      );

      final AppNavigationRail rail = tester.widget<AppNavigationRail>(
        find.byType(AppNavigationRail),
      );

      expect(
        rail.extended,
        isTrue,
        reason: 'The rail must become extended on desktop width.',
      );

      _expectNoException(
        tester,
        reason: 'Responsive navigation transitions must remain stable.',
      );
    });

    // =========================================================================
    // BREAKPOINT BOUNDARIES
    // =========================================================================

    testWidgets('switches from bottom navigation to rail at 600px', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(599, 800));

      await _pumpSartheeApp(tester);

      expect(find.byType(AppBottomNavigation), findsOneWidget);

      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomNavigation), findsNothing);

      expect(find.byType(AppNavigationRail), findsOneWidget);

      final AppNavigationRail rail = tester.widget<AppNavigationRail>(
        find.byType(AppNavigationRail),
      );

      expect(
        rail.extended,
        isFalse,
        reason: '600px is the beginning of the medium layout.',
      );

      _expectNoException(tester);
    });

    testWidgets('extends the navigation rail at 840px', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(839, 900));

      await _pumpSartheeApp(tester);

      final AppNavigationRail mediumRail = tester.widget<AppNavigationRail>(
        find.byType(AppNavigationRail),
      );

      expect(mediumRail.extended, isFalse);

      tester.view.physicalSize = const Size(840, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pump();
      await tester.pumpAndSettle();

      final AppNavigationRail expandedRail = tester.widget<AppNavigationRail>(
        find.byType(AppNavigationRail),
      );

      expect(
        expandedRail.extended,
        isTrue,
        reason: '840px is the beginning of the expanded layout.',
      );

      _expectNoException(tester);
    });

    // =========================================================================
    // NAVIGATION RAIL REGRESSION
    // =========================================================================

    testWidgets('uses a valid Material NavigationRail elevation', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(1280, 900));

      await _pumpSartheeApp(tester);

      final Finder railFinder = find.byType(NavigationRail);

      expect(railFinder, findsOneWidget);

      final NavigationRail rail = tester.widget<NavigationRail>(railFinder);

      expect(
        rail.elevation == null || rail.elevation! > 0,
        isTrue,
        reason: 'NavigationRail elevation must be null or greater than zero.',
      );

      expect(rail.destinations, isNotEmpty);

      expect(rail.selectedIndex, isNotNull);

      _expectNoException(
        tester,
        reason: 'Material NavigationRail configuration must remain valid.',
      );
    });

    // =========================================================================
    // PRIMARY DESTINATIONS
    // =========================================================================

    testWidgets('exposes primary navigation destinations on mobile', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(390, 844));

      await _pumpSartheeApp(tester);

      expect(find.byType(NavigationDestination), findsAtLeastNWidgets(1));

      expect(find.text('Home'), findsAtLeastNWidgets(1));

      _expectNoException(tester);
    });

    // =========================================================================
    // SEMANTICS
    // =========================================================================

    testWidgets('builds a valid semantic application tree', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(390, 844));

      final SemanticsHandle semantics = tester.ensureSemantics();

      try {
        await _pumpSartheeApp(tester);

        expect(find.byType(SartheeApp), findsOneWidget);

        expect(find.byType(Scaffold), findsAtLeastNWidgets(1));

        expect(find.byType(AppBottomNavigation), findsOneWidget);

        _expectNoException(
          tester,
          reason: 'Application semantics must build without exceptions.',
        );
      } finally {
        semantics.dispose();
      }
    });

    // =========================================================================
    // MULTI-FRAME STABILITY
    // =========================================================================

    testWidgets('remains stable across multiple rendered frames', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(390, 844));

      await _pumpSartheeApp(tester);

      await tester.pump();

      await tester.pump(const Duration(milliseconds: 50));

      await tester.pump(const Duration(milliseconds: 100));

      await tester.pump(const Duration(milliseconds: 250));

      await tester.pumpAndSettle();

      expect(find.byType(SartheeApp), findsOneWidget);

      expect(find.text('Sarthee AI'), findsAtLeastNWidgets(1));

      _expectNoException(
        tester,
        reason: 'Application must remain stable across rendered frames.',
      );
    });

    // =========================================================================
    // REBUILD STABILITY
    // =========================================================================

    testWidgets('survives application rebuilds safely', (
      WidgetTester tester,
    ) async {
      await _configureViewport(tester, const Size(390, 844));

      await _pumpSartheeApp(tester);

      expect(find.byType(SartheeApp), findsOneWidget);

      await tester.pump();

      await tester.pump(const Duration(milliseconds: 16));

      await tester.pumpAndSettle();

      expect(find.byType(SartheeApp), findsOneWidget);

      _expectNoException(
        tester,
        reason: 'Application rebuilds must remain exception-free.',
      );
    });
  });
}

// =============================================================================
// APPLICATION TEST HARNESS
// =============================================================================

/// Mounts the complete Sarthee AI application inside its Riverpod root.
///
/// The helper waits for:
///
/// • initial widget construction
/// • Riverpod initialization
/// • GoRouter initialization
/// • splash/bootstrap processing
/// • redirect processing
/// • AppShell rendering
/// • scheduled frames
Future<void> _pumpSartheeApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(_sharedPreferences),
        routeGuardStateProvider.overrideWithValue(_testRouteGuardState),
      ],
      child: const SartheeApp(),
    ),
  );

  await _settleApplication(tester);
}

/// Gives startup/bootstrap work deterministic time to complete.
Future<void> _settleApplication(WidgetTester tester) async {
  await tester.pump();

  await tester.pump(const Duration(milliseconds: 50));

  await tester.pump(const Duration(milliseconds: 100));

  await tester.pump(const Duration(milliseconds: 250));

  await tester.pumpAndSettle();
}

// =============================================================================
// VIEWPORT TEST HARNESS
// =============================================================================

/// Configures a deterministic logical viewport.
///
/// Widget tests normally run with framework-controlled view dimensions.
/// Setting both [physicalSize] and [devicePixelRatio] ensures that MediaQuery
/// receives the exact logical dimensions required by responsive tests.
///
/// Example:
///
/// physicalSize      = 390 × 844
/// devicePixelRatio  = 1
///
/// logicalSize       = 390 × 844
Future<void> _configureViewport(WidgetTester tester, Size logicalSize) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = logicalSize;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pump();
}

/// Returns the logical size currently exposed by the test view.
Size _logicalViewSize(WidgetTester tester) {
  final double pixelRatio = tester.view.devicePixelRatio;

  if (pixelRatio <= 0 || !pixelRatio.isFinite) {
    return Size.zero;
  }

  return Size(
    tester.view.physicalSize.width / pixelRatio,
    tester.view.physicalSize.height / pixelRatio,
  );
}

// =============================================================================
// FRAMEWORK ASSERTION UTILITIES
// =============================================================================

/// Verifies that Flutter did not report an uncaught framework exception.
void _expectNoException(
  WidgetTester tester, {
  String reason = 'No Flutter framework exception should be reported.',
}) {
  expect(tester.takeException(), isNull, reason: reason);
}
