import 'package:dio/dio.dart';

class NominatimSearchResult {
  final String displayName;
  final double latitude;
  final double longitude;

  NominatimSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  factory NominatimSearchResult.fromJson(Map<String, dynamic> json) {
    return NominatimSearchResult(
      displayName: json['display_name'] as String? ?? 'Unknown Location',
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class NominatimSearchDatasource {
  final Dio _dio;

  NominatimSearchDatasource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              headers: {
                'User-Agent': 'SartheeAI/1.0 (contact@sarthee.ai)',
              },
            ));

  /// Search locations across India via OpenStreetMap Nominatim
  Future<List<NominatimSearchResult>> searchLocation(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'countrycodes': 'in',
          'limit': 5,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => NominatimSearchResult.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
