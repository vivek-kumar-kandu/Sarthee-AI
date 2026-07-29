import 'package:flutter/material.dart';

import 'navigation_item.dart';

/// Sarthee AI adaptive Material 3 navigation drawer.
///
/// Architecture:
///
/// AppNavigationDrawer
///        ↓ callback
/// AppShell / Parent Navigation Layer
///        ↓
/// StatefulNavigationShell.goBranch()
///
/// This widget intentionally contains no direct dependency on:
///
/// • GoRouter
/// • Riverpod
/// • NavigationController
///
/// Responsibilities:
///
/// • Material 3 NavigationDrawer
/// • Primary navigation destinations
/// • Selected destination state
/// • Disabled destination support
/// • Badge support
/// • Accessibility
/// • Tooltips
/// • Sarthee AI branding
/// • Optional header/footer
/// • Safe destination selection
class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.header,
    this.footer,
    this.showHeader = true,
    this.showFooter = true,
    this.enableTooltips = true,
    this.closeOnSelection = true,
    super.key,
  });

  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================

  /// Primary navigation destinations.
  final List<NavigationItem> items;

  /// Currently selected primary branch.
  final int selectedIndex;

  /// Destination selection callback.
  ///
  /// Actual navigation is handled outside this widget.
  final ValueChanged<int> onDestinationSelected;

  /// Optional custom drawer header.
  final Widget? header;

  /// Optional custom drawer footer.
  final Widget? footer;

  /// Whether the drawer header should be shown.
  final bool showHeader;

  /// Whether the drawer footer should be shown.
  final bool showFooter;

  /// Whether tooltips should be enabled.
  final bool enableTooltips;

  /// Whether an open modal drawer should close after selection.
  final bool closeOnSelection;

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final int safeSelectedIndex = _safeSelectedIndex(
      selectedIndex,
      items.length,
    );

    return SafeArea(
      child: Column(
        children: <Widget>[
          if (showHeader) header ?? _buildDefaultHeader(context),

          Expanded(
            child: NavigationDrawer(
              selectedIndex: safeSelectedIndex,
              onDestinationSelected: (int index) {
                _handleDestinationSelected(context, index);
              },
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(28, 16, 28, 8),
                  child: Text('Navigation'),
                ),

                ...List<Widget>.generate(items.length, (int index) {
                  final NavigationItem item = items[index];

                  return _buildDestination(item: item);
                }, growable: false),
              ],
            ),
          ),

          if (showFooter) footer ?? _buildDefaultFooter(context),
        ],
      ),
    );
  }

  // ===========================================================================
  // DESTINATION
  // ===========================================================================

  NavigationDrawerDestination _buildDestination({
    required NavigationItem item,
  }) {
    return NavigationDrawerDestination(
      enabled: item.isEnabled,
      icon: _buildIcon(item: item, selected: false),
      selectedIcon: _buildIcon(item: item, selected: true),
      label: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
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
        label: badgeLabel.isEmpty ? null : Text(badgeLabel),
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
  // HEADER
  // ===========================================================================

  Widget _buildDefaultHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.travel_explore_rounded,
              size: 28,
              color: colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sarthee AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Smart travel companion',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FOOTER
  // ===========================================================================

  Widget _buildDefaultFooter(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: colorScheme.primary,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Powered by Sarthee AI',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SELECTION
  // ===========================================================================

  void _handleDestinationSelected(BuildContext context, int index) {
    if (index < 0 || index >= items.length) {
      return;
    }

    final NavigationItem item = items[index];

    if (!item.isEnabled) {
      return;
    }

    onDestinationSelected(index);

    if (!closeOnSelection) {
      return;
    }

    _closeDrawerIfPossible(context);
  }

  // ===========================================================================
  // DRAWER HANDLING
  // ===========================================================================

  void _closeDrawerIfPossible(BuildContext context) {
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);

    if (scaffold == null) {
      return;
    }

    if (scaffold.isDrawerOpen) {
      Navigator.of(context).maybePop();
      return;
    }

    if (scaffold.isEndDrawerOpen) {
      Navigator.of(context).maybePop();
    }
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
