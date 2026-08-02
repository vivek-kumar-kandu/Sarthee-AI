import 'package:flutter/material.dart';

import 'navigation_item.dart';

/// ============================================================================
/// SARTHEE AI — COMPACT BOTTOM NAVIGATION
/// ============================================================================
///
/// Production-ready Material 3 bottom navigation for compact/mobile layouts.
///
/// Architecture:
///
/// AppBottomNavigation
///        ↓
/// onDestinationSelected
///        ↓
/// AppShell
///        ↓
/// StatefulNavigationShell.goBranch()
///
/// Responsibilities:
///
/// • Render primary compact/mobile navigation
/// • Maintain safe destination selection
/// • Support enabled/disabled destinations
/// • Support selected/unselected icons
/// • Support notification badges
/// • Support optional tooltips
/// • Provide accessibility semantics
/// • Protect against invalid selected indices
/// • Remain independent from routing/state-management implementations
///
/// This widget intentionally has no dependency on:
///
/// • GoRouter
/// • Riverpod
/// • NavigationController
///
/// Routing remains centralized inside AppShell.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.height,
    this.elevation = 0.0,
    this.showLabels = true,
    this.enableTooltips = true,
    super.key,
  }) : assert(
         height == null || height > 0,
         'NavigationBar height must be null or greater than zero.',
       ),
       assert(elevation >= 0, 'NavigationBar elevation cannot be negative.');

  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================

  /// Primary application navigation destinations.
  final List<NavigationItem> items;

  /// Currently selected shell branch.
  ///
  /// Invalid values are normalized before being supplied to [NavigationBar].
  final int selectedIndex;

  /// Called when the user selects an enabled destination.
  ///
  /// Actual navigation is performed by AppShell.
  final ValueChanged<int> onDestinationSelected;

  /// Optional custom navigation-bar height.
  ///
  /// When null, Material's default NavigationBar height is used.
  final double? height;

  /// Navigation-bar elevation.
  ///
  /// Material NavigationBar supports zero elevation.
  final double elevation;

  /// Controls destination-label visibility.
  final bool showLabels;

  /// Controls destination tooltip availability.
  final bool enableTooltips;

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    // No destinations means there is nothing useful to render.
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final int safeSelectedIndex = _safeSelectedIndex(
      selectedIndex,
      items.length,
    );

    return SafeArea(
      top: false,
      child: NavigationBar(
        // ---------------------------------------------------------------------
        // SELECTION
        // ---------------------------------------------------------------------
        selectedIndex: safeSelectedIndex,

        onDestinationSelected: _handleDestinationSelected,

        // ---------------------------------------------------------------------
        // LAYOUT
        // ---------------------------------------------------------------------
        height: height,

        elevation: elevation,

        // ---------------------------------------------------------------------
        // LABEL BEHAVIOR
        // ---------------------------------------------------------------------
        labelBehavior: showLabels
            ? NavigationDestinationLabelBehavior.alwaysShow
            : NavigationDestinationLabelBehavior.alwaysHide,

        // ---------------------------------------------------------------------
        // DESTINATIONS
        // ---------------------------------------------------------------------
        destinations: List<NavigationDestination>.generate(items.length, (
          int index,
        ) {
          final NavigationItem item = items[index];

          return _buildDestination(item: item);
        }, growable: false),
      ),
    );
  }

  // ===========================================================================
  // DESTINATION
  // ===========================================================================

  NavigationDestination _buildDestination({required NavigationItem item}) {
    return NavigationDestination(
      // -----------------------------------------------------------------------
      // AVAILABILITY
      // -----------------------------------------------------------------------
      enabled: item.isEnabled,

      // -----------------------------------------------------------------------
      // ICONS
      // -----------------------------------------------------------------------
      icon: _buildIcon(item: item, selected: false),

      selectedIcon: _buildIcon(item: item, selected: true),

      // -----------------------------------------------------------------------
      // LABEL
      // -----------------------------------------------------------------------
      label: _resolveLabel(item),

      // -----------------------------------------------------------------------
      // TOOLTIP
      // -----------------------------------------------------------------------
      tooltip: _resolveTooltip(item),
    );
  }

  // ===========================================================================
  // ICON
  // ===========================================================================

  Widget _buildIcon({required NavigationItem item, required bool selected}) {
    Widget icon = Icon(selected ? item.selectedIcon : item.icon);

    // -------------------------------------------------------------------------
    // BADGE
    // -------------------------------------------------------------------------

    if (item.hasBadge) {
      final String badgeLabel = item.badgeLabel.trim();

      icon = Badge(
        isLabelVisible: true,
        label: badgeLabel.isEmpty
            ? null
            : Text(badgeLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
        child: icon,
      );
    }

    // -------------------------------------------------------------------------
    // TOOLTIP
    // -------------------------------------------------------------------------

    final String tooltip = _resolveTooltip(item);

    if (enableTooltips && tooltip.isNotEmpty) {
      icon = Tooltip(message: tooltip, child: icon);
    }

    // -------------------------------------------------------------------------
    // ACCESSIBILITY
    // -------------------------------------------------------------------------

    final String semanticLabel = _resolveSemanticLabel(item);

    return Semantics(
      label: semanticLabel.isEmpty ? null : semanticLabel,
      selected: selected,
      enabled: item.isEnabled,
      button: true,
      child: icon,
    );
  }

  // ===========================================================================
  // LABEL RESOLUTION
  // ===========================================================================

  /// Returns a safe, non-null destination label.
  String _resolveLabel(NavigationItem item) {
    final String label = item.label.trim();

    if (label.isNotEmpty) {
      return label;
    }

    final String semanticLabel = item.semanticLabel?.trim() ?? '';

    if (semanticLabel.isNotEmpty) {
      return semanticLabel;
    }

    return '';
  }

  // ===========================================================================
  // TOOLTIP RESOLUTION
  // ===========================================================================

  /// Resolves destination tooltip using the following priority:
  ///
  /// 1. Explicit tooltip
  /// 2. Destination label
  /// 3. Semantic label
  /// 4. Empty string
  ///
  /// The method always returns a non-null String.
  String _resolveTooltip(NavigationItem item) {
    if (!enableTooltips) {
      return '';
    }

    // -------------------------------------------------------------------------
    // CUSTOM TOOLTIP
    // -------------------------------------------------------------------------

    final String customTooltip = item.tooltip?.trim() ?? '';

    if (customTooltip.isNotEmpty) {
      return customTooltip;
    }

    // -------------------------------------------------------------------------
    // DESTINATION LABEL
    // -------------------------------------------------------------------------

    final String label = item.label.trim();

    if (label.isNotEmpty) {
      return label;
    }

    // -------------------------------------------------------------------------
    // SEMANTIC FALLBACK
    // -------------------------------------------------------------------------

    final String semanticLabel = item.semanticLabel?.trim() ?? '';

    if (semanticLabel.isNotEmpty) {
      return semanticLabel;
    }

    return '';
  }

  // ===========================================================================
  // SEMANTIC LABEL RESOLUTION
  // ===========================================================================

  /// Resolves the most useful accessibility label.
  ///
  /// Priority:
  ///
  /// 1. Explicit semantic label
  /// 2. Destination label
  /// 3. Tooltip
  /// 4. Empty string
  String _resolveSemanticLabel(NavigationItem item) {
    final String semanticLabel = item.semanticLabel?.trim() ?? '';

    if (semanticLabel.isNotEmpty) {
      return semanticLabel;
    }

    final String label = item.label.trim();

    if (label.isNotEmpty) {
      return label;
    }

    final String tooltip = item.tooltip?.trim() ?? '';

    if (tooltip.isNotEmpty) {
      return tooltip;
    }

    return '';
  }

  // ===========================================================================
  // DESTINATION SELECTION
  // ===========================================================================

  void _handleDestinationSelected(int index) {
    // -------------------------------------------------------------------------
    // INDEX VALIDATION
    // -------------------------------------------------------------------------

    if (index < 0 || index >= items.length) {
      return;
    }

    final NavigationItem item = items[index];

    // -------------------------------------------------------------------------
    // DISABLED DESTINATION
    // -------------------------------------------------------------------------

    if (!item.isEnabled) {
      return;
    }

    // -------------------------------------------------------------------------
    // NAVIGATION CALLBACK
    // -------------------------------------------------------------------------

    onDestinationSelected(index);
  }

  // ===========================================================================
  // INDEX SAFETY
  // ===========================================================================

  int _safeSelectedIndex(int index, int itemCount) {
    if (itemCount <= 0) {
      return 0;
    }

    return index.clamp(0, itemCount - 1);
  }
}
