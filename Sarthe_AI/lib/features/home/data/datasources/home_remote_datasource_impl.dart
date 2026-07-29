import 'dart:async';

import 'package:dio/dio.dart';

import '../models/home_content_model.dart';
import 'home_remote_datasource.dart';

/// ============================================================================
/// SARTHEE AI — HOME REMOTE DATA SOURCE IMPLEMENTATION
/// ============================================================================
///
/// Production-oriented Dio implementation of [HomeRemoteDataSource].
///
/// Architecture:
///
/// HomeRepositoryImpl
///        ↓
/// HomeRemoteDataSource
///        ↓
/// HomeRemoteDataSourceImpl
///        ↓
/// Dio
///        ↓
/// Sarthee AI Backend
///
/// Responsibilities:
///
/// • Build Home API requests
/// • Execute requests through injected Dio
/// • Validate HTTP responses
/// • Validate response payloads
/// • Convert JSON into HomeContentModel
/// • Normalize Dio/network failures
/// • Preserve transport concerns inside the data layer
///
/// Dio is injected instead of being created here so that application-level
/// networking configuration can remain centralized.
final class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({
    required this.dio,
    this.endpoint = '/home',
    this.requestTimeout = const Duration(seconds: 15),
  }) {
    if (endpoint.trim().isEmpty) {
      throw ArgumentError.value(
        endpoint,
        'endpoint',
        'Home endpoint cannot be empty.',
      );
    }

    if (requestTimeout <= Duration.zero) {
      throw ArgumentError.value(
        requestTimeout,
        'requestTimeout',
        'Request timeout must be greater than zero.',
      );
    }
  }

  // ===========================================================================
  // DEPENDENCIES
  // ===========================================================================

  final Dio dio;

  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================

  /// Relative Home endpoint.
  ///
  /// Examples:
  ///
  /// /home
  /// /api/home
  /// /v1/home
  final String endpoint;

  /// Maximum time allowed for the complete Home request.
  final Duration requestTimeout;

  // ===========================================================================
  // GET HOME CONTENT
  // ===========================================================================

  @override
  Future<HomeContentModel> getHomeContent({
    HomeRemoteRequest request = const HomeRemoteRequest(),
  }) async {
    try {
      final Response<dynamic> response = await dio
          .get<dynamic>(
            endpoint,
            queryParameters: request.toQueryParameters(),
            options: Options(
              responseType: ResponseType.json,
              headers: const <String, dynamic>{'Accept': 'application/json'},
            ),
          )
          .timeout(requestTimeout);

      return _parseResponse(response);
    } on TimeoutException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        HomeRemoteTimeoutException(timeout: requestTimeout, cause: error),
        stackTrace,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapDioException(error), stackTrace);
    } on HomeRemoteException {
      rethrow;
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        HomeRemoteParsingException(
          message: 'Home response contains invalid data.',
          cause: error,
        ),
        stackTrace,
      );
    } on TypeError catch (error, stackTrace) {
      Error.throwWithStackTrace(
        HomeRemoteParsingException(
          message: 'Home response has an unexpected structure.',
          cause: error,
        ),
        stackTrace,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        HomeRemoteUnknownException(
          message: 'Unexpected failure while loading Home content.',
          cause: error,
        ),
        stackTrace,
      );
    }
  }

  // ===========================================================================
  // RESPONSE PARSING
  // ===========================================================================

  HomeContentModel _parseResponse(Response<dynamic> response) {
    final int? statusCode = response.statusCode;

    if (statusCode == null) {
      throw const HomeRemoteProtocolException(
        message: 'Home API returned no HTTP status code.',
      );
    }

    if (statusCode < 200 || statusCode >= 300) {
      throw HomeRemoteHttpException(
        statusCode: statusCode,
        message: _resolveHttpMessage(statusCode, response.data),
      );
    }

    final Object? payload = response.data;

    if (payload == null) {
      throw const HomeRemoteParsingException(
        message: 'Home API returned an empty response.',
      );
    }

    final Map<String, dynamic> root = _asStringMap(
      payload,
      context: 'Home response',
    );

    final Map<String, dynamic> homeJson = _extractHomePayload(root);

    try {
      return HomeContentModel.fromJson(homeJson);
    } on FormatException {
      rethrow;
    } on TypeError {
      rethrow;
    } catch (error) {
      throw HomeRemoteParsingException(
        message: 'Unable to deserialize Home content.',
        cause: error,
      );
    }
  }

  // ===========================================================================
  // PAYLOAD EXTRACTION
  // ===========================================================================

  /// Supports a direct payload:
  ///
  /// {
  ///   "sections": [...]
  /// }
  ///
  /// as well as a common API envelope:
  ///
  /// {
  ///   "data": {
  ///     "sections": [...]
  ///   }
  /// }
  Map<String, dynamic> _extractHomePayload(Map<String, dynamic> root) {
    final Object? data = root['data'];

    if (data is Map) {
      return _asStringMap(data, context: 'Home response data');
    }

    return root;
  }

  Map<String, dynamic> _asStringMap(Object value, {required String context}) {
    if (value is! Map) {
      throw HomeRemoteParsingException(
        message: '$context must be a JSON object.',
      );
    }

    return value.map<String, dynamic>((Object? key, Object? value) {
      return MapEntry<String, dynamic>(key.toString(), value);
    });
  }

  // ===========================================================================
  // DIO ERROR MAPPING
  // ===========================================================================

  HomeRemoteException _mapDioException(DioException error) {
    switch (error.type) {
      // -----------------------------------------------------------------------
      // TIMEOUTS
      // -----------------------------------------------------------------------

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return HomeRemoteTimeoutException(
          timeout: requestTimeout,
          cause: error,
        );

      // -----------------------------------------------------------------------
      // CONNECTION
      // -----------------------------------------------------------------------

      case DioExceptionType.connectionError:
        return HomeRemoteConnectionException(
          message: 'Unable to connect to the Sarthee AI service.',
          cause: error,
        );

      // -----------------------------------------------------------------------
      // CERTIFICATE
      // -----------------------------------------------------------------------

      case DioExceptionType.badCertificate:
        return HomeRemoteSecurityException(
          message: 'Unable to establish a trusted connection to the service.',
          cause: error,
        );

      // -----------------------------------------------------------------------
      // CANCELLED
      // -----------------------------------------------------------------------

      case DioExceptionType.cancel:
        return HomeRemoteCancelledException(cause: error);

      // -----------------------------------------------------------------------
      // HTTP RESPONSE
      // -----------------------------------------------------------------------

      case DioExceptionType.badResponse:
        final Response<dynamic>? response = error.response;

        final int statusCode = response?.statusCode ?? 0;

        return HomeRemoteHttpException(
          statusCode: statusCode,
          message: _resolveHttpMessage(statusCode, response?.data),
          cause: error,
        );

      // -----------------------------------------------------------------------
      // UNKNOWN
      // -----------------------------------------------------------------------

      case DioExceptionType.unknown:
        return HomeRemoteConnectionException(
          message: 'A network error occurred while loading Home content.',
          cause: error,
        );
    }
  }

  // ===========================================================================
  // HTTP ERROR MESSAGE
  // ===========================================================================

  String _resolveHttpMessage(int statusCode, Object? payload) {
    final String? serverMessage = _extractServerMessage(payload);

    if (serverMessage != null) {
      return serverMessage;
    }

    switch (statusCode) {
      case 400:
        return 'The Home request was invalid.';

      case 401:
        return 'Authentication is required.';

      case 403:
        return 'Access to Home content was denied.';

      case 404:
        return 'Home content could not be found.';

      case 408:
        return 'The Home request timed out.';

      case 409:
        return 'The Home request conflicted with the current server state.';

      case 422:
        return 'The Home request could not be processed.';

      case 429:
        return 'Too many Home requests were sent. Please try again later.';

      case 500:
        return 'The Sarthee AI service encountered an internal error.';

      case 502:
        return 'The Sarthee AI service received an invalid upstream response.';

      case 503:
        return 'The Sarthee AI service is temporarily unavailable.';

      case 504:
        return 'The Sarthee AI service timed out while processing the request.';

      default:
        if (statusCode >= 500) {
          return 'The Sarthee AI service is currently unavailable.';
        }

        if (statusCode >= 400) {
          return 'The Home request could not be completed.';
        }

        return 'Home request failed with HTTP status $statusCode.';
    }
  }

  // ===========================================================================
  // SERVER ERROR EXTRACTION
  // ===========================================================================

  String? _extractServerMessage(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    const List<String> messageKeys = <String>[
      'message',
      'error',
      'detail',
      'errorMessage',
    ];

    for (final String key in messageKeys) {
      final Object? value = payload[key];

      if (value is String) {
        final String message = value.trim();

        if (message.isNotEmpty) {
          return message;
        }
      }
    }

    return null;
  }
}

