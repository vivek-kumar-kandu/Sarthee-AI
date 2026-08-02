import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/auth_exception.dart';
import 'repositories/auth_repository.dart';
import 'auth_service.dart';
import 'auth_state.dart';
import 'models/auth_user.dart';
import 'services/auth_bootstrap_service.dart';
import '../profile/domain/entities/profile_entity.dart';
import '../profile/providers/profile_provider.dart';
import '../profile/services/profile_cache_service.dart';
import '../location/services/location_cache_service.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref, authRepository: AuthService.instance),
);

/// Immutable auth startup state for routing and splash UI.
final authStartupProvider = Provider<AuthStartupState>((ref) {
  return ref.watch(
    authControllerProvider.select((AuthState state) => state.startup),
  );
});

final authUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStartupProvider.select((state) => state.user));
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStartupProvider.select((state) => state.isLoading));
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref, {required this._authRepository})
    : super(const AuthState()) {
    _initialize();
  }

  final Ref _ref;
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;
  bool _isBootstrapping = false;
  Future<void>? _bootstrapFuture;
  final Completer<void> _bootstrapCompleter = Completer<void>();

  Future<void> waitForBootstrap() async {
    if (state.startup.bootstrapComplete) {
      return;
    }
    return _bootstrapCompleter.future;
  }

  void _initialize() {
    _ref.onDispose(() {
      _authStateSubscription?.cancel();
    });

    _setStartup(const AuthStartupState());
    debugPrint('AUTH_INIT_START');

    _subscribeToAuthStateChanges();
    _bootstrapFuture = _runColdStartPipeline();
  }

  void _setStartup(AuthStartupState startup) {
    final AuthState previous = state;
    final AuthState next = AuthState(startup: startup);

    if (previous == next) {
      return;
    }

    if (kDebugMode) {
      debugPrint('AUTH_STATE_CHANGE: old: ${previous.startup}');
      debugPrint('AUTH_STATE_CHANGE: new: $startup');
    }

    state = next;

    if (startup.bootstrapComplete && !_bootstrapCompleter.isCompleted) {
      _bootstrapCompleter.complete();
      if (kDebugMode) {
        debugPrint('AUTH_READY');
      }
    }
  }

  void _subscribeToAuthStateChanges() {
    _authStateSubscription ??= _authRepository.authStateChanges.listen(
      (User? user) async {
        if (_bootstrapFuture != null) {
          try {
            await _bootstrapFuture;
          } catch (_) {}
        }

        if (_isBootstrapping) {
          return;
        }

        if (user == null) {
          if (!state.isUnauthenticated || !state.startup.bootstrapComplete) {
            _clearSessionState(
              const AuthStartupState(
                phase: AuthStartupPhase.unauthenticated,
                bootstrapComplete: true,
              ),
            );
          }
          return;
        }

        if (state.isAuthenticated && state.startup.user?.uid == user.uid) {
          return;
        }

        await _runAuthenticatedPipeline(user);
      },
      onError: (Object error, StackTrace stackTrace) {
        _setStartup(
          AuthStartupState(
            phase: AuthStartupPhase.error,
            error: error.toString(),
            bootstrapComplete: true,
          ),
        );
      },
    );
  }

  Future<void> _runColdStartPipeline() async {
    try {
      await _runStartupPipeline();
    } finally {
      _bootstrapFuture = null;
    }
  }

  Future<void> _runStartupPipeline({User? firebaseUser}) async {
    if (_isBootstrapping) {
      return;
    }

    _isBootstrapping = true;

    try {
      _setStartup(
        state.startup.copyWith(
          phase: AuthStartupPhase.initializing,
          clearError: true,
        ),
      );

      _setStartup(
        state.startup.copyWith(phase: AuthStartupPhase.checkingFirebaseSession),
      );

      final User? user = firebaseUser ?? _authRepository.currentUser;
      if (user == null) {
        debugPrint('AUTH_SESSION_EMPTY');
        _setStartup(
          const AuthStartupState(
            phase: AuthStartupPhase.unauthenticated,
            bootstrapComplete: true,
          ),
        );
        return;
      }

      debugPrint('AUTH_SESSION_FOUND uid=${user.uid}');
      await _validateAuthenticatedSession(user);
    } catch (error) {
      _handlePipelineError(error);
    } finally {
      _isBootstrapping = false;
    }
  }

  Future<void> _runAuthenticatedPipeline(User user) async {
    await _runStartupPipeline(firebaseUser: user);
  }

  Future<void> _validateAuthenticatedSession(User user) async {
    _setStartup(state.startup.copyWith(phase: AuthStartupPhase.restoringToken));

    _setStartup(
      state.startup.copyWith(phase: AuthStartupPhase.validatingBackendSession),
    );

    final AuthBootstrapResult result = await AuthBootstrapService.instance
        .validateSession();

    if (result.status == AuthBootstrapStatus.offline) {
      _setStartup(
        AuthStartupState(
          phase: AuthStartupPhase.error,
          user: AuthUser.fromFirebase(user),
          error: result.errorMessage,
          isOffline: true,
          bootstrapComplete: true,
        ),
      );
      return;
    }

    if (result.status == AuthBootstrapStatus.unauthenticated) {
      debugPrint('AUTH_SESSION_EMPTY');
      _clearSessionState(
        AuthStartupState(
          phase: AuthStartupPhase.unauthenticated,
          error: result.errorMessage,
          bootstrapComplete: true,
        ),
      );
      return;
    }

    if (result.status == AuthBootstrapStatus.error) {
      _setStartup(
        AuthStartupState(
          phase: AuthStartupPhase.error,
          error: result.errorMessage ?? 'Authentication failed.',
          bootstrapComplete: true,
        ),
      );
      return;
    }

    _setStartup(
      state.startup.copyWith(phase: AuthStartupPhase.checkingProfileCompletion),
    );

    final ProfileEntity? profile = result.profile;
    if (profile != null) {
      _ref.read(profileProvider.notifier).setProfile(profile);
    }

    final bool profileComplete = AuthBootstrapService.instance
        .checkProfileCompletion(profile);

    debugPrint('AUTH_PROFILE_VALIDATED complete=$profileComplete');

    _setStartup(
      AuthStartupState(
        phase: AuthStartupPhase.authenticated,
        user: AuthUser.fromFirebase(user),
        isProfileComplete: profileComplete,
        bootstrapComplete: true,
      ),
    );
  }

  void _handlePipelineError(Object error) {
    if (error is AuthException) {
      if (error.type == AuthErrorType.networkFailure) {
        _setStartup(
          AuthStartupState(
            phase: AuthStartupPhase.error,
            error: error.message,
            isOffline: true,
            bootstrapComplete: true,
          ),
        );
        return;
      }

      if (error.type == AuthErrorType.expiredSession) {
        _clearSessionState(
          AuthStartupState(
            phase: AuthStartupPhase.unauthenticated,
            error: error.message,
            bootstrapComplete: true,
          ),
        );
        return;
      }
    }

    _setStartup(
      AuthStartupState(
        phase: AuthStartupPhase.error,
        error: error.toString(),
        bootstrapComplete: true,
      ),
    );
  }

  void _clearSessionState(AuthStartupState startup) {
    _ref.read(profileProvider.notifier).clearProfile();
    AuthBootstrapService.instance.resetSessionValidation();
    _setStartup(startup);
  }

  Future<void> retryBootstrap() async {
    if (_isBootstrapping) {
      return;
    }

    _setStartup(const AuthStartupState(phase: AuthStartupPhase.initializing));

    await _runStartupPipeline();
  }

  /// Updates profile completion after PUT /auth/profile succeeds.
  void markProfileComplete() {
    if (!state.isAuthenticated) {
      return;
    }

    _setStartup(state.startup.copyWith(isProfileComplete: true));
  }

  Future<void> login({required String email, required String password}) async {
    if (_isBootstrapping) {
      return;
    }

    _setStartup(
      state.startup.copyWith(
        phase: AuthStartupPhase.checkingFirebaseSession,
        bootstrapComplete: false,
        clearError: true,
      ),
    );

    try {
      await _authRepository.login(email: email, password: password);
      final User? user = _authRepository.currentUser;
      if (user == null) {
        _setStartup(
          const AuthStartupState(
            phase: AuthStartupPhase.unauthenticated,
            bootstrapComplete: true,
          ),
        );
        return;
      }

      await _runStartupPipeline(firebaseUser: user);
    } on AuthException catch (error) {
      _setStartup(
        AuthStartupState(
          phase: AuthStartupPhase.error,
          error: error.message,
          bootstrapComplete: true,
        ),
      );
      rethrow;
    } catch (error) {
      _handlePipelineError(error);
      rethrow;
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    String? name,
  }) async {
    if (_isBootstrapping) {
      return;
    }

    _setStartup(
      state.startup.copyWith(
        phase: AuthStartupPhase.checkingFirebaseSession,
        bootstrapComplete: false,
        clearError: true,
      ),
    );

    try {
      await _authRepository.signup(
        email: email,
        password: password,
        name: name,
      );
      final User? user = _authRepository.currentUser;
      if (user == null) {
        _setStartup(
          const AuthStartupState(
            phase: AuthStartupPhase.unauthenticated,
            bootstrapComplete: true,
          ),
        );
        return;
      }

      await _runStartupPipeline(firebaseUser: user);
    } on AuthException catch (error) {
      _setStartup(
        AuthStartupState(
          phase: AuthStartupPhase.error,
          error: error.message,
          bootstrapComplete: true,
        ),
      );
      rethrow;
    } catch (error) {
      _handlePipelineError(error);
      rethrow;
    }
  }

  Future<void> googleLogin() async {
    if (_isBootstrapping) {
      return;
    }

    _setStartup(
      state.startup.copyWith(
        phase: AuthStartupPhase.checkingFirebaseSession,
        bootstrapComplete: false,
        clearError: true,
      ),
    );

    try {
      await _authRepository.googleLogin();
      final User? user = _authRepository.currentUser;
      if (user == null) {
        _setStartup(
          const AuthStartupState(
            phase: AuthStartupPhase.unauthenticated,
            bootstrapComplete: true,
          ),
        );
        return;
      }

      await _runStartupPipeline(firebaseUser: user);
    } on AuthException catch (error) {
      _setStartup(
        AuthStartupState(
          phase: AuthStartupPhase.error,
          error: error.message,
          bootstrapComplete: true,
        ),
      );
      rethrow;
    } catch (error) {
      _handlePipelineError(error);
      rethrow;
    }
  }

  Future<void> logout() async {
    _setStartup(
      state.startup.copyWith(phase: AuthStartupPhase.checkingFirebaseSession),
    );

    try {
      await _authRepository.logout();

      try {
        await ProfileCacheService.instance.clearCache();
      } catch (_) {}

      try {
        await LocationCacheService.instance.clear();
      } catch (_) {}

      AuthBootstrapService.instance.resetSessionValidation();
      _ref.read(profileProvider.notifier).clearProfile();

      _setStartup(
        const AuthStartupState(
          phase: AuthStartupPhase.unauthenticated,
          bootstrapComplete: true,
        ),
      );
    } catch (error) {
      _setStartup(
        AuthStartupState(
          phase: AuthStartupPhase.error,
          error: error.toString(),
          bootstrapComplete: true,
        ),
      );
      rethrow;
    }
  }
}
