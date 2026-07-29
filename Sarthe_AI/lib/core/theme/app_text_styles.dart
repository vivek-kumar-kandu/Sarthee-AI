import 'package:flutter/material.dart';

/// Centralized typography system for Sarthee AI.
///
/// Rules:
/// 1. Avoid random TextStyle declarations inside feature screens.
/// 2. Prefer Theme.of(context).textTheme for standard UI text.
/// 3. Use AppTextStyles for specialized Sarthee AI typography.
/// 4. Font sizes remain centralized for future accessibility,
///    branding and responsive improvements.
abstract final class AppTextStyles {
  // ============================================================
  // FONT FAMILY
  // ============================================================

  /// Keep null while using Flutter's platform-default font.
  ///
  /// Later, if Sarthee AI gets a custom brand font, change it here
  /// and configure the font inside pubspec.yaml.
  static const String? fontFamily = null;

  // ============================================================
  // FONT WEIGHTS
  // ============================================================

  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ============================================================
  // DISPLAY
  // ============================================================

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: regular,
    height: 1.12,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: regular,
    height: 1.16,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: regular,
    height: 1.22,
    letterSpacing: 0,
  );

  // ============================================================
  // HEADLINES
  // ============================================================

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: bold,
    height: 1.28,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.33,
    letterSpacing: 0,
  );

  // ============================================================
  // TITLES
  // ============================================================

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: semiBold,
    height: 1.27,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // ============================================================
  // BODY
  // ============================================================

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // ============================================================
  // LABELS
  // ============================================================

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: medium,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // ============================================================
  // COMPATIBILITY ALIASES
  // ============================================================

  /// Kept so existing code using headingLarge does not break.
  static const TextStyle headingLarge = headlineLarge;

  static const TextStyle headingMedium = headlineMedium;

  static const TextStyle headingSmall = headlineSmall;

  // ============================================================
  // BUTTON TYPOGRAPHY
  // ============================================================

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.25,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: semiBold,
    height: 1.33,
    letterSpacing: 0.2,
  );

  /// Default button style.
  static const TextStyle button = buttonLarge;

  // ============================================================
  // CAPTION / SUPPORTING TEXT
  // ============================================================

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.3,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: semiBold,
    height: 1.45,
    letterSpacing: 1.0,
  );

  static const TextStyle helperText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.4,
  );

  static const TextStyle errorText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
  );

  // ============================================================
  // BRAND / HERO
  // ============================================================

  static const TextStyle brandTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static const TextStyle heroTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: regular,
    height: 1.5,
  );

  // ============================================================
  // AI CHAT
  // ============================================================

  static const TextStyle aiMessage = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: regular,
    height: 1.55,
    letterSpacing: 0.1,
  );

  static const TextStyle aiMessageStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: semiBold,
    height: 1.55,
    letterSpacing: 0.1,
  );

  static const TextStyle chatTimestamp = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: regular,
    height: 1.3,
  );

  static const TextStyle chatInput = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.4,
  );

  // ============================================================
  // TRAVEL / DESTINATIONS
  // ============================================================

  static const TextStyle destinationTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: bold,
    height: 1.3,
  );

  static const TextStyle destinationSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.4,
  );

  static const TextStyle destinationOverlayTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: bold,
    height: 1.25,
  );

  static const TextStyle location = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: medium,
    height: 1.4,
  );

  // ============================================================
  // HOTEL / FOOD / RATINGS
  // ============================================================

  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: bold,
    height: 1.25,
  );

  static const TextStyle priceLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: bold,
    height: 1.25,
  );

  static const TextStyle rating = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: semiBold,
    height: 1.3,
  );

  // ============================================================
  // NAVIGATION
  // ============================================================

  static const TextStyle navigationLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.3,
  );

  static const TextStyle navigationLabelSelected = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: bold,
    height: 1.3,
  );

  // ============================================================
  // PROFILE / STATS
  // ============================================================

  static const TextStyle statValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: bold,
    height: 1.2,
  );

  static const TextStyle statLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
  );

  // ============================================================
  // MATERIAL 3 TEXT THEME
  // ============================================================

  /// Base Material 3 typography used by AppTheme.
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  // ============================================================
  // THEME-AWARE TEXT THEME BUILDER
  // ============================================================

  /// Applies the current ColorScheme to the typography system.
  ///
  /// This lets light/dark mode control text colors automatically.
  static TextTheme buildTextTheme(ColorScheme colorScheme) {
    return textTheme.copyWith(
      displayLarge: displayLarge.copyWith(color: colorScheme.onSurface),
      displayMedium: displayMedium.copyWith(color: colorScheme.onSurface),
      displaySmall: displaySmall.copyWith(color: colorScheme.onSurface),
      headlineLarge: headlineLarge.copyWith(color: colorScheme.onSurface),
      headlineMedium: headlineMedium.copyWith(color: colorScheme.onSurface),
      headlineSmall: headlineSmall.copyWith(color: colorScheme.onSurface),
      titleLarge: titleLarge.copyWith(color: colorScheme.onSurface),
      titleMedium: titleMedium.copyWith(color: colorScheme.onSurface),
      titleSmall: titleSmall.copyWith(color: colorScheme.onSurface),
      bodyLarge: bodyLarge.copyWith(color: colorScheme.onSurface),
      bodyMedium: bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
      bodySmall: bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
      labelLarge: labelLarge.copyWith(color: colorScheme.onSurface),
      labelMedium: labelMedium.copyWith(color: colorScheme.onSurfaceVariant),
      labelSmall: labelSmall.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  AppTextStyles._();
}
