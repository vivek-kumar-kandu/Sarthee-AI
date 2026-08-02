import 'package:flutter/material.dart';

/// Header widget for Onboarding Screen.
class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    required this.onSkip,
    super.key,
  });

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Brand Hero Mark (Balanced size & alignment)
          Hero(
            tag: 'sarthee-logo',
            child: Semantics(
              label: 'Sarthee AI logo mark',
              image: true,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/logo/sarthee_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // Premium Translucent Glassmorphic Skip Pill Button
          Semantics(
            button: true,
            label: 'Skip onboarding',
            hint: 'Navigates directly to authentication screen',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSkip,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Subtle translucent glass tint
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.10),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
