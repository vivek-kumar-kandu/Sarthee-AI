import 'package:flutter/material.dart';

import 'onboarding_item.dart';

/// Official Onboarding Content Data for Sarthee AI.
abstract class OnboardingData {
  static const List<OnboardingItem> items = <OnboardingItem>[
    OnboardingItem(
      title: 'Discover\nIncredible India',
      description:
          'Explore iconic destinations, hidden gems, local culture, food, festivals, and unforgettable experiences—all in one intelligent travel companion.',
      imageAsset: 'assets/images/onboarding/slide1_discover_india.png',
      primaryColor: Color(0xFF4F46E5),
      accentColor: Color(0xFF6366F1),
      buttonText: 'Next  →',
    ),
    OnboardingItem(
      title: 'Meet\nSarthee AI',
      description:
          'Ask anything about destinations, routes, history, hotels, restaurants, weather, or nearby attractions. Sarthee AI provides intelligent travel guidance based on your context.',
      imageAsset: 'assets/images/onboarding/slide2_sarthee_ai.png',
      primaryColor: Color(0xFF4338CA),
      accentColor: Color(0xFF4F46E5),
      buttonText: 'Next  →',
    ),
    OnboardingItem(
      title: 'Travel\nSmarter',
      description:
          'Plan trips, receive personalized recommendations, manage budgets, explore culture, and travel safely with one connected companion.',
      imageAsset: 'assets/images/onboarding/slide3_travel_smarter.png',
      primaryColor: Color(0xFF0F766E),
      accentColor: Color(0xFF14B8A6),
      buttonText: 'Get Started  →',
    ),
  ];
}
