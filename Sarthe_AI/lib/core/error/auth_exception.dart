import 'package:firebase_auth/firebase_auth.dart';

import 'app_exception.dart';

enum AuthErrorType {
  invalidCredential,
  networkFailure,
  userCancelled,
  expiredSession,
  unknown,
}

class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    this.type = AuthErrorType.unknown,
    super.retryable = false,
  });

  final AuthErrorType type;

  factory AuthException.invalidCredential([
    String message = 'Invalid credentials.',
  ]) {
    return AuthException(
      message,
      type: AuthErrorType.invalidCredential,
      retryable: false,
    );
  }

  factory AuthException.networkFailure([
    String message = 'Network error. Please check your connection.',
  ]) {
    return AuthException(
      message,
      type: AuthErrorType.networkFailure,
      retryable: true,
    );
  }

  factory AuthException.userCancelled([
    String message = 'Authentication was cancelled.',
  ]) {
    return AuthException(
      message,
      type: AuthErrorType.userCancelled,
      retryable: false,
    );
  }

  factory AuthException.expiredSession([
    String message = 'Your session has expired. Please sign in again.',
  ]) {
    return AuthException(
      message,
      type: AuthErrorType.expiredSession,
      retryable: false,
    );
  }

  factory AuthException.unknown([
    String message = 'Authentication failed. Please try again.',
  ]) {
    return AuthException(message, type: AuthErrorType.unknown, retryable: true);
  }

  factory AuthException.fromFirebaseAuthException(FirebaseAuthException error) {
    final message = error.message ?? 'Authentication failed. Please try again.';

    switch (error.code) {
      case 'invalid-email':
      case 'wrong-password':
      case 'user-not-found':
      case 'user-disabled':
      case 'email-already-in-use':
      case 'operation-not-allowed':
      case 'account-exists-with-different-credential':
      case 'invalid-verification-code':
      case 'invalid-verification-id':
        return AuthException.invalidCredential(message);
      case 'network-request-failed':
        return AuthException.networkFailure(message);
      case 'too-many-requests':
      case 'quota-exceeded':
        return AuthException.networkFailure(message);
      case 'requires-recent-login':
      case 'expired-action-code':
      case 'user-token-expired':
      case 'invalid-user-token':
        return AuthException.expiredSession(message);
      default:
        return AuthException.unknown(message);
    }
  }

  @override
  String toString() => message;
}
