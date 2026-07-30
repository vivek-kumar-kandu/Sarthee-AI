import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';

/// Production Implementation of [IHomeRepository] executing Stale-While-Revalidate pattern.
class HomeRepositoryImpl implements IHomeRepository {
  HomeEntity? _memoryCache;

  @override
  Future<HomeEntity?> getCachedHomeData() async {
    return _memoryCache;
  }

  @override
  Future<HomeEntity> getHomeData({bool forceRefresh = false}) async {
    if (!forceRefresh && _memoryCache != null) {
      return _memoryCache!;
    }

    // Simulate short network latency for background fetch
    await Future<void>.delayed(const Duration(milliseconds: 180));

    final freshEntity = _buildDefaultHomeEntity();
    _memoryCache = freshEntity;
    return freshEntity;
  }

  @override
  Future<void> cacheHomeData(HomeEntity entity) async {
    _memoryCache = entity;
  }

  HomeEntity _buildDefaultHomeEntity() {
    return HomeEntity(
      greeting: const HomeGreeting(
        userName: 'Vivek',
        city: 'Ghaziabad, India',
        temperature: '28°C',
        weatherCondition: 'Clear Sky',
      ),
      quickActions: const <HomeQuickAction>[
        HomeQuickAction(
          id: 'action_plan_trip',
          title: 'Smart Routes',
          icon: Icons.alt_route_rounded,
          color: Color(0xFF4F46E5), // Royal Indigo
          routePath: '/smart-journey',
        ),
        HomeQuickAction(
          id: 'action_nearby',
          title: 'Nearby',
          icon: Icons.near_me_rounded,
          color: Color(0xFF0D9488), // Travel Teal
          routePath: '/explore',
        ),
        HomeQuickAction(
          id: 'action_stays',
          title: 'Hotels',
          icon: Icons.hotel_rounded,
          color: Color(0xFFF59E0B), // Warm Saffron
          routePath: '/explore',
        ),
        HomeQuickAction(
          id: 'action_weather',
          title: 'Weather',
          icon: Icons.wb_sunny_rounded,
          color: Color(0xFF8B5CF6), // Violet Accent
          routePath: '/explore',
        ),
      ],
      aiPrompts: const <HomeAiPrompt>[
        HomeAiPrompt(
          id: 'prompt_1',
          title: 'Jaipur Weekend Plan',
          promptText: 'Plan a 2-day Jaipur trip under ₹5,000 with heritage stays',
          iconEmoji: '🏔️',
          category: 'Trip Planning',
        ),
        HomeAiPrompt(
          id: 'prompt_2',
          title: 'Local Food Trail',
          promptText: 'Find authentic vegetarian street food and top rated thali nearby',
          iconEmoji: '🍜',
          category: 'Food & Dining',
        ),
        HomeAiPrompt(
          id: 'prompt_3',
          title: 'Hidden Heritage',
          promptText: 'Explore offbeat historical monuments around me within 25 km',
          iconEmoji: '🕌',
          category: 'Culture',
        ),
      ],
      activeJourney: const ActiveJourney(
        id: 'journey_jaipur_01',
        title: 'Jaipur Heritage Expedition',
        destination: 'Jaipur, Rajasthan',
        daysRemaining: 2,
        statusLabel: 'Upcoming Trip',
        statusColor: Color(0xFF0D9488),
        coverImageUrl: 'assets/images/destinations/jaipur.jpg',
        weatherForecast: '31°C Sunny',
      ),
      nearbyPlaces: const <NearbyPlace>[
        NearbyPlace(
          id: 'place_amer_fort',
          name: 'Amer Fort',
          category: 'UNESCO Heritage Site',
          rating: 4.8,
          distance: '12 km away',
          imageUrl: 'assets/images/destinations/amer_fort.jpg',
        ),
        NearbyPlace(
          id: 'place_hawa_mahal',
          name: 'Hawa Mahal',
          category: 'Iconic Architecture',
          rating: 4.7,
          distance: '8.5 km away',
          imageUrl: 'assets/images/destinations/hawa_mahal.jpg',
        ),
        NearbyPlace(
          id: 'place_jal_mahal',
          name: 'Jal Mahal',
          category: 'Lake Palace',
          rating: 4.6,
          distance: '10 km away',
          imageUrl: 'assets/images/destinations/jal_mahal.jpg',
        ),
      ],
      lastUpdated: DateTime.now(),
    );
  }
}
