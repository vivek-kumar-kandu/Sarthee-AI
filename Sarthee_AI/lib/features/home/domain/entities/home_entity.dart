import 'package:flutter/material.dart';

/// Aggregate Domain Entity for Sarthee AI Home Dashboard (Phase 1).
@immutable
class HomeEntity {
  const HomeEntity({
    required this.greeting,
    required this.quickActions,
    required this.aiPrompts,
    this.activeJourney,
    this.nearbyPlaces = const <NearbyPlace>[],
    required this.lastUpdated,
  });

  final HomeGreeting greeting;
  final List<HomeQuickAction> quickActions;
  final List<HomeAiPrompt> aiPrompts;
  final ActiveJourney? activeJourney;
  final List<NearbyPlace> nearbyPlaces;
  final DateTime lastUpdated;

  HomeEntity copyWith({
    HomeGreeting? greeting,
    List<HomeQuickAction>? quickActions,
    List<HomeAiPrompt>? aiPrompts,
    ActiveJourney? activeJourney,
    List<NearbyPlace>? nearbyPlaces,
    DateTime? lastUpdated,
  }) {
    return HomeEntity(
      greeting: greeting ?? this.greeting,
      quickActions: quickActions ?? this.quickActions,
      aiPrompts: aiPrompts ?? this.aiPrompts,
      activeJourney: activeJourney ?? this.activeJourney,
      nearbyPlaces: nearbyPlaces ?? this.nearbyPlaces,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Dynamic Header Greeting & Location Metadata
@immutable
class HomeGreeting {
  const HomeGreeting({
    required this.userName,
    required this.city,
    required this.temperature,
    required this.weatherCondition,
    this.avatarUrl,
  });

  final String userName;
  final String city;
  final String temperature;
  final String weatherCondition;
  final String? avatarUrl;

  /// Determines time-aware greeting string (Good Morning / Afternoon / Evening)
  String get dynamicGreetingText {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}

/// Action Card for Quick Actions Grid
@immutable
class HomeQuickAction {
  const HomeQuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.routePath,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String routePath;
}

/// Curated AI Prompt Card for "Ask Sarthee AI" Section
@immutable
class HomeAiPrompt {
  const HomeAiPrompt({
    required this.id,
    required this.title,
    required this.promptText,
    required this.iconEmoji,
    required this.category,
  });

  final String id;
  final String title;
  final String promptText;
  final String iconEmoji;
  final String category;
}

/// Represents an active ongoing trip, upcoming booking, or saved draft itinerary.
@immutable
class ActiveJourney {
  const ActiveJourney({
    required this.id,
    required this.title,
    required this.destination,
    required this.daysRemaining,
    required this.statusLabel,
    required this.statusColor,
    required this.coverImageUrl,
    required this.weatherForecast,
  });

  final String id;
  final String title;
  final String destination;
  final int daysRemaining;
  final String statusLabel;
  final Color statusColor;
  final String coverImageUrl;
  final String weatherForecast;
}

/// Recommended Nearby Place Item
@immutable
class NearbyPlace {
  const NearbyPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.distance,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final double rating;
  final String distance;
  final String imageUrl;
}
