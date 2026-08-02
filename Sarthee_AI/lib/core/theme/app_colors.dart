import 'package:flutter/material.dart';

/// Sarthee AI centralized color system.
///
/// Rules:
/// 1. UI screens should not contain random hard-coded colors.
/// 2. Brand colors belong here.
/// 3. Semantic colors should be preferred over raw colors.
/// 4. Light/Dark ThemeData is generated separately in [AppTheme].
/// 5. New feature-specific colors can be added without changing existing ones.
abstract final class AppColors {
  // ============================================================
  // BRAND
  // ============================================================

  /// Primary Sarthee AI identity color.
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryLight = Color(0xFF8B72C9);
  static const Color primaryDark = Color(0xFF4F378B);

  /// Supporting brand color.
  static const Color secondary = Color(0xFF006C67);
  static const Color secondaryLight = Color(0xFF4FD8CF);
  static const Color secondaryDark = Color(0xFF00504C);

  /// Warm travel/culture accent.
  static const Color accent = Color(0xFFFFB74D);
  static const Color accentLight = Color(0xFFFFD180);
  static const Color accentDark = Color(0xFFF57C00);

  // ============================================================
  // LIGHT COLOR SCHEME
  // ============================================================

  static const Color lightPrimary = primary;
  static const Color lightOnPrimary = Color(0xFFFFFFFF);

  static const Color lightPrimaryContainer = Color(0xFFE9DDFF);
  static const Color lightOnPrimaryContainer = Color(0xFF22005D);

  static const Color lightSecondary = secondary;
  static const Color lightOnSecondary = Color(0xFFFFFFFF);

  static const Color lightSecondaryContainer = Color(0xFF9CF2E9);
  static const Color lightOnSecondaryContainer = Color(0xFF00201E);

