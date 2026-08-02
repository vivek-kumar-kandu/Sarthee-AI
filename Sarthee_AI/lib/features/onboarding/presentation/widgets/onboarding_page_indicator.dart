import 'package:flutter/material.dart';

/// Animated page dot indicator for Onboarding Carousel.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    required this.currentIndex,
    required this.itemCount,
    required this.activeColor,
    super.key,
  });

  final int currentIndex;
  final int itemCount;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(itemCount, (int index) {
        final bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 10 : 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? activeColor
                : activeColor.withValues(alpha: 0.22),
          ),
        );
      }),
    );
  }
}
