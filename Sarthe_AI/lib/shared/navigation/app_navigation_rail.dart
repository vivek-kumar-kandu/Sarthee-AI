import 'package:flutter/material.dart';

import 'navigation_item.dart';

/// ============================================================================
/// SARTHEE AI — ADAPTIVE NAVIGATION RAIL
/// ============================================================================
///
/// Material 3 navigation rail used by Sarthee AI on medium and expanded
/// layouts.
///
/// Layout behavior:
///
/// • Medium   → compact NavigationRail
/// • Expanded → extended NavigationRail
///
/// Navigation architecture:
///
/// AppNavigationRail
///        ↓ callback
/// AppShell
///        ↓
/// StatefulNavigationShell.goBranch()
///
/// This widget intentionally contains no direct dependency on:
///
/// • GoRouter
/// • Riverpod
/// • NavigationController
///
/// Branch switching and routing remain centralized inside [AppShell].
class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = false,
    this.showLeading = true,
    this.showTrailing = false,
    this.leading,
    this.trailing,
    this.minWidth,
    this.minExtendedWidth,
    this.elevation,
    this.enableTooltips = true,
    this.groupAlignment = -1.0,
    super.key,
  }) : assert(
         elevation == null || elevation > 0,
         'NavigationRail elevation must be null or greater than zero.',
       ),
       assert(
         minWidth == null || minWidth > 0,
         'NavigationRail minWidth must be greater than zero.',
       ),
       assert(
         minExtendedWidth == null || minExtendedWidth > 0,
         'NavigationRail minExtendedWidth must be greater than zero.',
       );

  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================

  /// Primary application navigation destinations.
  final List<NavigationItem> items;

  /// Currently selected navigation destination.
  ///
  /// Invalid values are normalized defensively before being passed to
  /// Material's [NavigationRail].
  final int selectedIndex;

  /// Called after an enabled destination is selected.
  ///
  /// Actual branch navigation is handled by [AppShell].
  final ValueChanged<int> onDestinationSelected;

  /// Whether the rail should display destination labels next to their icons.
  final bool extended;

  /// Whether the leading section should be displayed.
  final bool showLeading;

  /// Whether the trailing section should be displayed.
  final bool showTrailing;

  /// Optional custom leading widget.
  ///
  /// When omitted, Sarthee AI branding is rendered automatically.
  final Widget? leading;

  /// Optional custom trailing widget.
  final Widget? trailing;

  /// Minimum width of the compact rail.
  final double? minWidth;

  /// Minimum width of the extended rail.
  final double? minExtendedWidth;

  /// Optional Material elevation.
  ///
  /// Flutter's [NavigationRail] requires this value to either be `null`
  /// or greater than zero.
  ///
  /// `null` is intentionally the default because Sarthee AI uses a flat
  /// Material 3 navigation surface.
  final double? elevation;

  /// Whether destination tooltips should be rendered.
  final bool enableTooltips;

  /// Vertical alignment of the navigation destination group.
  ///
  /// Valid range:
  ///
  /// -1.0 → top
  ///  0.0 → center
  ///  1.0 → bottom
  final double groupAlignment;

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    // A NavigationRail without destinations is not useful and may violate
    // framework expectations. Return an empty widget defensively.
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final int safeSelectedIndex = _safeSelectedIndex(
      selectedIndex,
      items.length,
    );

    final double safeGroupAlignment = groupAlignment
        .clamp(-1.0, 1.0)
        .toDouble();

    return NavigationRail(
      // -----------------------------------------------------------------------
      // SELECTION
      // -----------------------------------------------------------------------
      selectedIndex: safeSelectedIndex,

      onDestinationSelected: _handleDestinationSelected,

      // -----------------------------------------------------------------------
      // LAYOUT
      // -----------------------------------------------------------------------
      extended: extended,

      minWidth: minWidth,

      minExtendedWidth: minExtendedWidth,

      groupAlignment: safeGroupAlignment,

      // -----------------------------------------------------------------------
      // MATERIAL SURFACE
      // -----------------------------------------------------------------------
      //
      // Important:
      //
      // NavigationRail does not accept elevation == 0.
      //
      // Passing null allows Material/Theme defaults to control the surface
      // while keeping the rail visually flat.
      elevation: elevation,

      // -----------------------------------------------------------------------
      // LABEL BEHAVIOR
      // -----------------------------------------------------------------------
      //
      // Extended rails already display labels beside icons.
      //
      // Compact rails display the currently selected destination label.
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.selected,

      // -----------------------------------------------------------------------
      // LEADING / TRAILING
      // -----------------------------------------------------------------------
      leading: showLeading ? leading ?? _buildDefaultLeading(context) : null,

      trailing: showTrailing ? trailing : null,

      // -----------------------------------------------------------------------
      // DESTINATIONS
      // -----------------------------------------------------------------------
      destinations: List<NavigationRailDestination>.generate(items.length, (
        int index,
      ) {
        return _buildDestination(item: items[index]);
      }, growable: false),
    );
  }

  // ===========================================================================
  // DESTINATION
  // ===========================================================================

  NavigationRailDestination _buildDestination({required NavigationItem item}) {
    return NavigationRailDestination(
      disabled: !item.isEnabled,

      icon: _buildIcon(item: item, selected: false),

      selectedIcon: _buildIcon(item: item, selected: true),

      label: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),

      padding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  // ===========================================================================
  // DESTINATION ICON
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
        label: badgeLabel.isEmpty ? null : Text(badgeLabel, maxLines: 1),
        child: icon,
      );
    }

    // -------------------------------------------------------------------------
    // TOOLTIP
    // -------------------------------------------------------------------------

    final String tooltip = item.tooltip?.trim() ?? '';

    if (enableTooltips && tooltip.isNotEmpty) {
      icon = Tooltip(message: tooltip, child: icon);
    }

    // -------------------------------------------------------------------------
    // ACCESSIBILITY
    // -------------------------------------------------------------------------

    return Semantics(
      label: item.semanticLabel,
      selected: selected,
      enabled: item.isEnabled,
      button: true,
      child: icon,
    );
  }

  // ===========================================================================
  // DEFAULT LEADING / BRANDING
  // ===========================================================================

  Widget _buildDefaultLeading(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (extended) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildBrandIcon(colorScheme),

            const SizedBox(width: 12),

            Flexible(
              child: Text(
                'Sarthee AI',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Tooltip(
        message: 'Sarthee AI',
        child: Semantics(
          label: 'Sarthee AI',
          image: true,
          child: _buildBrandIcon(colorScheme),
        ),
      ),
    );
  }

  // ===========================================================================
  // BRAND ICON
  // ===========================================================================

  Widget _buildBrandIcon(ColorScheme colorScheme) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.travel_explore_rounded,
        size: 24,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  // ===========================================================================
  // DESTINATION SELECTION
  // ===========================================================================

  void _handleDestinationSelected(int index) {
    // Protect against invalid framework/programmatic indices.
    if (index < 0 || index >= items.length) {
      return;
    }

    final NavigationItem item = items[index];

    // Disabled destinations must never trigger branch navigation.
    if (!item.isEnabled) {
      return;
    }

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
