import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav.dart';
import 'app_navigation_rail.dart';
import 'navigation_config.dart';
import 'navigation_controller.dart';
import 'navigation_item.dart';
import 'responsive_navigation.dart';

/// Root adaptive navigation shell for Sarthee AI.
///
/// Designed specifically for:
///
/// [StatefulShellRoute.indexedStack]
///
/// Architecture:
///
/// GoRouter
///   ↓
/// StatefulShellRoute.indexedStack
///   ↓
/// StatefulNavigationShell
///   ↓
/// AppShell
///   ├── Compact  → Bottom Navigation
///   ├── Medium   → NavigationRail
///   └── Expanded → Extended NavigationRail
///
/// Primary application branches:
///
/// 0 → Home
/// 1 → Explore
/// 2 → Sarthee AI
/// 3 → Trips
/// 4 → Profile
///
/// Every branch owns an independent Navigator stack. This means navigation
/// history inside one branch survives when the user switches to another
/// branch.
///
/// Example:
///
/// Explore
///   → Destinations
///   → Destination Details
///
/// Switch:
///
/// Explore → AI → Explore
///
/// Destination Details remains active because GoRouter preserves the Explore
/// branch Navigator.
///
/// Important:
///
/// Branch switching MUST use [StatefulNavigationShell.goBranch].
///
/// Do not replace it with:
///
/// context.go(...)
/// context.goNamed(...)
///
/// for primary branch switching, because doing so defeats the purpose of the
/// independent StatefulShellBranch navigation stacks.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  /// Navigation shell supplied by [StatefulShellRoute.indexedStack].
  ///
  /// This object owns and preserves the Navigator for every primary branch.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only the properties required by the shell.
    //
    // Riverpod's select() prevents unnecessary AppShell rebuilds if additional
    // fields are added to NavigationState in the future.
    final _ShellNavigationState navigationState = ref.watch(
      navigationControllerProvider.select(
        (state) => _ShellNavigationState(
          selectedIndex: state.selectedIndex,
          navigationEnabled: state.isNavigationEnabled,
        ),
      ),
    );

    final List<NavigationItem> items = NavigationConfig.primaryItems;

    final int currentIndex = _safeIndex(
      navigationShell.currentIndex,
      items.length,
    );

    final NavigationLayout layout = ResponsiveNavigation.of(context);

    // Keep Riverpod navigation state synchronized with GoRouter.
    //
    // GoRouter remains the source of truth for the currently active branch.
    _scheduleNavigationStateSynchronization(
      context: context,
      ref: ref,
      routerIndex: currentIndex,
      stateIndex: navigationState.selectedIndex,
    );

    void handleDestinationSelected(int index) {
      _selectDestination(
        ref: ref,
        items: items,
        index: index,
        navigationEnabled: navigationState.navigationEnabled,
      );
    }

    return switch (layout) {
      NavigationLayout.compact => _CompactNavigationLayout(
        navigationShell: navigationShell,
        items: items,
        selectedIndex: currentIndex,
        navigationEnabled: navigationState.navigationEnabled,
        onDestinationSelected: handleDestinationSelected,
      ),

      NavigationLayout.medium => _RailNavigationLayout(
        navigationShell: navigationShell,
        items: items,
        selectedIndex: currentIndex,
        navigationEnabled: navigationState.navigationEnabled,
        onDestinationSelected: handleDestinationSelected,
        extended: false,
      ),

      NavigationLayout.expanded => _RailNavigationLayout(
        navigationShell: navigationShell,
        items: items,
        selectedIndex: currentIndex,
        navigationEnabled: navigationState.navigationEnabled,
        onDestinationSelected: handleDestinationSelected,
        extended: true,
      ),
    };
  }

  // ===========================================================================
  // NAVIGATION STATE SYNCHRONIZATION
  // ===========================================================================

  /// Synchronizes Riverpod's navigation state with GoRouter.
  ///
  /// GoRouter's [StatefulNavigationShell.currentIndex] is treated as the
  /// authoritative branch index.
  ///
  /// Synchronization is deferred until after the current frame because
  /// provider state must not be mutated while Flutter is building widgets.
  void _scheduleNavigationStateSynchronization({
    required BuildContext context,
    required WidgetRef ref,
    required int routerIndex,
    required int stateIndex,
  }) {
    if (routerIndex == stateIndex) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }

      final currentState = ref.read(navigationControllerProvider);

      // The state may already have been synchronized by another rebuild.
      if (currentState.selectedIndex == routerIndex) {
        return;
      }

      ref
          .read(navigationControllerProvider.notifier)
          .syncSelectedIndex(routerIndex);
    });
  }

  // ===========================================================================
  // DESTINATION SELECTION
  // ===========================================================================

  /// Handles switching between primary application branches.
  void _selectDestination({
    required WidgetRef ref,
    required List<NavigationItem> items,
    required int index,
    required bool navigationEnabled,
  }) {
    // -------------------------------------------------------------------------
    // INDEX VALIDATION
    // -------------------------------------------------------------------------

    if (!_isValidIndex(index, items.length)) {
      return;
    }

    // -------------------------------------------------------------------------
    // GLOBAL NAVIGATION LOCK
    // -------------------------------------------------------------------------

    if (!navigationEnabled) {
      return;
    }

    final NavigationItem destination = items[index];

    // -------------------------------------------------------------------------
    // DESTINATION AVAILABILITY
    // -------------------------------------------------------------------------

    if (!destination.isEnabled) {
      return;
    }

    final int currentBranch = navigationShell.currentIndex;

    final bool selectingCurrentBranch = index == currentBranch;

    // -------------------------------------------------------------------------
    // UPDATE APPLICATION NAVIGATION STATE
    // -------------------------------------------------------------------------

    ref.read(navigationControllerProvider.notifier).selectDestination(index);

    // -------------------------------------------------------------------------
    // SWITCH GOROUTER BRANCH
    // -------------------------------------------------------------------------

    /// goBranch() is intentionally used instead of:
    ///
    /// context.go(...)
    /// context.goNamed(...)
    ///
    /// because StatefulShellRoute owns independent Navigator stacks.
    ///
    /// When selecting another branch:
    ///
    /// initialLocation = false
    ///
    /// restores that branch's previous navigation stack.
    ///
    /// When selecting the currently active branch:
    ///
    /// initialLocation = true
    ///
    /// returns the branch to its initial route.
    navigationShell.goBranch(index, initialLocation: selectingCurrentBranch);
  }

  // ===========================================================================
  // INDEX SAFETY
  // ===========================================================================

  bool _isValidIndex(int index, int itemCount) {
    return itemCount > 0 && index >= 0 && index < itemCount;
  }

  int _safeIndex(int index, int itemCount) {
    if (itemCount <= 0) {
      return 0;
    }

    return index.clamp(0, itemCount - 1);
  }
}

