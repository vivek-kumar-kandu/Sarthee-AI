import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../auth/auth_provider.dart';

const String kHasCompletedOnboardingKey = 'has_completed_onboarding';

/// Riverpod controller managing onboarding index and page navigation.
class OnboardingController extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void onPageChanged(int index) {
    state = index;
  }

  void nextPage(PageController pageController) {
    if (state < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void previousPage(PageController pageController) {
    if (state > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> completeOnboarding(BuildContext context) async {
    // 1. Mark onboarding completed in SharedPreferences and update Riverpod state immediately
    await ref.read(hasCompletedOnboardingProvider.notifier).markCompleted();

    if (!context.mounted) return;

    // 2. Navigate to appropriate post-onboarding screen
    final authState = ref.read(authStartupProvider);
    if (authState.isAuthenticated) {
      context.go(RoutePaths.home);
    } else {
      context.go(RoutePaths.login);
    }
  }

  Future<void> skip(BuildContext context) async {
    await completeOnboarding(context);
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, int>(OnboardingController.new);

/// Reactive Notifier managing [hasCompletedOnboarding] state for route guards and router.
class HasCompletedOnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(kHasCompletedOnboardingKey) ?? false;
  }

  Future<void> markCompleted() async {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(kHasCompletedOnboardingKey, true);
    state = true;
  }
}

final hasCompletedOnboardingProvider =
    NotifierProvider<HasCompletedOnboardingNotifier, bool>(
  HasCompletedOnboardingNotifier.new,
);
