import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception_mapper.dart';
import '../../../core/network/api_response.dart';
import '../models/location_model.dart';
import '../models/nearby_place.dart';

class PlacesService {
  const PlacesService({this.client});

  final ApiClient? client;

  ApiClient get apiClient => client ?? ApiClient.instance;

  Future<ApiResponse<List<NearbyPlace>>> getNearbyPlaces(
    LocationModel location, {
    String category = 'all',
    int radius = 5000,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/nearby',
        queryParameters: {
          'lat': location.latitude,
          'lng': location.longitude,
          'category': category,
          'radius': radius,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
        (data) {
          final List<NearbyPlace> results = [];
          if (data is Map<String, dynamic> && data['categories'] is Map<String, dynamic>) {
            final categoriesObj = data['categories'] as Map<String, dynamic>;
            categoriesObj.forEach((catKey, poiList) {
              if (poiList is List) {
                for (final item in poiList) {
                  if (item is Map<String, dynamic>) {
                    results.add(NearbyPlace.fromJson(item));
                  }
                }
              }
            });
          } else if (data is List) {
            for (final item in data) {
              if (item is Map<String, dynamic>) {
                results.add(NearbyPlace.fromJson(item));
              }
            }
          }
          return results;
        },
      );
    } catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  Future<ApiResponse<List<NearbyPlace>>> searchPlaces(
    String query, {
    double lat = 26.9124,
    double lng = 75.7873,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'query': query,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
        (data) {
          final List<NearbyPlace> results = [];
          if (data is List) {
            for (final item in data) {
              if (item is Map<String, dynamic>) {
                results.add(NearbyPlace.fromJson(item));
              }
            }
          }
          return results;
        },
      );
    } catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