/// ============================================================================
/// HOME REMOTE EXCEPTION
/// ============================================================================

sealed class HomeRemoteException implements Exception {
  const HomeRemoteException({required this.message, this.cause});

  final String message;

  final Object? cause;

  @override
  String toString() {
    return '$runtimeType(message: $message)';
  }
}

/// ============================================================================
/// HTTP FAILURE
/// ============================================================================

final class HomeRemoteHttpException extends HomeRemoteException {
  const HomeRemoteHttpException({
    required this.statusCode,
    required super.message,
    super.cause,
  });

  final int statusCode;

  bool get isClientError => statusCode >= 400 && statusCode < 500;

  bool get isServerError => statusCode >= 500 && statusCode < 600;

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  bool get isNotFound => statusCode == 404;

  bool get isRateLimited => statusCode == 429;
}

/// ============================================================================
/// CONNECTION FAILURE
/// ============================================================================

final class HomeRemoteConnectionException extends HomeRemoteException {
  const HomeRemoteConnectionException({required super.message, super.cause});
}

/// ============================================================================
/// TIMEOUT FAILURE
/// ============================================================================

final class HomeRemoteTimeoutException extends HomeRemoteException {
  HomeRemoteTimeoutException({required this.timeout, super.cause})
    : super(
        message:
            'Home request exceeded the allowed timeout of '
            '${timeout.inSeconds} seconds.',
      );

  final Duration timeout;
}

/// ============================================================================
/// SECURITY FAILURE
/// ============================================================================

final class HomeRemoteSecurityException extends HomeRemoteException {
  const HomeRemoteSecurityException({required super.message, super.cause});
}

/// ============================================================================
/// CANCELLATION
/// ============================================================================

final class HomeRemoteCancelledException extends HomeRemoteException {
  const HomeRemoteCancelledException({super.cause})
    : super(message: 'Home request was cancelled.');
}

/// ============================================================================
/// PROTOCOL FAILURE
/// ============================================================================

final class HomeRemoteProtocolException extends HomeRemoteException {
  const HomeRemoteProtocolException({required super.message, super.cause});
}

/// ============================================================================
/// PARSING FAILURE
/// ============================================================================

final class HomeRemoteParsingException extends HomeRemoteException {
  const HomeRemoteParsingException({required super.message, super.cause});
}

/// ============================================================================
/// UNKNOWN FAILURE
/// ============================================================================

final class HomeRemoteUnknownException extends HomeRemoteException {
  const HomeRemoteUnknownException({required super.message, super.cause});
}
