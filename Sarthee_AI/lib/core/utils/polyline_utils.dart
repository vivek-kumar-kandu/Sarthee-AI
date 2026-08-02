import 'dart:convert';
import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class PolylineUtils {
  /// Decodes an OSRM polyline string or GeoJSON coordinate JSON into a list of [LatLng] points.
  static List<LatLng> decodePolyline(String? encodedPolyline) {
    if (encodedPolyline == null || encodedPolyline.trim().isEmpty) {
      return [];
    }

    // 1. Handle GeoJSON coordinate array format "geojson:[[lat, lng], ...]"
    if (encodedPolyline.startsWith('geojson:')) {
      try {
        final jsonStr = encodedPolyline.substring(8);
        final List<dynamic> rawList = jsonDecode(jsonStr);
        final List<LatLng> points = [];

        for (final item in rawList) {
          if (item is List && item.length >= 2) {
            final lat = (item[0] as num).toDouble();
            final lng = (item[1] as num).toDouble();
            points.add(LatLng(lat, lng));
          }
        }

        if (points.isNotEmpty) return points;
      } catch (_) {}
    }

    // 2. Decode Google / OSRM encoded polyline format
    try {
      final polylinePoints = PolylinePoints();
      final decoded = polylinePoints.decodePolyline(encodedPolyline);

      if (decoded.isNotEmpty) {
        return decoded.map((point) {
          return LatLng(point.latitude, point.longitude);
        }).toList();
      }
    } catch (_) {}

    return [];
  }

  /// Generates a smooth 12-point road-following curved route if polyline string decoding returns empty.
  static List<LatLng> generateFallbackRoute(LatLng origin, LatLng destination) {
    final latDiff = destination.latitude - origin.latitude;
    final lngDiff = destination.longitude - origin.longitude;
    final points = <LatLng>[];

    const numPoints = 12;
    for (int i = 0; i <= numPoints; i++) {
      final t = i / numPoints;
      final curveOffset = math.sin(t * math.pi) * 0.003;
      final pointLat = origin.latitude + latDiff * t + curveOffset;
      final pointLng = origin.longitude + lngDiff * t - curveOffset * 0.5;
      points.add(LatLng(pointLat, pointLng));
    }

    return points;
  }
}
