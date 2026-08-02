import 'package:dio/dio.dart';

/// ApiExceptionMapper — Central Dio & Network Exception Mapper
///
/// Converts Dio HTTP errors (Timeout, No Internet, 401 Unauthorized, 404, 500)
/// into typed AppException objects for consistent UI error rendering.
abstract class AppException implements Exception {
  const AppException(this.message, {this.code = 'APP_ERROR', this.statusCode});

  final String message;
  final String code;
  final int? statusCode;

  @override
  String toString() => '$code: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection. Please check your network.'])
      : super(code: 'NO_INTERNET');
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out. Please try again.'])
      : super(code: 'TIMEOUT');
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.code = 'SERVER_ERROR'});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired. Please sign in again.'])
      : super(code: 'UNAUTHORIZED', statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Requested resource not found.'])
      : super(code: 'NOT_FOUND', statusCode: 404);
}

class ApiExceptionMapper {
  static AppException map(dynamic error) {
    if (error is AppException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const TimeoutException();

        case DioExceptionType.connectionError:
          return const NetworkException();

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          String msg = 'An unexpected server error occurred.';
          String code = 'SERVER_ERROR';

          if (responseData is Map<String, dynamic>) {
            if (responseData['error'] is Map<String, dynamic>) {
              msg = responseData['error']['message'] as String? ?? msg;
              code = responseData['error']['code'] as String? ?? code;
            } else if (responseData['message'] is String) {
              msg = responseData['message'] as String;
            }
          }

          if (statusCode == 401) {
            return UnauthorizedException(msg);
          } else if (statusCode == 404) {
            return NotFoundException(msg);
          }
          return ServerException(msg, statusCode: statusCode, code: code);

        case DioExceptionType.cancel:
          return const ServerException('Request was cancelled.', code: 'CANCELLED');

        default:
          return NetworkException(error.message ?? 'Network communication failure.');
      }
    }

    return ServerException(error?.toString() ?? 'An unexpected error occurred.');
  }
}
