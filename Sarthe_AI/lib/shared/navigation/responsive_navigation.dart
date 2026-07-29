import 'package:flutter/material.dart';

/// Adaptive navigation layouts supported by Sarthee AI.
///
/// Material 3 strategy:
///
/// Compact
///   Phones / narrow windows
///   → Bottom NavigationBar
///
/// Medium
///   Tablets / foldables
///   → NavigationRail
///
/// Expanded
///   Desktop / large tablets / wide windows
///   → Extended NavigationRail
enum NavigationLayout {
  compact,
  medium,
  expanded;

  bool get isCompact => this == NavigationLayout.compact;

  bool get isMedium => this == NavigationLayout.medium;

  bool get isExpanded => this == NavigationLayout.expanded;

  bool get usesBottomNavigation => isCompact;

  bool get usesNavigationRail => isMedium || isExpanded;

  bool get usesExtendedNavigationRail => isExpanded;
}

/// Higher-level viewport classification.
///
/// Navigation uses only:
///
/// • compact
/// • medium
/// • expanded
///
/// while feature pages can additionally use:
///
/// • large
/// • extraLarge
///
/// for multi-pane layouts, maps, dashboards and grids.
enum ResponsiveWindowClass {
  compact,
  medium,
  expanded,
  large,
  extraLarge;

  bool get isCompact => this == ResponsiveWindowClass.compact;

  bool get isMedium => this == ResponsiveWindowClass.medium;

  bool get isExpanded => this == ResponsiveWindowClass.expanded;

  bool get isLarge => this == ResponsiveWindowClass.large;

  bool get isExtraLarge => this == ResponsiveWindowClass.extraLarge;

  bool get supportsRail => this != ResponsiveWindowClass.compact;

  bool get supportsMultiPane =>
      this == ResponsiveWindowClass.large ||
      this == ResponsiveWindowClass.extraLarge;
}

/// Central adaptive layout engine for Sarthee AI.
///
/// This class is intentionally independent from:
///
/// • GoRouter
/// • Riverpod
/// • AppShell
/// • feature modules
///
/// Architecture:
///
/// MediaQuery
///     ↓
/// ResponsiveNavigation
///     ↓
/// ┌─────────────────────────────────────────┐
/// │ NavigationLayout                       │
/// │ ResponsiveWindowClass                  │
/// │ Content constraints                    │
/// │ Responsive padding                     │
/// │ Grid configuration                     │
/// │ Navigation dimensions                  │
/// │ Accessibility / motion                 │
/// │ Orientation                            │
/// │ Multi-pane capability                  │
/// └─────────────────────────────────────────┘
///
/// This creates one responsive source of truth for the complete application.
abstract final class ResponsiveNavigation {
  ResponsiveNavigation._();

  // ===========================================================================
  // BREAKPOINTS
  // ===========================================================================

  /// Phone → tablet transition.
  static const double compactBreakpoint = 600.0;

  /// Tablet → expanded transition.
  static const double expandedBreakpoint = 840.0;

  /// Large desktop / multi-pane transition.
  static const double largeBreakpoint = 1200.0;

  /// Extra-large desktop/web transition.
  static const double extraLargeBreakpoint = 1600.0;

  // ===========================================================================
  // CONTENT WIDTH
  // ===========================================================================

  static const double expandedContentMaxWidth = 960.0;

  static const double largeContentMaxWidth = 1200.0;

  static const double extraLargeContentMaxWidth = 1440.0;

  // ===========================================================================
  // HORIZONTAL PADDING
  // ===========================================================================

  static const double compactHorizontalPadding = 16.0;

  static const double mediumHorizontalPadding = 24.0;

  static const double expandedHorizontalPadding = 32.0;

  static const double largeHorizontalPadding = 40.0;

  static const double extraLargeHorizontalPadding = 48.0;

  // ===========================================================================
  // VERTICAL PADDING
  // ===========================================================================

  static const double compactVerticalPadding = 16.0;

  static const double mediumVerticalPadding = 20.0;

  static const double expandedVerticalPadding = 24.0;

  // ===========================================================================
  // NAVIGATION DIMENSIONS
  // ===========================================================================

  static const double compactRailWidth = 72.0;

  static const double expandedRailWidth = 80.0;

  static const double defaultExtendedRailWidth = 240.0;

