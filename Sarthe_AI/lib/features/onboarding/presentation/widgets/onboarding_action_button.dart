import 'package:flutter/material.dart';

/// Dynamic CTA Button for Onboarding Slide ("Next →" vs "Get Started →").
class OnboardingActionButton extends StatelessWidget {
  const OnboardingActionButton({
    required this.text,
    required this.onPressed,
    required this.buttonColor,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: text.replaceAll('→', '').trim(),
      hint: text.contains('Get Started')
          ? 'Finishes onboarding and navigates to sign in'
          : 'Advances to next onboarding slide',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: buttonColor.withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Row(
              key: ValueKey<String>(text),
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
