import 'state/auth_startup_state.dart';

export 'state/auth_startup_state.dart' show AuthStartupPhase, AuthStartupState;

/// Application auth state — wraps immutable [AuthStartupState].
class AuthState {
  const AuthState({this.startup = const AuthStartupState()});

  final AuthStartupState startup;

  AuthStartupPhase get phase => startup.phase;

  bool get isLoading => startup.isLoading;

  bool get isInitializing => phase == AuthStartupPhase.initializing;

  bool get isAuthenticated => startup.isAuthenticated;

  bool get isUnauthenticated => startup.isUnauthenticated;

  bool get hasError => startup.hasError;

  bool get isReady => startup.bootstrapComplete;

  bool get initialized => startup.bootstrapComplete;

  AuthState copyWith({AuthStartupState? startup}) {
    return AuthState(startup: startup ?? this.startup);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AuthState && other.startup == startup);
  }

  @override
  int get hashCode => startup.hashCode;

  @override
  String toString() => 'AuthState(startup: $startup)';
}