// =============================================================================
// SHELL STATE PROJECTION
// =============================================================================

/// Minimal immutable projection of the navigation state required by AppShell.
///
/// Keeping this object small prevents the shell from depending on unrelated
/// navigation state fields.
@immutable
class _ShellNavigationState {
  const _ShellNavigationState({
    required this.selectedIndex,
    required this.navigationEnabled,
  });

  final int selectedIndex;

  final bool navigationEnabled;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _ShellNavigationState &&
            runtimeType == other.runtimeType &&
            selectedIndex == other.selectedIndex &&
            navigationEnabled == other.navigationEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(selectedIndex, navigationEnabled);
  }
}

// =============================================================================
// COMPACT NAVIGATION
// =============================================================================

/// Phone / compact-screen navigation.
///
/// Layout:
///
/// ┌──────────────────────────────┐
/// │                              │
/// │       Branch Navigator       │
/// │                              │
/// ├──────────────────────────────┤
/// │ Material 3 NavigationBar     │
/// └──────────────────────────────┘
class _CompactNavigationLayout extends StatelessWidget {
  const _CompactNavigationLayout({
    required this.navigationShell,
    required this.items,
    required this.selectedIndex,
    required this.navigationEnabled,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell navigationShell;

  final List<NavigationItem> items;

  final int selectedIndex;

  final bool navigationEnabled;

  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,

      // IgnorePointer allows the UI to remain visible while preventing
      // interaction during navigation-critical operations.
      bottomNavigationBar: IgnorePointer(
        ignoring: !navigationEnabled,
        child: AppBottomNavigation(
          items: items,
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
        ),
      ),
    );
  }
}

// =============================================================================
// MEDIUM / EXPANDED NAVIGATION
// =============================================================================

/// Tablet and desktop navigation layout.
///
/// Medium:
///
/// NavigationRail | Content
///
/// Expanded:
///
/// Extended NavigationRail | Content
class _RailNavigationLayout extends StatelessWidget {
  const _RailNavigationLayout({
    required this.navigationShell,
    required this.items,
    required this.selectedIndex,
    required this.navigationEnabled,
    required this.onDestinationSelected,
    required this.extended,
  });

  final StatefulNavigationShell navigationShell;

  final List<NavigationItem> items;

  final int selectedIndex;

  final bool navigationEnabled;

  final ValueChanged<int> onDestinationSelected;

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final double navigationWidth = extended
        ? ResponsiveNavigation.extendedNavigationRailWidth(context)
        : ResponsiveNavigation.navigationRailWidth(context);

    return Scaffold(
      body: Row(
        children: <Widget>[
          // -------------------------------------------------------------------
          // NAVIGATION
          // -------------------------------------------------------------------
          SafeArea(
            right: false,
            child: SizedBox(
              width: navigationWidth,
              child: IgnorePointer(
                ignoring: !navigationEnabled,
                child: AppNavigationRail(
                  items: items,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  extended: extended,
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // SEPARATOR
          // -------------------------------------------------------------------
          const VerticalDivider(width: 1, thickness: 1),

          // -------------------------------------------------------------------
          // ACTIVE BRANCH
          // -------------------------------------------------------------------
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
