import 'package:flutter/material.dart';

/// Shared auth background maintaining visual continuity with Splash & Onboarding.
///
/// Features:
/// • Gradient background: #FFFFFF -> #F6F8FF -> #FFFFFF
/// • Subtle bottom India skyline artwork (~8% opacity)
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          // 1. Background Gradient Backdrop
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFFFFFFFF),
                    Color(0xFFF6F8FF),
                    Color(0xFFFFFFFF),
                  ],
                  stops: <double>[0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 2. India Skyline Background Artwork (Opacity 0.08)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: Opacity(
                  opacity: 0.08,
                  child: Image.asset(
                    'assets/images/splash/india_skyline.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),

          // 3. Foreground Content Container
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
