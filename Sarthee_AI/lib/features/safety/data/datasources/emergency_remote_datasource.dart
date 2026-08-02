import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/network/api_response.dart';

/// EmergencyRemoteDataSource — Production Emergency REST Datasource
///
/// Connects 24x7 Emergency SOS alert dispatch to Express backend API gateway (/api/v1/emergency/sos).
class EmergencyRemoteDataSource {
  const EmergencyRemoteDataSource({this.client});

  final ApiClient? client;

  ApiClient get apiClient => client ?? ApiClient.instance;

  Future<ApiResponse<Map<String, dynamic>>> dispatchSos({
    required double lat,
    required double lng,
    String userId = 'guest_user',
    List<String> emergencyContacts = const [],
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/emergency/sos',
        data: {
          'lat': lat,
          'lng': lng,
          'userId': userId,
          'emergencyContacts': emergencyContacts,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
        (data) => data is Map<String, dynamic> ? data : <String, dynamic>{},
      );
    } catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
