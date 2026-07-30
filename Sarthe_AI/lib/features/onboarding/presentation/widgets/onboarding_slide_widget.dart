import 'package:flutter/material.dart';

import '../../domain/onboarding_item.dart';

/// Single Onboarding Slide Presentation with Full-Screen Background Artwork.
class OnboardingSlideWidget extends StatelessWidget {
  const OnboardingSlideWidget({
    required this.item,
    required this.availableHeight,
    super.key,
  });

  final OnboardingItem item;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // 1. Full-Screen Immersive Artwork Background
        Semantics(
          image: true,
          label: '${item.title.replaceAll('\n', ' ')} background artwork',
          child: Image.asset(
            item.imageAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFF8FAFC),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 72,
                    color: item.primaryColor.withValues(alpha: 0.4),
                  ),
                ),
              );
            },
          ),
        ),

        // 2. Subtle Gradient Overlay to Ensure High Contrast & Text Readability
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.90),
                Colors.white,
              ],
              stops: const <double>[0.0, 0.42, 0.72, 1.0],
            ),
          ),
        ),

        // 3. Foreground Text Content (Title, Star Divider, Description)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: <Widget>[
                const Spacer(flex: 9),

                // Title
                Semantics(
                  header: true,
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF0F172A),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Divider with ✦ (Opacity ~40%)
                Opacity(
                  opacity: 0.40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 36,
                        child: Divider(
                          thickness: 1.5,
                          color: item.primaryColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.star_rounded,
                          size: 10,
                          color: item.primaryColor,
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        child: Divider(
                          thickness: 1.5,
                          color: item.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF334155),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),
                ),

                const SizedBox(height: 84), // Reserved space for bottom controls
              ],
            ),
          ),
        ),
      ],
    );
  }
}
