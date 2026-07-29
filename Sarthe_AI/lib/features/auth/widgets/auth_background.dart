import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerLow,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.mobileHorizontalPadding,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
