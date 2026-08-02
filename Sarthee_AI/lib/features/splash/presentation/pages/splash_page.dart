import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sarthee_ai/features/auth/auth_provider.dart';
import 'package:sarthee_ai/features/auth/widgets/auth_loading_widget.dart';
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

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background Gradient: #FFFFFF -> #F6F8FF -> #FFFFFF
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

          // India Skyline Background Artwork (Opacity 0.08 - 0.10)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: Opacity(
                  opacity: 0.09,
                  child: Image.asset(
                    'assets/images/splash/india_skyline.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ),

          // Foreground Content Hierarchy
          SafeArea(
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
        ],
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
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool compactHeight = availableHeight < 650;
    final bool reduceMotion = mediaQuery.disableAnimations;

    final Widget startupState = _buildStartupState(context);

    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: _horizontalPadding(availableWidth),
                vertical: compactHeight ? 16 : 28,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Semantics(
                  container: true,
                  label: 'Sarthee AI startup screen',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // 1. Animated Logo
                      SplashLogo(
                        size: compactHeight ? 110 : 134,
                        animate: !reduceMotion,
                      ),

                      SizedBox(height: compactHeight ? 20 : 28),

                      // 2. Title: "Starting Sarthee AI" (fontSize: 32, w700, letterSpacing: -0.5)
                      Semantics(
                        header: true,
                        child: Text(
                          'Starting Sarthee AI',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFF1E293B),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 3. Divider: ──── ✦ ──── (Opacity ~40%)
                      Opacity(
                        opacity: 0.40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            SizedBox(
                              width: 44,
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            SizedBox(
                              width: 44,
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 4. Description: "Preparing your personalized experience..."
                      Text(
                        'Preparing your personalized experience...',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF475569),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),

                      SizedBox(height: compactHeight ? 20 : 26),

                      // 5. Time Info Container: Schedule Icon + 30s notice
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.schedule_rounded,
                                size: 18,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'First launch may take a little longer\nwhile we prepare everything for you.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF334155),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: compactHeight ? 28 : 36),

                      // 6. Loading Indicator / Real-state progress
                      startupState,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 7. Footer: Secure • Intelligent • Personalized (fontSize: 13, opacity: 0.55)
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: Opacity(
            opacity: 0.55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(
                  Icons.verified_user_outlined,
                  size: 14,
                  color: Color(0xFF475569),
                ),
                SizedBox(width: 6),
                Text(
                  'Secure  •  Intelligent  •  Personalized',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

    return SplashLoadingIndicator(
      key: const ValueKey<String>('splash-indicator'),
      message: stepMessage,
      progress: progress,
      showSpinner: true,
    );
  }

  double _horizontalPadding(double width) {
    if (!width.isFinite || width <= 0) {
      return 24;
    }
    if (width >= 840) return 40;
    return 24;
  }
}
