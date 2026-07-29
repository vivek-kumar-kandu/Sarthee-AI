import 'package:flutter/material.dart';

/// Centralized layout, spacing, sizing and responsive tokens
/// for Sarthee AI.
///
/// Rules:
/// 1. Avoid random spacing values inside feature screens.
/// 2. Prefer these tokens for padding, gaps, radius and sizing.
/// 3. Responsive breakpoints should come from this file.
/// 4. Existing tokens should remain stable; new requirements
///    should normally be handled by adding new tokens.
abstract final class AppSpacing {
  // ============================================================
  // BASE SPACING SCALE
  // ============================================================

  static const double none = 0.0;

  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;
  static const double space72 = 72.0;
  static const double space80 = 80.0;
  static const double space96 = 96.0;

  // ============================================================
  // SEMANTIC SPACING
  // ============================================================

  static const double xxs = space2;
  static const double xs = space4;
  static const double sm = space8;
  static const double md = space12;
  static const double lg = space16;
  static const double xl = space20;
  static const double xxl = space24;
  static const double xxxl = space32;
  static const double huge = space48;
  static const double extraHuge = space64;

  // ============================================================
  // SCREEN PADDING
  // ============================================================

  static const double mobileHorizontalPadding = 20.0;
  static const double tabletHorizontalPadding = 32.0;
  static const double desktopHorizontalPadding = 48.0;

  static const double screenTopPadding = 16.0;
  static const double screenBottomPadding = 24.0;

