import 'package:flutter/material.dart';

/// Screen device categories for Sarthee AI responsive design system.
enum DeviceCategory {
  compact,   // Small phones (< 360dp)
  standard,  // Standard phones (360dp – 599dp)
  foldable,  // Large phones / Foldables (600dp – 839dp)
  tablet;    // Tablets & Desktops (>= 840dp)

  bool get isCompact => this == DeviceCategory.compact;
  bool get isStandard => this == DeviceCategory.standard;
  bool get isFoldable => this == DeviceCategory.foldable;
  bool get isTablet => this == DeviceCategory.tablet;
  bool get isMobile => this == DeviceCategory.compact || this == DeviceCategory.standard;
}

/// Centralized responsive breakpoints.
class ResponsiveBreakpoints {
  const ResponsiveBreakpoints._();

  static const double compactMax = 359;
  static const double standardMax = 599;
  static const double foldableMax = 839;

  static DeviceCategory getCategory(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width <= compactMax) return DeviceCategory.compact;
    if (width <= standardMax) return DeviceCategory.standard;
    if (width <= foldableMax) return DeviceCategory.foldable;
    return DeviceCategory.tablet;
  }
}
