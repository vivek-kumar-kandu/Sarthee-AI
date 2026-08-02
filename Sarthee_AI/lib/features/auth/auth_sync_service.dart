import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';

class AuthSyncService {
  AuthSyncService._();

  static final AuthSyncService instance = AuthSyncService._();

  Future<void> syncUser({bool forceRefresh = false, int attempt = 0}) async {
    try {
      final token = await _getValidToken(forceRefresh: forceRefresh);

      if (token == null || token.isEmpty) {
        throw AuthSyncException('Firebase token is unavailable.');
      }

      await ApiClient.instance.dio.post(
        '/auth/sync',
        options: Options(
          headers: <String, Object>{'Authorization': 'Bearer $token'},
        ),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 && !forceRefresh && attempt < 1) {
        await syncUser(forceRefresh: true, attempt: attempt + 1);
        return;
      }

      throw AuthSyncException.fromDioException(error);
    } on AuthSyncException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AuthSyncException('Backend sync failed. Please try again.'),
        stackTrace,
      );
    }
  }

  Future<String?> _getValidToken({required bool forceRefresh}) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw AuthSyncException('No authenticated Firebase user is available.');
    }

    final String? token = await user.getIdToken(forceRefresh);

    if (token == null || token.isEmpty) {
      throw AuthSyncException('Firebase ID token could not be retrieved.');
    }

    await SecureStorage.instance.saveToken(token);
    return token;
  }
}

class AuthSyncException implements Exception {
  AuthSyncException(this.message, {this.statusCode, this.retryable = false});

  factory AuthSyncException.fromDioException(DioException error) {
    final int? statusCode = error.response?.statusCode;
    final bool retryable =
        statusCode == 401 || statusCode == 408 || statusCode == 429;

    if (statusCode == 401) {
      return AuthSyncException(
        'Authentication expired. Please sign in again.',
        statusCode: statusCode,
        retryable: true,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return AuthSyncException(
        'The backend is temporarily unavailable. Please try again shortly.',
        statusCode: statusCode,
        retryable: true,
      );
    }

    if (statusCode != null && statusCode >= 400) {
      return AuthSyncException(
        'Backend sync failed with status $statusCode.',
        statusCode: statusCode,
        retryable: false,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return AuthSyncException(
        'The request timed out while syncing your account.',
        retryable: true,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return AuthSyncException(
        'Unable to reach the server. Please check your connection.',
        retryable: true,
      );
    }

    return AuthSyncException(
      'Backend sync failed. Please try again.',
      retryable: retryable,
    );
  }

  final String message;
  final int? statusCode;
  final bool retryable;

  @override
  String toString() => message;
}