  static const double largeExtendedRailWidth = 260.0;

  static const double extraLargeExtendedRailWidth = 280.0;

  // ===========================================================================
  // GRID CONFIGURATION
  // ===========================================================================

  static const double compactGridAspectRatio = 1.10;

  static const double mediumGridAspectRatio = 1.25;

  static const double expandedGridAspectRatio = 1.35;

  // ===========================================================================
  // NAVIGATION LAYOUT
  // ===========================================================================

  /// Main API consumed by [AppShell].
  static NavigationLayout of(BuildContext context) {
    return fromWidth(screenWidth(context));
  }

  /// Determines the navigation layout directly from width.
  ///
  /// Keeping this independent from BuildContext makes the responsive engine
  /// straightforward to unit test.
  static NavigationLayout fromWidth(double width) {
    final double safeWidth = _sanitizeDimension(width);

    if (safeWidth < compactBreakpoint) {
      return NavigationLayout.compact;
    }

    if (safeWidth < expandedBreakpoint) {
      return NavigationLayout.medium;
    }

    return NavigationLayout.expanded;
  }

  // ===========================================================================
  // WINDOW CLASS
  // ===========================================================================

  static ResponsiveWindowClass windowClass(BuildContext context) {
    return windowClassFromWidth(screenWidth(context));
  }

  static ResponsiveWindowClass windowClassFromWidth(double width) {
    final double safeWidth = _sanitizeDimension(width);

    if (safeWidth < compactBreakpoint) {
      return ResponsiveWindowClass.compact;
    }

    if (safeWidth < expandedBreakpoint) {
      return ResponsiveWindowClass.medium;
    }

    if (safeWidth < largeBreakpoint) {
      return ResponsiveWindowClass.expanded;
    }

    if (safeWidth < extraLargeBreakpoint) {
      return ResponsiveWindowClass.large;
    }

    return ResponsiveWindowClass.extraLarge;
  }

  // ===========================================================================
  // SCREEN INFORMATION
  // ===========================================================================

  static Size screenSize(BuildContext context) {
    return MediaQuery.sizeOf(context);
  }

  static double screenWidth(BuildContext context) {
    return screenSize(context).width;
  }

  static double screenHeight(BuildContext context) {
    return screenSize(context).height;
  }

  static double shortestSide(BuildContext context) {
    return screenSize(context).shortestSide;
  }

  static double longestSide(BuildContext context) {
    return screenSize(context).longestSide;
  }

  static double devicePixelRatio(BuildContext context) {
    return MediaQuery.devicePixelRatioOf(context);
  }

  // ===========================================================================
  // NAVIGATION CLASSIFICATION
  // ===========================================================================

  static bool isCompact(BuildContext context) {
    return of(context).isCompact;
  }

  static bool isMedium(BuildContext context) {
    return of(context).isMedium;
  }

  static bool isExpanded(BuildContext context) {
    return of(context).isExpanded;
  }

  static bool isCompactWidth(double width) {
    return fromWidth(width).isCompact;
  }

  static bool isMediumWidth(double width) {
    return fromWidth(width).isMedium;
  }

  static bool isExpandedWidth(double width) {
    return fromWidth(width).isExpanded;
  }

  // ===========================================================================
  // ADVANCED WINDOW CLASSIFICATION
  // ===========================================================================

  static bool isLarge(BuildContext context) {
    return windowClass(context).isLarge;
  }

  static bool isExtraLarge(BuildContext context) {
    return windowClass(context).isExtraLarge;
  }

  static bool isLargeWidth(double width) {
    final ResponsiveWindowClass type = windowClassFromWidth(width);

    return type.isLarge || type.isExtraLarge;
  }

  static bool isExtraLargeWidth(double width) {
    return windowClassFromWidth(width).isExtraLarge;
  }

  // ===========================================================================
  // ORIENTATION
  // ===========================================================================

  static Orientation orientation(BuildContext context) {
    return MediaQuery.orientationOf(context);
  }

  static bool isPortrait(BuildContext context) {
    return orientation(context) == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return orientation(context) == Orientation.landscape;
  }

  // ===========================================================================
  // CONTENT CONSTRAINTS
  // ===========================================================================

  static double contentMaxWidth(BuildContext context) {
    return contentMaxWidthFor(screenWidth(context));
  }

