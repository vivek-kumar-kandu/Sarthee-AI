import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation_config.dart';
import 'navigation_state.dart';

/// Controls Sarthee AI primary-navigation UI state.
///
/// IMPORTANT:
/// Actual route navigation is owned by GoRouter / StatefulNavigationShell.
///
/// Responsibilities:
/// - selected branch state
/// - previous branch tracking
/// - navigation enable/disable
/// - synchronization with GoRouter
/// - safe index validation
/// - navigation locking during critical operations
class NavigationController extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    return const NavigationState.initial();
  }

  // ===========================================================================
  // DESTINATION SELECTION
  // ===========================================================================

  /// Updates the selected primary destination.
  ///
  /// This method does NOT perform GoRouter navigation.
  /// AppShell performs the actual branch switch using:
  ///
  /// navigationShell.goBranch(...)
  void selectDestination(int index) {
    if (!state.isNavigationEnabled) {
      return;
    }

    if (!NavigationConfig.isValidIndex(index)) {
      return;
    }

    if (index == state.selectedIndex) {
      return;
    }

    state = state.copyWith(
      previousIndex: state.selectedIndex,
      selectedIndex: index,
    );
  }

  // ===========================================================================
  // ROUTER SYNCHRONIZATION
  // ===========================================================================

  /// Synchronizes controller state with StatefulNavigationShell.
  ///
  /// Used when navigation originates outside the bottom navigation UI:
  /// - deep links
  /// - redirects
  /// - programmatic navigation
  /// - restored application state
  ///
  /// Unlike [selectDestination], this synchronization is allowed even when
  /// navigation interaction is temporarily disabled.
  void syncSelectedIndex(int index) {
    if (!NavigationConfig.isValidIndex(index)) {
      return;
    }

    if (index == state.selectedIndex) {
      return;
    }

    state = state.copyWith(
      previousIndex: state.selectedIndex,
      selectedIndex: index,
    );
  }

  /// Synchronizes the controller using a route/location.
  ///
  /// Useful for deep-link handling and future external navigation flows.
  void syncFromLocation(String location) {
    final int index = NavigationConfig.indexForPath(location);

    syncSelectedIndex(index);
  }

  // ===========================================================================
  // PREVIOUS DESTINATION
  // ===========================================================================

  /// Returns whether a previous destination is available.
  bool get hasPreviousDestination {
    return NavigationConfig.isValidIndex(state.previousIndex) &&
        state.previousIndex != state.selectedIndex;
  }

  /// Returns the previous valid destination index.
  ///
  /// Falls back to Home when no previous destination exists.
  int get previousDestinationIndex {
    if (!hasPreviousDestination) {
      return NavigationConfig.homeIndex;
    }

    return state.previousIndex;
  }

  // ===========================================================================
  // NAVIGATION AVAILABILITY
  // ===========================================================================

  /// Enables primary-navigation interaction.
  void enableNavigation() {
    if (state.isNavigationEnabled) {
      return;
    }

    state = state.copyWith(isNavigationEnabled: true);
  }

  /// Temporarily disables primary-navigation interaction.
  ///
  /// Useful during:
  /// - authentication transitions
  /// - checkout/payment flows
  /// - critical saves
  /// - route restoration
  /// - modal workflows
  void disableNavigation() {
    if (!state.isNavigationEnabled) {
      return;
    }

    state = state.copyWith(isNavigationEnabled: false);
  }

  /// Explicitly controls navigation availability.
  void setNavigationEnabled(bool enabled) {
    if (state.isNavigationEnabled == enabled) {
      return;
    }

    state = state.copyWith(isNavigationEnabled: enabled);
  }

  // ===========================================================================
  // NAVIGATION LOCK
  // ===========================================================================

  /// Executes [operation] while primary navigation is disabled.
  ///
  /// Navigation is restored automatically even if the operation throws.
  Future<T> runWithNavigationLocked<T>(Future<T> Function() operation) async {
    final bool wasEnabled = state.isNavigationEnabled;

    if (wasEnabled) {
      disableNavigation();
    }

    try {
      return await operation();
    } finally {
      if (wasEnabled) {
        enableNavigation();
      }
    }
  }

  // ===========================================================================
  // RESET
  // ===========================================================================

  /// Restores navigation to its initial state.
  ///
  /// This resets controller state only.
  /// GoRouter navigation must still be performed by the caller when needed.
  void reset() {
    state = const NavigationState.initial();
  }

  /// Resets the controller to Home while preserving the current navigation
  /// enabled/disabled state.
  void resetToHome() {
    final bool navigationEnabled = state.isNavigationEnabled;

    state = NavigationState(
      selectedIndex: NavigationConfig.homeIndex,
      previousIndex: NavigationConfig.homeIndex,
      isNavigationEnabled: navigationEnabled,
    );
  }
}

// =============================================================================
// PROVIDER
// =============================================================================

final navigationControllerProvider =
    NotifierProvider<NavigationController, NavigationState>(
      NavigationController.new,
    );

// =============================================================================
// SELECTOR PROVIDERS
// =============================================================================

/// Currently selected primary-navigation branch.
final selectedNavigationIndexProvider = Provider<int>((ref) {
  return ref.watch(
    navigationControllerProvider.select((state) => state.selectedIndex),
  );
});

/// Previously selected primary-navigation branch.
final previousNavigationIndexProvider = Provider<int>((ref) {
  return ref.watch(
    navigationControllerProvider.select((state) => state.previousIndex),
  );
});

/// Whether the user can currently interact with primary navigation.
final navigationEnabledProvider = Provider<bool>((ref) {
  return ref.watch(
    navigationControllerProvider.select((state) => state.isNavigationEnabled),
  );
});

/// Currently selected NavigationItem.
final selectedNavigationItemProvider = Provider((ref) {
  final int index = ref.watch(selectedNavigationIndexProvider);

  return NavigationConfig.itemAt(index);
});
