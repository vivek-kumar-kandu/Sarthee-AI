import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/network/api_response.dart';

/**
 * TripRemoteDataSource — Production Trip Planner REST Datasource
 *
 * Connects Multi-Day Trip Planning solver and Saved Trips list to Express backend API gateway (/api/v1/trips).
 */
class TripRemoteDataSource {
  const TripRemoteDataSource({ApiClient? client}) : _client = client;

  final ApiClient? _client;

  ApiClient get client => _client ?? ApiClient.instance;

  Future<ApiResponse<Map<String, dynamic>>> planTrip({
    required String rawPrompt,
    String city = 'Jaipur',
    double totalHours = 6.0,
    String persona = 'Family',
    double maxBudget = 1500.0,
    Map<String, dynamic> dynamicConstraints = const {},
  }) async {
    try {
      final response = await client.dio.post(
        '/trips/plan',
        data: {
          'rawPrompt': rawPrompt,
          'city': city,
          'totalHours': totalHours,
          'persona': persona,
          'maxBudget': maxBudget,
          'dynamicConstraints': dynamicConstraints,
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

  Future<ApiResponse<Map<String, dynamic>>> fetchSavedTrips() async {
    try {
      final response = await client.dio.get('/trips');
      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
        (data) => data is Map<String, dynamic> ? data : <String, dynamic>{},
      );
    } catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> fetchTripById(String tripId) async {
    try {
      final response = await client.dio.get('/trips/$tripId');
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
