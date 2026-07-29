import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/auth_provider.dart';
import '../../../auth/state/auth_startup_state.dart';
import '../../domain/splash_state.dart';

/// Splash presentation controller — mirrors auth startup progress.
///
/// Authentication bootstrap is owned by [AuthController]. This controller
/// waits for that pipeline and exposes human-readable progress for the splash UI.
class SplashController extends Notifier<SplashState> {
  bool _isInitializing = false;
  bool _isDisposed = false;

  @override
  SplashState build() {
    ref.onDispose(() {
      _isDisposed = true;
    });

    ref.listen<AuthStartupState>(authStartupProvider, (previous, next) {
      if (!_canUpdateState) {
        return;
      }
      _syncFromAuthStartup(next);
    });

    return const SplashState.initial();
  }

  Future<void> initialize() async {
    if (_isInitializing || state.isReady) {
      return;
    }

    _isInitializing = true;

    state = state.start(message: 'Preparing Sarthee');

    try {
      final AuthStartupState startup = ref.read(authStartupProvider);
      if (startup.bootstrapComplete) {
        _syncFromAuthStartup(startup);
        return;
      }

      await ref.read(authControllerProvider.notifier).waitForBootstrap();

      if (!_canUpdateState) {
        return;
      }

      _syncFromAuthStartup(ref.read(authStartupProvider));
    } on Object catch (error, stackTrace) {
      if (!_canUpdateState) {
        return;
      }

      _reportBootstrapError(error, stackTrace);
      state = state.fail(errorMessage: _userFriendlyError(error));
    } finally {
      _isInitializing = false;
    }
  }

  void _syncFromAuthStartup(AuthStartupState startup) {
    if (startup.hasError && startup.isOffline) {
      state = state.fail(
        errorMessage:
            startup.error ??
            'No internet connection. Please check your network.',
      );
      return;
    }

    if (startup.hasError) {
      state = state.fail(
        errorMessage: startup.error ?? 'Authentication failed.',
      );
      return;
    }

    if (startup.bootstrapComplete) {
      state = state.complete(message: startup.stepMessage);
      return;
    }

    state = state.updateProgress(
      startup.progress,
      message: startup.stepMessage,
    );
  }

  Future<void> retry() async {
    if (_isInitializing) {
      return;
    }

    if (!state.hasError && !ref.read(authStartupProvider).hasError) {
      return;
    }

    state = state.prepareRetry(message: 'Retrying startup');

    final AuthStartupState startup = ref.read(authStartupProvider);
    if (startup.hasError) {
      await ref.read(authControllerProvider.notifier).retryBootstrap();
    }

    await initialize();
  }

  void reset() {
    if (_isInitializing) {
      return;
    }

    state = const SplashState.initial();
  }

  bool get _canUpdateState => !_isDisposed;

  String _userFriendlyError(Object error) {
    return 'Sarthee AI could not finish starting. Please try again.';
  }

  void _reportBootstrapError(Object error, StackTrace stackTrace) {
    Zone.current.handleUncaughtError(error, stackTrace);
  }
}

final splashControllerProvider =
    NotifierProvider<SplashController, SplashState>(SplashController.new);

final splashReadyProvider = Provider<bool>((ref) {
  return ref.watch(
    authStartupProvider.select((state) => state.bootstrapComplete),
  );
});

final splashFailureProvider = Provider<bool>((ref) {
  final AuthStartupState startup = ref.watch(authStartupProvider);
  return ref.watch(
        splashControllerProvider.select((SplashState state) => state.hasError),
      ) ||
      (startup.hasError && startup.isOffline);
});

/// Current auth step message for splash UI.
final splashStepMessageProvider = Provider<String>((ref) {
  return ref.watch(authStartupProvider.select((state) => state.stepMessage));
});

/// Auth startup progress for splash UI (0.0 – 1.0).
final splashAuthProgressProvider = Provider<double>((ref) {
  return ref.watch(authStartupProvider.select((state) => state.progress));
});
