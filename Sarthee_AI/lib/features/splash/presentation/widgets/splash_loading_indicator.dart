import 'package:flutter/material.dart';

/// Premium startup progress presentation for Sarthee AI featuring a pulse animated progress loader.
class SplashLoadingIndicator extends StatefulWidget {
  const SplashLoadingIndicator({
    required this.message,
    super.key,
    this.progress,
    this.showSpinner = true,
  });

  final String message;
  final double? progress;
  final bool showSpinner;

  @override
  State<SplashLoadingIndicator> createState() => _SplashLoadingIndicatorState();
}

class _SplashLoadingIndicatorState extends State<SplashLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Semantics(
      container: true,
      liveRegion: true,
      label: widget.message,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.showSpinner)
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.08),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  backgroundColor: colors.primary.withValues(alpha: 0.15),
                ),
              ),
            ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            reverseDuration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.18),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              widget.message,
              key: ValueKey<String>(widget.message),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.primary.withValues(alpha: 0.90),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
