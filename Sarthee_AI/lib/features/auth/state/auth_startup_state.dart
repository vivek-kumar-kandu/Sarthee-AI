import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';

/// Enterprise auth startup phases — single source of truth for bootstrap.
enum AuthStartupPhase {
  initializing,
  checkingFirebaseSession,
  restoringToken,
  validatingBackendSession,
  checkingProfileCompletion,
  authenticated,
  unauthenticated,
  error;

  bool get isBootstrapping =>
      this == AuthStartupPhase.initializing ||
      this == AuthStartupPhase.checkingFirebaseSession ||
      this == AuthStartupPhase.restoringToken ||
      this == AuthStartupPhase.validatingBackendSession ||
      this == AuthStartupPhase.checkingProfileCompletion;

  bool get isTerminal =>
      this == AuthStartupPhase.authenticated ||
      this == AuthStartupPhase.unauthenticated ||
      this == AuthStartupPhase.error;
}

/// Immutable auth startup state exposed to UI and routing layers.
///
/// No widget should read [FirebaseAuth] directly — consume this state instead.
@immutable
class AuthStartupState {
  const AuthStartupState({
    this.phase = AuthStartupPhase.initializing,
    this.user,
    this.error,
    this.isProfileComplete = false,
    this.isOffline = false,
    this.bootstrapComplete = false,
  });

  final AuthStartupPhase phase;
  final AuthUser? user;
  final String? error;
  final bool isProfileComplete;
  final bool isOffline;
  final bool bootstrapComplete;

  bool get isAuthenticated => phase == AuthStartupPhase.authenticated;

  bool get isUnauthenticated => phase == AuthStartupPhase.unauthenticated;

  bool get hasError => phase == AuthStartupPhase.error;

  bool get isLoading => phase.isBootstrapping;

  /// Human-readable step shown on splash and loading overlays.
  String get stepMessage {
    return switch (phase) {
      AuthStartupPhase.initializing => 'Preparing Sarthee',
      AuthStartupPhase.checkingFirebaseSession => 'Checking Session',
      AuthStartupPhase.restoringToken => 'Restoring User',
      AuthStartupPhase.validatingBackendSession => 'Validating Profile',
      AuthStartupPhase.checkingProfileCompletion => 'Validating Profile',
      AuthStartupPhase.authenticated => 'Preparing Sarthee',
      AuthStartupPhase.unauthenticated => 'Preparing Sarthee',
      AuthStartupPhase.error =>
        isOffline ? 'No internet connection' : 'Authentication failed',
    };
  }

  /// Normalized progress for splash/loading indicators (0.0 – 1.0).
  double get progress {
    return switch (phase) {
      AuthStartupPhase.initializing => 0.05,
      AuthStartupPhase.checkingFirebaseSession => 0.25,
      AuthStartupPhase.restoringToken => 0.45,
      AuthStartupPhase.validatingBackendSession => 0.65,
      AuthStartupPhase.checkingProfileCompletion => 0.85,
      AuthStartupPhase.authenticated ||
      AuthStartupPhase.unauthenticated ||
      AuthStartupPhase.error => 1.0,
    };
  }

  AuthStartupState copyWith({
    AuthStartupPhase? phase,
    AuthUser? user,
    String? error,
    bool? isProfileComplete,
    bool? isOffline,
    bool? bootstrapComplete,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthStartupState(
      phase: phase ?? this.phase,
      user: clearUser ? null : user ?? this.user,
      error: clearError ? null : error ?? this.error,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isOffline: isOffline ?? this.isOffline,
      bootstrapComplete: bootstrapComplete ?? this.bootstrapComplete,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AuthStartupState &&
            other.phase == phase &&
            other.user == user &&
            other.error == error &&
            other.isProfileComplete == isProfileComplete &&
            other.isOffline == isOffline &&
            other.bootstrapComplete == bootstrapComplete);
  }

  @override
  int get hashCode => Object.hash(
    phase,
    user,
    error,
    isProfileComplete,
    isOffline,
    bootstrapComplete,
  );

  @override
  String toString() {
    return 'AuthStartupState(phase: $phase, user: ${user?.uid ?? 'none'}, '
        'profileComplete: $isProfileComplete, offline: $isOffline, '
        'bootstrapComplete: $bootstrapComplete, error: ${error ?? 'none'})';
  }
}
