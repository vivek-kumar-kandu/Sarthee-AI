abstract class AppException implements Exception {
  const AppException(this.message, {this.code, this.retryable = false});

  final String message;
  final String? code;
  final bool retryable;

  @override
  String toString() => message;
}