  /// Default mobile screen padding.
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: mobileHorizontalPadding,
    vertical: screenTopPadding,
  );

  static const EdgeInsets mobileScreenPadding = EdgeInsets.symmetric(
    horizontal: mobileHorizontalPadding,
    vertical: screenTopPadding,
  );

  static const EdgeInsets tabletScreenPadding = EdgeInsets.symmetric(
    horizontal: tabletHorizontalPadding,
    vertical: space24,
  );

  static const EdgeInsets desktopScreenPadding = EdgeInsets.symmetric(
    horizontal: desktopHorizontalPadding,
    vertical: space32,
  );

  // ============================================================
  // COMMON EDGE INSETS
  // ============================================================

  static const EdgeInsets paddingXS = EdgeInsets.all(space4);
  static const EdgeInsets paddingSM = EdgeInsets.all(space8);
  static const EdgeInsets paddingMD = EdgeInsets.all(space12);
  static const EdgeInsets paddingLG = EdgeInsets.all(space16);
  static const EdgeInsets paddingXL = EdgeInsets.all(space20);
  static const EdgeInsets paddingXXL = EdgeInsets.all(space24);
  static const EdgeInsets paddingXXXL = EdgeInsets.all(space32);

  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(
    horizontal: space8,
  );

  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(
    horizontal: space12,
  );

  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(
    horizontal: space16,
  );

  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(
    horizontal: space20,
  );

  static const EdgeInsets horizontalXXL = EdgeInsets.symmetric(
    horizontal: space24,
  );

  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: space8);

  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: space12);

  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: space16);

  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: space20);

  static const EdgeInsets verticalXXL = EdgeInsets.symmetric(vertical: space24);

  // ============================================================
  // SECTION / CONTENT SPACING
  // ============================================================

  static const double sectionGap = 32.0;
  static const double largeSectionGap = 48.0;

  static const double titleToContentGap = 16.0;
  static const double itemGap = 12.0;
  static const double compactItemGap = 8.0;

  static const double cardGap = 16.0;
  static const double listItemGap = 12.0;
  static const double gridGap = 16.0;

  // ============================================================
  // BORDER RADIUS SCALE
  // ============================================================

  static const double radiusNone = 0.0;
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusXXXL = 32.0;

  /// Used for pills, chips and circular-style containers.
  static const double radiusFull = 999.0;

  // ============================================================
  // BORDER RADIUS OBJECTS
  // ============================================================

  static const BorderRadius borderRadiusXS = BorderRadius.all(
    Radius.circular(radiusXS),
  );

  static const BorderRadius borderRadiusSM = BorderRadius.all(
    Radius.circular(radiusSM),
  );

  static const BorderRadius borderRadiusMD = BorderRadius.all(
    Radius.circular(radiusMD),
  );

  static const BorderRadius borderRadiusLG = BorderRadius.all(
    Radius.circular(radiusLG),
  );

  static const BorderRadius borderRadiusXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );

  static const BorderRadius borderRadiusXXL = BorderRadius.all(
    Radius.circular(radiusXXL),
  );

  static const BorderRadius borderRadiusXXXL = BorderRadius.all(
    Radius.circular(radiusXXXL),
  );

  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );

  // ============================================================
  // TOUCH TARGETS
  // ============================================================

  /// Recommended minimum interactive target.
  static const double minimumTouchTarget = 48.0;

  static const double compactTouchTarget = 40.0;

  // ============================================================
  // BUTTONS
  // ============================================================

  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  /// Default Sarthee AI button height.
  static const double buttonHeight = buttonHeightLarge;

  static const double buttonRadius = radiusMD;

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: space24,
    vertical: space12,
  );

  // ============================================================
  // INPUT FIELDS
  // ============================================================

  static const double inputHeight = 56.0;
  static const double inputRadius = radiusMD;

  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space16,
  );

  // ============================================================
  // ICON SIZES
  // ============================================================

  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 48.0;

  // ============================================================
  // AVATAR SIZES
  // ============================================================

  static const double avatarXS = 24.0;
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 96.0;
  static const double avatarXXL = 128.0;

  // ============================================================
  // CARDS
  // ============================================================

  static const double cardRadius = radiusLG;

  static const double cardPadding = space16;

  static const EdgeInsets cardContentPadding = EdgeInsets.all(cardPadding);

  static const double compactCardPadding = space12;
  static const double largeCardPadding = space24;

  // ============================================================
  // APP BAR
  // ============================================================

  static const double appBarHeight = 56.0;

  static const double largeAppBarHeight = 112.0;

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  static const double bottomNavigationHeight = 72.0;

  static const double navigationIconSize = 24.0;

  // ============================================================
  // DRAWER / NAVIGATION RAIL
  // ============================================================

  static const double drawerWidth = 304.0;

  static const double navigationRailWidth = 80.0;

  static const double extendedNavigationRailWidth = 256.0;

  // ============================================================
  // CHIPS
  // ============================================================

  static const double chipHeight = 36.0;

  static const double chipRadius = radiusFull;

  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: space12,
    vertical: space8,
  );

  // ============================================================
  // AI CHAT
  // ============================================================

  static const double chatBubbleRadius = 20.0;

  static const double chatBubbleMaxWidthFactor = 0.82;

  static const EdgeInsets chatBubblePadding = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space12,
  );

  static const double chatMessageGap = 12.0;

  static const double chatInputMinHeight = 56.0;

  // ============================================================
  // DESTINATION / TRAVEL CARDS
  // ============================================================

  static const double destinationCardHeight = 220.0;

  static const double destinationCardRadius = 20.0;

  static const double horizontalCardWidth = 280.0;

  // ============================================================
  // MAP / NAVIGATION
  // ============================================================

  static const double mapControlSize = 48.0;

  static const double mapMarkerSize = 40.0;

  static const double mapBottomSheetRadius = 28.0;

  // ============================================================
  // BOTTOM SHEETS
  // ============================================================

  static const double bottomSheetRadius = 28.0;

  static const double bottomSheetHandleWidth = 32.0;
  static const double bottomSheetHandleHeight = 4.0;

  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(
    space20,
    space12,
    space20,
    space24,
  );

  // ============================================================
  // DIALOGS
  // ============================================================

  static const double dialogRadius = 24.0;

  static const double dialogMaxWidth = 560.0;

  static const EdgeInsets dialogPadding = EdgeInsets.all(space24);

  // ============================================================
  // SNACKBAR / TOAST
  // ============================================================

  static const double snackBarRadius = 12.0;

  static const EdgeInsets snackBarMargin = EdgeInsets.all(space16);

  // ============================================================
  // DIVIDERS / BORDERS
  // ============================================================

  static const double dividerThickness = 1.0;

  static const double borderWidth = 1.0;

  static const double focusedBorderWidth = 2.0;

  // ============================================================
  // LOADING / PROGRESS
  // ============================================================

  static const double progressIndicatorSmall = 20.0;
  static const double progressIndicatorMedium = 32.0;
  static const double progressIndicatorLarge = 48.0;

  // ============================================================
  // RESPONSIVE BREAKPOINTS
  // ============================================================

  /// Phones.
  static const double mobileBreakpoint = 600.0;

  /// Tablets and smaller foldable layouts.
  static const double tabletBreakpoint = 1024.0;

  /// Desktop/web layouts.
  static const double desktopBreakpoint = 1440.0;

  /// Large desktop displays.
  static const double largeDesktopBreakpoint = 1920.0;

  // ============================================================
  // CONTENT WIDTH
  // ============================================================

  /// Forms such as login/signup/profile editing.
  static const double maxFormWidth = 520.0;

  /// Dialog/form content.
  static const double maxCompactContentWidth = 640.0;

  /// Main reading/content area.
  static const double maxContentWidth = 1200.0;

  /// Dashboard / large desktop content.
  static const double maxWideContentWidth = 1440.0;

  // ============================================================
  // GRID
  // ============================================================

  static const int mobileGridColumns = 1;
  static const int tabletGridColumns = 2;
  static const int desktopGridColumns = 3;
  static const int largeDesktopGridColumns = 4;

  // ============================================================
  // IMAGE ASPECT RATIOS
  // ============================================================

  static const double landscapeImageRatio = 16 / 9;
  static const double standardImageRatio = 4 / 3;
  static const double squareImageRatio = 1.0;
  static const double portraitImageRatio = 3 / 4;

  // ============================================================
  // RESPONSIVE HELPERS
  // ============================================================

  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktopBreakpoint;
  }

  /// Returns screen padding according to current device width.
  static EdgeInsets responsiveScreenPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= tabletBreakpoint) {
      return desktopScreenPadding;
    }

    if (width >= mobileBreakpoint) {
      return tabletScreenPadding;
    }

    return mobileScreenPadding;
  }

  /// Returns maximum useful content width for current device.
  static double responsiveContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= desktopBreakpoint) {
      return maxWideContentWidth;
    }

    if (width >= tabletBreakpoint) {
      return maxContentWidth;
    }

    return width;
  }

  /// Recommended grid column count according to width.
  static int gridColumnCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= largeDesktopBreakpoint) {
      return largeDesktopGridColumns;
    }

    if (width >= tabletBreakpoint) {
      return desktopGridColumns;
    }

    if (width >= mobileBreakpoint) {
      return tabletGridColumns;
    }

    return mobileGridColumns;
  }

  AppSpacing._();
}
