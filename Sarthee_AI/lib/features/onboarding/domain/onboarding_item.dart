import 'package:flutter/material.dart';

/// Immutable domain model for Onboarding slides.
class OnboardingItem {
  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.primaryColor,
    required this.accentColor,
    required this.buttonText,
  });

  final String title;
  final String description;
  final String imageAsset;
  final Color primaryColor;
  final Color accentColor;
  final String buttonText;
}
