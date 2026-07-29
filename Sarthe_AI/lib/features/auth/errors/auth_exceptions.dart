class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthException: $message';
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException([super.message = 'Session expired'])
    : super(code: 'SESSION_EXPIRED');
}

class FirebaseAuthFailureException extends AuthException {
  const FirebaseAuthFailureException(super.message, {super.code});
}

class BackendAuthException extends AuthException {
  BackendAuthException(super.message, {int? statusCode})
    : super(code: statusCode?.toString());
}
