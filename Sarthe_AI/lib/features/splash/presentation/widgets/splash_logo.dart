import 'package:flutter/material.dart';

/// Animated brand mark displayed during Sarthee AI startup.
///
/// Pulse Animation:
/// • Scale: 1.00 -> 1.04 -> 1.00
/// • Duration: 1400ms repeating
class SplashLogo extends StatefulWidget {
  const SplashLogo({super.key, this.size = 140, this.animate = true})
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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 1.00, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SplashLogo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animate == widget.animate) {
      return;
    }

    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Widget logo = Hero(
      tag: 'sarthee-logo',
      child: Semantics(
        image: true,
        label: 'Sarthee AI logo',
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.18),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/logo/sarthee_logo.png',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF0066FF),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.travel_explore_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              );
            },
          ),
        ),
      ),
    );

    if (!widget.animate || reduceMotion) {
      return logo;
    }

    return ScaleTransition(scale: _scaleAnimation, child: logo);
  }
}
