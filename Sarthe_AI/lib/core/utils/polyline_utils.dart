import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class PolylineUtils {
  /// Decodes an OSRM encoded polyline string (e.g. "_|~mDspnwM...") into a list of [LatLng] points.
  static List<LatLng> decodePolyline(String? encodedPolyline) {
    if (encodedPolyline == null || encodedPolyline.trim().isEmpty) {
      return [];
    }

    try {
      final polylinePoints = PolylinePoints();
      final decoded = polylinePoints.decodePolyline(encodedPolyline);

      return decoded.map((point) {
        return LatLng(point.latitude, point.longitude);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Generates a straight linear fallback route if polyline string decoding returns empty.
  static List<LatLng> generateFallbackRoute(LatLng origin, LatLng destination) {
    return [origin, destination];
  }
}
