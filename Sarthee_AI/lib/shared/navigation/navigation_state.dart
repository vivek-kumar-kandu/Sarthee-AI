import 'package:flutter/foundation.dart';

import 'navigation_config.dart';

/// Immutable state model for Sarthee AI primary navigation.
///
/// This state intentionally stores UI/navigation metadata only.
///
/// Actual route navigation and independent branch stacks are owned by:
///
/// GoRouter
///   → StatefulShellRoute.indexedStack
///   → StatefulNavigationShell
///
/// Responsibilities:
///
/// • Current primary branch
/// • Previous primary branch
/// • Navigation interaction state
/// • Safe immutable state transitions
/// • State comparison
/// • Debug diagnostics
@immutable
class NavigationState {
  const NavigationState({
    required this.selectedIndex,
    required this.previousIndex,
    required this.isNavigationEnabled,
  });

  /// Default navigation state.
  ///
  /// Sarthee AI always starts with Home as the primary branch.
  const NavigationState.initial()
    : selectedIndex = NavigationConfig.homeIndex,
      previousIndex = NavigationConfig.homeIndex,
      isNavigationEnabled = true;

  // ===========================================================================
  // STATE
  // ===========================================================================

  /// Currently selected StatefulShellBranch index.
  final int selectedIndex;

  /// Previously selected StatefulShellBranch index.
  ///
  /// This is always a valid branch index.
  final int previousIndex;

  /// Whether the user may currently change primary navigation branches.
  ///
  /// This does not disable GoRouter itself.
  /// It only controls user-driven primary navigation interaction.
  final bool isNavigationEnabled;

  // ===========================================================================
  // DERIVED STATE
  // ===========================================================================

  /// Whether Home is currently selected.
  bool get isHomeSelected => selectedIndex == NavigationConfig.homeIndex;

  /// Whether Explore is currently selected.
  bool get isExploreSelected => selectedIndex == NavigationConfig.exploreIndex;

  /// Whether Sarthee AI is currently selected.
  bool get isAISelected => selectedIndex == NavigationConfig.aiIndex;

  /// Whether Trips is currently selected.
  bool get isTripsSelected => selectedIndex == NavigationConfig.tripsIndex;

  /// Whether Profile is currently selected.
  bool get isProfileSelected => selectedIndex == NavigationConfig.profileIndex;

  /// Whether the selected branch differs from the previous branch.
  bool get hasPreviousDestination => previousIndex != selectedIndex;

  /// Whether primary navigation interaction is currently blocked.
  bool get isNavigationLocked => !isNavigationEnabled;

  // ===========================================================================
  // COPY
  // ===========================================================================

  NavigationState copyWith({
    int? selectedIndex,
    int? previousIndex,
    bool? isNavigationEnabled,
  }) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      previousIndex: previousIndex ?? this.previousIndex,
      isNavigationEnabled: isNavigationEnabled ?? this.isNavigationEnabled,
    );
  }

  // ===========================================================================
  // FACTORIES
  // ===========================================================================

  /// Creates a safe state for a specific branch.
  ///
  /// Invalid indexes automatically fall back to Home.
  factory NavigationState.forIndex(
    int index, {
    bool isNavigationEnabled = true,
  }) {
    final int safeIndex = NavigationConfig.isValidIndex(index)
        ? index
        : NavigationConfig.homeIndex;

    return NavigationState(
      selectedIndex: safeIndex,
      previousIndex: NavigationConfig.homeIndex,
      isNavigationEnabled: isNavigationEnabled,
    );
  }

  // ===========================================================================
  // VALIDATION
  // ===========================================================================

  /// Whether this state contains valid primary-navigation indexes.
  bool get isValid =>
      NavigationConfig.isValidIndex(selectedIndex) &&
      NavigationConfig.isValidIndex(previousIndex);

  /// Returns a corrected state if an invalid index somehow enters the state.
  NavigationState normalized() {
    final int safeSelectedIndex = NavigationConfig.isValidIndex(selectedIndex)
        ? selectedIndex
        : NavigationConfig.homeIndex;

    final int safePreviousIndex = NavigationConfig.isValidIndex(previousIndex)
        ? previousIndex
        : NavigationConfig.homeIndex;

    if (safeSelectedIndex == selectedIndex &&
        safePreviousIndex == previousIndex) {
      return this;
    }

    return NavigationState(
      selectedIndex: safeSelectedIndex,
      previousIndex: safePreviousIndex,
      isNavigationEnabled: isNavigationEnabled,
    );
  }

  // ===========================================================================
  // EQUALITY
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is NavigationState &&
        other.selectedIndex == selectedIndex &&
        other.previousIndex == previousIndex &&
        other.isNavigationEnabled == isNavigationEnabled;
  }

  @override
  int get hashCode =>
      Object.hash(selectedIndex, previousIndex, isNavigationEnabled);

  // ===========================================================================
  // DEBUGGING
  // ===========================================================================

  @override
  String toString() {
    return 'NavigationState('
        'selectedIndex: $selectedIndex, '
        'previousIndex: $previousIndex, '
        'isNavigationEnabled: $isNavigationEnabled'
        ')';
  }
}