  static double contentMaxWidthFor(double width) {
    final double safeWidth = _sanitizeDimension(width);

    if (safeWidth >= extraLargeBreakpoint) {
      return extraLargeContentMaxWidth;
    }

    if (safeWidth >= largeBreakpoint) {
      return largeContentMaxWidth;
    }

    if (safeWidth >= expandedBreakpoint) {
      return expandedContentMaxWidth;
    }

    return double.infinity;
  }

  /// Applies the application's recommended maximum content width.
  ///
  /// Useful for:
  ///
  /// • Settings
  /// • Profile
  /// • Forms
  /// • Destination pages
  /// • Authentication
  /// • AI Chat desktop layouts
  static Widget constrainContent(
    BuildContext context, {
    required Widget child,
    AlignmentGeometry alignment = Alignment.topCenter,
  }) {
    final double maxWidth = contentMaxWidth(context);

    if (!maxWidth.isFinite) {
      return child;
    }

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  // ===========================================================================
  // RESPONSIVE PADDING
  // ===========================================================================

  static double horizontalPadding(BuildContext context) {
    return horizontalPaddingFor(screenWidth(context));
  }

  static double horizontalPaddingFor(double width) {
    final double safeWidth = _sanitizeDimension(width);

    if (safeWidth >= extraLargeBreakpoint) {
      return extraLargeHorizontalPadding;
    }

    if (safeWidth >= largeBreakpoint) {
      return largeHorizontalPadding;
    }

    if (safeWidth >= expandedBreakpoint) {
      return expandedHorizontalPadding;
    }

    if (safeWidth >= compactBreakpoint) {
      return mediumHorizontalPadding;
    }

    return compactHorizontalPadding;
  }

  static double verticalPadding(BuildContext context) {
    return switch (of(context)) {
      NavigationLayout.compact => compactVerticalPadding,
      NavigationLayout.medium => mediumVerticalPadding,
      NavigationLayout.expanded => expandedVerticalPadding,
    };
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context),
      vertical: verticalPadding(context),
    );
  }

  static EdgeInsets horizontalPagePadding(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: horizontalPadding(context));
  }

  // ===========================================================================
  // GRID SYSTEM
  // ===========================================================================

  /// Recommended grid column count.
  ///
  /// Intended for:
  ///
  /// • Destinations
  /// • Culture
  /// • Food
  /// • Hotels
  /// • Favorites
  /// • Trip cards
  static int gridColumnCount(BuildContext context) {
    return gridColumnCountFor(screenWidth(context));
  }

  static int gridColumnCountFor(double width) {
    final double safeWidth = _sanitizeDimension(width);

    if (safeWidth >= extraLargeBreakpoint) {
      return 5;
    }

    if (safeWidth >= largeBreakpoint) {
      return 4;
    }

    if (safeWidth >= expandedBreakpoint) {
      return 3;
    }

    if (safeWidth >= compactBreakpoint) {
      return 2;
    }

    return 1;
  }

  static double gridChildAspectRatio(BuildContext context) {
    return switch (of(context)) {
      NavigationLayout.compact => compactGridAspectRatio,
      NavigationLayout.medium => mediumGridAspectRatio,
      NavigationLayout.expanded => expandedGridAspectRatio,
    };
  }

  // ===========================================================================
  // NAVIGATION DIMENSIONS
  // ===========================================================================

  static double navigationRailWidth(BuildContext context) {
    return isExpanded(context) ? expandedRailWidth : compactRailWidth;
  }

  static double extendedNavigationRailWidth(BuildContext context) {
    final ResponsiveWindowClass type = windowClass(context);

    return switch (type) {
      ResponsiveWindowClass.extraLarge => extraLargeExtendedRailWidth,

      ResponsiveWindowClass.large => largeExtendedRailWidth,

      ResponsiveWindowClass.expanded => defaultExtendedRailWidth,

      ResponsiveWindowClass.medium => defaultExtendedRailWidth,

      ResponsiveWindowClass.compact => defaultExtendedRailWidth,
    };
  }

  // ===========================================================================
  // MULTI-PANE CAPABILITY
  // ===========================================================================

  /// Whether the viewport can safely display multiple content panes.
  ///
  /// Future examples:
  ///
  /// Destinations | Details
  ///
  /// Map | Navigation instructions
  ///
  /// Trips | Trip details
  ///
  /// AI conversations | Active chat
  static bool supportsMultiPane(BuildContext context) {
    return windowClass(context).supportsMultiPane;
  }

  static bool supportsMultiPaneWidth(double width) {
    return windowClassFromWidth(width).supportsMultiPane;
  }

  /// Useful for layouts that should behave more like desktop applications.
  static bool isDesktopLike(BuildContext context) {
    return screenWidth(context) >= expandedBreakpoint;
  }

  // ===========================================================================
  // ACCESSIBILITY
  // ===========================================================================

  static bool disableAnimations(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  static bool accessibleNavigation(BuildContext context) {
    return MediaQuery.accessibleNavigationOf(context);
  }

  static bool highContrast(BuildContext context) {
    return MediaQuery.highContrastOf(context);
  }

  static bool boldText(BuildContext context) {
    return MediaQuery.boldTextOf(context);
  }

  // ===========================================================================
  // MOTION
  // ===========================================================================

  /// Returns zero duration when the user requests reduced motion.
  static Duration adaptiveDuration(
    BuildContext context, {
    Duration duration = const Duration(milliseconds: 250),
  }) {
    if (disableAnimations(context)) {
      return Duration.zero;
    }

    return duration;
  }

  // ===========================================================================
  // TEXT SCALING
  // ===========================================================================

  static TextScaler textScaler(BuildContext context) {
    return MediaQuery.textScalerOf(context);
  }

  static double textScaleFactor(BuildContext context) {
    return textScaler(context).scale(1.0);
  }

  static bool usesLargeText(BuildContext context) {
    return textScaleFactor(context) >= 1.3;
  }

  static bool usesVeryLargeText(BuildContext context) {
    return textScaleFactor(context) >= 1.6;
  }

  // ===========================================================================
  // SAFE AREA
  // ===========================================================================

  static EdgeInsets viewPadding(BuildContext context) {
    return MediaQuery.viewPaddingOf(context);
  }

  static EdgeInsets viewInsets(BuildContext context) {
    return MediaQuery.viewInsetsOf(context);
  }

  static bool keyboardVisible(BuildContext context) {
    return viewInsets(context).bottom > 0;
  }

  // ===========================================================================
  // INTERNAL SAFETY
  // ===========================================================================

  static double _sanitizeDimension(double value) {
    if (!value.isFinite || value < 0) {
      return 0.0;
    }

    return value;
  }

  // ===========================================================================
  // DEVELOPMENT VALIDATION
  // ===========================================================================

  /// Validates the responsive configuration in debug mode.
  ///
  /// Call this from application/router initialization if desired:
  ///
  /// assert(() {
  ///   ResponsiveNavigation.debugValidate();
  ///   return true;
  /// }());
  static void debugValidate() {
    assert(() {
      if (compactBreakpoint <= 0) {
        throw StateError('compactBreakpoint must be greater than zero.');
      }

      if (expandedBreakpoint <= compactBreakpoint) {
        throw StateError(
          'expandedBreakpoint must be greater than '
          'compactBreakpoint.',
        );
      }

      if (largeBreakpoint <= expandedBreakpoint) {
        throw StateError(
          'largeBreakpoint must be greater than '
          'expandedBreakpoint.',
        );
      }

      if (extraLargeBreakpoint <= largeBreakpoint) {
        throw StateError(
          'extraLargeBreakpoint must be greater than '
          'largeBreakpoint.',
        );
      }

      if (expandedContentMaxWidth <= 0) {
        throw StateError('expandedContentMaxWidth must be positive.');
      }

      if (largeContentMaxWidth <= expandedContentMaxWidth) {
        throw StateError(
          'largeContentMaxWidth must be greater than '
          'expandedContentMaxWidth.',
        );
      }

      if (extraLargeContentMaxWidth <= largeContentMaxWidth) {
        throw StateError(
          'extraLargeContentMaxWidth must be greater than '
          'largeContentMaxWidth.',
        );
      }

      if (compactRailWidth <= 0 ||
          expandedRailWidth <= 0 ||
          defaultExtendedRailWidth <= 0 ||
          largeExtendedRailWidth <= 0 ||
          extraLargeExtendedRailWidth <= 0) {
        throw StateError('Navigation widths must be greater than zero.');
      }

      return true;
    }());
  }
}
