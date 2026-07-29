import 'package:flutter/material.dart';

/// Animated brand mark displayed during Sarthee AI startup.
///
/// The widget is intentionally independent from SplashController so it can
/// later be reused by onboarding, authentication and branded loading screens.
class SplashLogo extends StatefulWidget {
  const SplashLogo({super.key, this.size = 112, this.animate = true})
    : assert(size > 0, 'SplashLogo size must be greater than zero.');

  final double size;
  final bool animate;

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant SplashLogo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animate == widget.animate) {
      return;
    }

    if (widget.animate) {
      _controller.forward(from: 0);
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Widget logo = Semantics(
      image: true,
      label: 'Sarthee AI logo',
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primaryContainer,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.travel_explore_rounded,
          size: widget.size * 0.48,
          color: colors.onPrimaryContainer,
        ),
      ),
    );

    if (!widget.animate || reduceMotion) {
      return logo;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: logo),
    );
  }
}
