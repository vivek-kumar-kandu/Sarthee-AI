import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/journey_plan.dart';

class RemoteJourneyDatasource {
  final Dio _dio;

  RemoteJourneyDatasource({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  /// Connects to the backend REST API: POST /journey/plan
  Future<List<JourneyPlan>> planJourney({
    required String originName,
    required double originLat,
    required double originLng,
    required String destinationName,
    required double destinationLat,
    required double destinationLng,
    String preferredMode = 'balanced',
  }) async {
    final response = await _dio.post(
      '/journey/plan',
      data: {
        'originName': originName,
        'originLat': originLat,
        'originLng': originLng,
        'destinationName': destinationName,
        'destinationLat': destinationLat,
        'destinationLng': destinationLng,
        'preferredMode': preferredMode,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final responseBody = response.data as Map<String, dynamic>;
      final dataObj = responseBody['data'] as Map<String, dynamic>?;

      if (dataObj != null && dataObj['plans'] != null) {
        final plansObj = dataObj['plans'] as Map<String, dynamic>;
        final List<JourneyPlan> parsedPlans = [];

        plansObj.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            parsedPlans.add(JourneyPlan.fromJson(value));
          }
        });

        if (parsedPlans.isNotEmpty) {
          return parsedPlans;
        }
      }
    }

    throw Exception('Failed to receive valid journey plans from backend REST API.');
  }
}
