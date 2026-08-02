import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/network/api_response.dart';

/// FeedbackRemoteDataSource — Production Feedback REST Datasource
///
/// Connects Beta User Feedback submission form to Express backend API gateway (/api/v1/feedback).
class FeedbackRemoteDataSource {
  const FeedbackRemoteDataSource({this.client});

  final ApiClient? client;

  ApiClient get apiClient => client ?? ApiClient.instance;

  Future<ApiResponse<Map<String, dynamic>>> submitFeedback({
    int rating = 5,
    int journeyAccuracyRating = 5,
    int nearbyAccuracyRating = 5,
    int performanceRating = 5,
    String category = 'general',
    String comments = '',
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/feedback',
        data: {
          'rating': rating,
          'journeyAccuracyRating': journeyAccuracyRating,
          'nearbyAccuracyRating': nearbyAccuracyRating,
          'performanceRating': performanceRating,
          'category': category,
          'comments': comments,
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
