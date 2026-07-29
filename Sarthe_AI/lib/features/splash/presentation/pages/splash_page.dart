import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/auth_provider.dart';
import '../../../auth/widgets/auth_loading_widget.dart';
import '../../domain/splash_state.dart';
import '../controllers/splash_controller.dart';
import '../widgets/splash_loading_indicator.dart';
import '../widgets/splash_logo.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _initializationScheduled = false;
  bool _retryInProgress = false;

  @override
  void initState() {
    super.initState();
    _scheduleInitialization();
  }

  void _scheduleInitialization() {
    if (_initializationScheduled) {
      return;
    }

    _initializationScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _initializeApplication();
    });
  }

  Future<void> _initializeApplication() async {
    if (!mounted) {
      return;
    }

    await ref.read(splashControllerProvider.notifier).initialize();
  }

  Future<void> _retryInitialization() async {
    if (_retryInProgress || !mounted) {
      return;
    }

    _retryInProgress = true;

    try {
      await ref.read(splashControllerProvider.notifier).retry();
    } finally {
      _retryInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final SplashState splashState = ref.watch(splashControllerProvider);
    final String stepMessage = ref.watch(splashStepMessageProvider);
    final double authProgress = ref.watch(splashAuthProgressProvider);
    final startup = ref.watch(authStartupProvider);

    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return _SplashContent(
              state: splashState,
              stepMessage: stepMessage,
              progress: authProgress,
              showRetry: startup.hasError,
              availableWidth: constraints.maxWidth,
              availableHeight: constraints.maxHeight,
              onRetry: _retryInitialization,
            );
          },
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.state,
    required this.stepMessage,
    required this.progress,
    required this.showRetry,
    required this.availableWidth,
    required this.availableHeight,
    required this.onRetry,
  });

  final SplashState state;
  final String stepMessage;
  final double progress;
  final bool showRetry;
  final double availableWidth;
  final double availableHeight;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool compactHeight = availableHeight < 600;
    final bool reduceMotion = mediaQuery.disableAnimations;
    final double horizontalPadding = _horizontalPadding(availableWidth);
    final double logoSize = _logoSize(
      width: availableWidth,
      compactHeight: compactHeight,
    );

    final Widget startupState = _buildStartupState(context);

    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: compactHeight ? 24 : 40,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Semantics(
            container: true,
            label: 'Sarthee AI startup',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SplashLogo(size: logoSize, animate: !reduceMotion),
                SizedBox(height: compactHeight ? 22 : 30),
                Semantics(
                  header: true,
                  child: Text(
                    'Sarthee AI',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Smart travel. Local culture. AI assistance.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: compactHeight ? 30 : 44),
                if (reduceMotion)
                  startupState
                else
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    reverseDuration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: startupState,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartupState(BuildContext context) {
    if (state.hasError || showRetry) {
      return AuthLoadingWidget(
        key: const ValueKey<String>('splash-error'),
        message: stepMessage,
        showRetry: true,
        onRetry: () {
          onRetry();
        },
      );
    }

    if (state.isReady) {
      return SplashLoadingIndicator(
        key: const ValueKey<String>('splash-ready'),
        progress: 1.0,
        message: stepMessage,
        indeterminate: false,
        showPercentage: false,
      );
    }

    return SplashLoadingIndicator(
      key: const ValueKey<String>('splash-loading'),
      progress: progress.clamp(0.0, 1.0),
      message: stepMessage,
      indeterminate: progress <= 0.05,
      showPercentage: progress > 0.05,
    );
  }

  double _horizontalPadding(double width) {
    if (!width.isFinite || width <= 0) {
      return 24;
    }
    if (width >= 1600) return 80;
    if (width >= 1200) return 64;
    if (width >= 840) return 48;
    if (width >= 600) return 32;
    return 24;
  }

  double _logoSize({required double width, required bool compactHeight}) {
    if (compactHeight) return 84;
    if (width >= 840) return 120;
    return 104;
  }
}