  static const Color lightTertiary = Color(0xFF8A4F00);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);

  static const Color lightTertiaryContainer = Color(0xFFFFDDB8);
  static const Color lightOnTertiaryContainer = Color(0xFF2C1600);

  static const Color lightBackground = Color(0xFFF9F9FC);
  static const Color lightOnBackground = Color(0xFF1B1B1F);

  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1B1B1F);

  static const Color lightSurfaceVariant = Color(0xFFF1F0F5);
  static const Color lightOnSurfaceVariant = Color(0xFF47464F);

  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF7F7FA);
  static const Color lightSurfaceContainer = Color(0xFFF1F1F5);
  static const Color lightSurfaceContainerHigh = Color(0xFFEBEBEF);
  static const Color lightSurfaceContainerHighest = Color(0xFFE5E5E9);

  static const Color lightOutline = Color(0xFF797780);
  static const Color lightOutlineVariant = Color(0xFFCAC7D0);

  static const Color lightInverseSurface = Color(0xFF303034);
  static const Color lightOnInverseSurface = Color(0xFFF3F0F5);
  static const Color lightInversePrimary = Color(0xFFD0BCFF);

  // ============================================================
  // DARK COLOR SCHEME
  // ============================================================

  static const Color darkPrimary = Color(0xFFD0BCFF);
  static const Color darkOnPrimary = Color(0xFF381E72);

  static const Color darkPrimaryContainer = Color(0xFF4F378B);
  static const Color darkOnPrimaryContainer = Color(0xFFEADDFF);

  static const Color darkSecondary = Color(0xFF80D5CD);
  static const Color darkOnSecondary = Color(0xFF003733);

  static const Color darkSecondaryContainer = Color(0xFF00504C);
  static const Color darkOnSecondaryContainer = Color(0xFF9CF2E9);

  static const Color darkTertiary = Color(0xFFFFB86B);
  static const Color darkOnTertiary = Color(0xFF492900);

  static const Color darkTertiaryContainer = Color(0xFF683C00);
  static const Color darkOnTertiaryContainer = Color(0xFFFFDDB8);

  static const Color darkBackground = Color(0xFF111114);
  static const Color darkOnBackground = Color(0xFFE5E1E6);

  static const Color darkSurface = Color(0xFF111114);
  static const Color darkOnSurface = Color(0xFFE5E1E6);

  static const Color darkSurfaceVariant = Color(0xFF24242A);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC7D0);

  static const Color darkSurfaceContainerLowest = Color(0xFF0C0C0F);
  static const Color darkSurfaceContainerLow = Color(0xFF19191D);
  static const Color darkSurfaceContainer = Color(0xFF1D1D21);
  static const Color darkSurfaceContainerHigh = Color(0xFF27272B);
  static const Color darkSurfaceContainerHighest = Color(0xFF323236);

  static const Color darkOutline = Color(0xFF938F99);
  static const Color darkOutlineVariant = Color(0xFF49454F);

  static const Color darkInverseSurface = Color(0xFFE5E1E6);
  static const Color darkOnInverseSurface = Color(0xFF303034);
  static const Color darkInversePrimary = primary;

  // ============================================================
  // TEXT
  // ============================================================

  static const Color lightTextPrimary = Color(0xFF1B1B1F);
  static const Color lightTextSecondary = Color(0xFF5F5F67);
  static const Color lightTextTertiary = Color(0xFF797780);
  static const Color lightTextDisabled = Color(0xFF9E9EA7);

  static const Color darkTextPrimary = Color(0xFFF4F4F6);
  static const Color darkTextSecondary = Color(0xFFB8B8C2);
  static const Color darkTextTertiary = Color(0xFF96969F);
  static const Color darkTextDisabled = Color(0xFF777780);

  // ============================================================
  // BORDERS / DIVIDERS
  // ============================================================

  static const Color lightBorder = Color(0xFFE2E2E8);
  static const Color lightDivider = Color(0xFFE8E8EE);

  static const Color darkBorder = Color(0xFF34343C);
  static const Color darkDivider = Color(0xFF2B2B32);

  // ============================================================
  // SEMANTIC STATUS
  // ============================================================

  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successDark = Color(0xFF81C784);

  static const Color warning = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color warningDark = Color(0xFFFFD54F);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorLight = Color(0xFFFFDAD6);
  static const Color errorDark = Color(0xFFFFB4AB);

  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color infoDark = Color(0xFF90CAF9);

  // ============================================================
  // SARTHEE AI
  // ============================================================

  static const Color ai = Color(0xFF6A5AE0);
  static const Color aiLight = Color(0xFF9C8CFF);
  static const Color aiDark = Color(0xFF4939BD);

  static const Color aiUserBubble = Color(0xFF6750A4);
  static const Color aiAssistantBubbleLight = Color(0xFFF1ECFF);
  static const Color aiAssistantBubbleDark = Color(0xFF272331);

  // ============================================================
  // FEATURE COLORS
  // ============================================================

  static const Color destination = Color(0xFF1565C0);
  static const Color tripPlanner = Color(0xFF5E35B1);
  static const Color hotel = Color(0xFF7B1FA2);
  static const Color food = Color(0xFFE65100);
  static const Color culture = Color(0xFFAD1457);
  static const Color navigation = Color(0xFF00897B);
  static const Color weather = Color(0xFF0288D1);
  static const Color budget = Color(0xFF388E3C);
  static const Color safety = Color(0xFFD84315);
  static const Color favorite = Color(0xFFE91E63);
  static const Color notification = Color(0xFFEF6C00);
  static const Color history = Color(0xFF546E7A);

  // ============================================================
  // MAP / NAVIGATION
  // ============================================================

  static const Color mapRoute = Color(0xFF2962FF);
  static const Color mapCurrentLocation = Color(0xFF00BFA5);
  static const Color mapDestination = Color(0xFFE53935);

  static const Color mapTrafficLow = Color(0xFF43A047);
  static const Color mapTrafficMedium = Color(0xFFFFB300);
  static const Color mapTrafficHigh = Color(0xFFE53935);

  // ============================================================
  // RATINGS
  // ============================================================

  static const Color rating = Color(0xFFFFB300);

  // ============================================================
  // COMMON
  // ============================================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ============================================================
  // OVERLAYS
  // ============================================================

  static const Color blackOverlay10 = Color(0x1A000000);
  static const Color blackOverlay20 = Color(0x33000000);
  static const Color blackOverlay40 = Color(0x66000000);
  static const Color blackOverlay60 = Color(0x99000000);

  static const Color whiteOverlay10 = Color(0x1AFFFFFF);
  static const Color whiteOverlay20 = Color(0x33FFFFFF);
  static const Color whiteOverlay40 = Color(0x66FFFFFF);

  // ============================================================
  // SHADOWS
  // ============================================================

  static const Color lightShadow = Color(0x1A000000);
  static const Color mediumShadow = Color(0x33000000);
  static const Color darkShadow = Color(0x66000000);

  // ============================================================
  // SKELETON / SHIMMER
  // ============================================================

  static const Color lightSkeletonBase = Color(0xFFE8E8EC);
  static const Color lightSkeletonHighlight = Color(0xFFF5F5F8);

  static const Color darkSkeletonBase = Color(0xFF29292E);
  static const Color darkSkeletonHighlight = Color(0xFF36363C);

  // ============================================================
  // GRADIENTS
  // ============================================================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C63E6), Color(0xFF4F378B)],
  );

  static const LinearGradient travelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00897B), Color(0xFF1565C0)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB74D), Color(0xFFE65100)],
  );

  static const LinearGradient imageOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0xB3000000)],
  );

  // ============================================================
  // PRIVATE CONSTRUCTOR
  // ============================================================

  AppColors._();
}
