import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/onboarding_data.dart';
import '../../domain/onboarding_item.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_action_button.dart';
import '../widgets/onboarding_page_indicator.dart';
import '../widgets/onboarding_slide_widget.dart';
import '../widgets/onboarding_top_bar.dart';

/// Main Onboarding Screen featuring full-screen artwork background and interactive controls.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;
  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      for (final item in OnboardingData.items) {
        precacheImage(AssetImage(item.imageAsset), context);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed(int currentIndex) {
    final notifier = ref.read(onboardingControllerProvider.notifier);
    if (currentIndex < OnboardingData.items.length - 1) {
      notifier.nextPage(_pageController);
    } else {
      notifier.completeOnboarding(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = ref.watch(onboardingControllerProvider);
    final OnboardingItem currentItem = OnboardingData.items[currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: <Widget>[
              // 1. Full-Screen PageView Rendering Immersive Background Artwork & Typography
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: OnboardingData.items.length,
                  onPageChanged: (int index) {
                    ref
                        .read(onboardingControllerProvider.notifier)
                        .onPageChanged(index);
                  },
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return OnboardingSlideWidget(
                      item: OnboardingData.items[index],
                      availableHeight: constraints.maxHeight,
                    );
                  },
                ),
              ),

              // 2. Floating Top Header Bar: Sarthee Logo (Left) & Skip Pill (Right)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: OnboardingTopBar(
                    onSkip: () {
                      ref
                          .read(onboardingControllerProvider.notifier)
                          .skip(context);
                    },
                  ),
                ),
              ),

              // 3. Floating Bottom Controls Row: Page Indicator (Left) & CTA Button (Right)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Left: Page Indicator
                        OnboardingPageIndicator(
                          currentIndex: currentIndex,
                          itemCount: OnboardingData.items.length,
                          activeColor: currentItem.primaryColor,
                        ),

                        // Right: Next / Get Started Button
                        OnboardingActionButton(
                          text: currentItem.buttonText,
                          buttonColor: currentItem.primaryColor,
                          onPressed: () => _onNextPressed(currentIndex),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
