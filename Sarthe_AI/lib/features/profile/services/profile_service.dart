import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../data/models/profile_response_model.dart';
import '../data/models/profile_update_request.dart';

/// ============================================================================
/// PROFILE SERVICE
/// ============================================================================
///
/// Responsibilities:
///
/// ✓ Communicate with Backend
/// ✓ Parse API Response
/// ✓ Throw Domain Exceptions
///
/// NOT Responsible For:
///
/// ✗ Business Logic
/// ✗ UI
/// ✗ State Management
/// ✗ Mapping to Entity
///
/// ============================================================================

abstract interface class IProfileService {
  Future<ProfileResponseModel> getProfile();

  Future<ProfileResponseModel> updateProfile(ProfileUpdateRequest request);
}

class ProfileService implements IProfileService {
  ProfileService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  static const String _endpoint = '/auth/profile';

  @override
  Future<ProfileResponseModel> getProfile() async {
    try {
      final response = await _dio.get(_endpoint);

      final data = _validateResponse(response);

      return ProfileResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw ProfileException.fromDioException(e);
    }
  }

@override
Future<ProfileResponseModel> updateProfile(
  ProfileUpdateRequest request,
) async {
  try {
    final body = request.toJson();

    print("========== PROFILE UPDATE REQUEST ==========");
    print(body);
    print("===========================================");

    final response = await _dio.put(
      _endpoint,
      data: body,
    );

    final data = _validateResponse(response);

    return ProfileResponseModel.fromJson(data);
  } on DioException catch (e) {
    throw ProfileException.fromDioException(e);
  }
}

  Map<String, dynamic> _validateResponse(Response response) {
    if (response.data == null) {
      throw const ProfileException('Server returned an empty response.');
    }

    if (response.data is! Map<String, dynamic>) {
      throw const ProfileException('Invalid server response format.');
    }

    return Map<String, dynamic>.from(response.data);
  }
}

class ProfileException implements Exception {
  const ProfileException(
    this.message, {
    this.statusCode,
    this.retryable = false,
  });

  factory ProfileException.fromDioException(DioException error) {
    final status = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ProfileException('Connection timed out.', retryable: true);

      case DioExceptionType.connectionError:
        return const ProfileException(
          'Unable to connect to the server.',
          retryable: true,
        );

      case DioExceptionType.cancel:
        return const ProfileException('Request was cancelled.');

      default:
        break;
    }

    switch (status) {
      case 400:
        return const ProfileException('Invalid profile request.');

      case 401:
        return const ProfileException(
          'Your session has expired. Please sign in again.',
          statusCode: 401,
        );

      case 403:
        return const ProfileException(
          'You are not authorized to perform this action.',
          statusCode: 403,
        );

      case 404:
        return const ProfileException('Profile not found.', statusCode: 404);

      case 409:
        return const ProfileException(
          'Profile update conflict.',
          statusCode: 409,
        );

      case 422:
        return const ProfileException(
          'Profile validation failed.',
          statusCode: 422,
        );

      default:
        if (status != null && status >= 500) {
          return ProfileException(
            'Server error. Please try again later.',
            statusCode: status,
            retryable: true,
          );
        }
    }

    return ProfileException(
      error.message ?? 'Unexpected profile error.',
      statusCode: status,
      retryable: true,
    );
  }

  final String message;

  final int? statusCode;

  final bool retryable;

  @override
  String toString() => message;
}
