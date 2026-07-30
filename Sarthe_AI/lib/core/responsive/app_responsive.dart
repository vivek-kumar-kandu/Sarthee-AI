import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

/// Lightweight global helper for responsive layout decisions, breakpoints, and adaptive scaling.
///
/// Guidelines:
/// • Keep responsive framework usage lightweight; use helpers for structural decisions,
///   padding, and typography bounds where they add value, avoiding over-engineering.
/// • Select the appropriate scrollable widget (`ListView`, `CustomScrollView`, `GridView`, or
///   `SingleChildScrollView`) based on each screen's specific requirements.
class AppResponsive {
  const AppResponsive._();

  /// Gets current device category.
  static DeviceCategory category(BuildContext context) {
    return ResponsiveBreakpoints.getCategory(context);
  }

  /// Returns true if device is small phone (< 360dp).
  static bool isCompact(BuildContext context) => category(context).isCompact;

  /// Returns true if device is mobile phone (< 600dp).
  static bool isMobile(BuildContext context) => category(context).isMobile;

  /// Returns true if device is tablet/desktop (>= 600dp).
  static bool isTabletOrLarger(BuildContext context) => !isMobile(context);

  /// Selects responsive value based on device category.
  static T value<T>(
    BuildContext context, {
    required T compact,
    T? standard,
    T? foldable,
    T? tablet,
  }) {
    final cat = category(context);
    switch (cat) {
      case DeviceCategory.compact:
        return compact;
      case DeviceCategory.standard:
        return standard ?? compact;
      case DeviceCategory.foldable:
        return foldable ?? standard ?? compact;
      case DeviceCategory.tablet:
        return tablet ?? foldable ?? standard ?? compact;
    }
  }

  /// Calculates viewport height fraction.
  static double heightFraction(BuildContext context, double fraction) {
    return MediaQuery.sizeOf(context).height * fraction;
  }

  /// Calculates viewport width fraction.
  static double widthFraction(BuildContext context, double fraction) {
    return MediaQuery.sizeOf(context).width * fraction;
  }

  /// Scales font size respecting accessibility text scale factor up to max limit.
  static double scaledFontSize(BuildContext context, double baseFontSize, {double maxScaleFactor = 1.35}) {
    final double textScaler = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.85, maxScaleFactor);
    return baseFontSize * textScaler;
  }

  /// Responsive horizontal padding for screen containers.
  static EdgeInsets screenPadding(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= 840) return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    if (width >= 600) return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    if (width <= 360) return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
  }
}
