import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/responsive/app_responsive.dart';

import '../providers/home_provider.dart';
import '../widgets/home_ai_section.dart';
import '../widgets/home_greeting_section.dart';
import '../widgets/home_journey_section.dart';
import '../widgets/home_nearby_section.dart';
import '../widgets/home_quick_action_section.dart';
import '../widgets/home_search_section.dart';
import '../widgets/home_skeleton_loader.dart';

/// Sarthee AI Main Home Dashboard Page (Phase 1).
///
/// Architecture:
/// Pure layout coordinator consuming [homeProvider] state.
/// Contains zero UI business logic.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF4F46E5),
          onRefresh: () => ref.read(homeProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: AppResponsive.screenPadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: homeAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: HomeSkeletonLoader(),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 40,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Unable to load dashboard data',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ref.read(homeProvider.notifier).refresh(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (data) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 8),

                        // 1. Time-Aware Greeting Header Section
                        HomeGreetingSection(
                          greeting: data.greeting,
                          onPassportPressed: () {
                            context.push(RoutePaths.profile);
                          },
                        ),

                        const SizedBox(height: 20),

                        // 2. Universal Search Bar Section
                        HomeSearchSection(
                          onTap: () {
                            context.push(RoutePaths.explore);
                          },
                        ),

                        const SizedBox(height: 20),

                        // 3. Quick Action 4-Card Grid Section
                        HomeQuickActionSection(
                          actions: data.quickActions,
                          onActionPressed: (action) {
                            context.push(action.routePath);
                          },
                        ),

                        const SizedBox(height: 24),

                        // 4. Continue Your Journey Section
                        HomeJourneySection(
                          journey: data.activeJourney,
                          onJourneyPressed: (journey) {
                            context.push(RoutePaths.trips);
                          },
                          onStartPlanPressed: () {
                            context.push(RoutePaths.trips);
                          },
                        ),

                        const SizedBox(height: 24),

                        // 5. Ask Sarthee AI Starter Prompts Section
                        HomeAISection(
                          prompts: data.aiPrompts,
                          onPromptSelected: (prompt) {
                            context.push(RoutePaths.ai);
                          },
                        ),

                        const SizedBox(height: 24),

                        // 6. Explore Nearby Places Section
                        HomeNearbySection(
                          places: data.nearbyPlaces,
                          onPlacePressed: (place) {
                            context.push(RoutePaths.explore);
                          },
                          onExploreAllPressed: () {
                            context.push(RoutePaths.explore);
                          },
                        ),

                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
