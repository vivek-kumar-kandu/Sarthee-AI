import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/polyline_utils.dart';
import '../../domain/entities/journey_plan.dart';

class SartheeLeafletMapWidget extends StatefulWidget {
  final JourneyPlan plan;
  final double height;

  const SartheeLeafletMapWidget({
    super.key,
    required this.plan,
    this.height = 320,
  });

  @override
  State<SartheeLeafletMapWidget> createState() => _SartheeLeafletMapWidgetState();
}

class _SartheeLeafletMapWidgetState extends State<SartheeLeafletMapWidget> {
  final MapController _mapController = MapController();

  late LatLng _originLatLng;
  late LatLng _destLatLng;
  late LatLng _initialCenter;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _initMapData();
  }

  @override
  void didUpdateWidget(covariant SartheeLeafletMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan.id != widget.plan.id ||
        oldWidget.plan.originLat != widget.plan.originLat ||
        oldWidget.plan.destinationLat != widget.plan.destinationLat ||
        oldWidget.plan.polyline != widget.plan.polyline) {
      _initMapData();
    }
  }

  void _initMapData() {
    final origin = LatLng(
      widget.plan.originLat != 0.0 ? widget.plan.originLat : 28.6715,
      widget.plan.originLng != 0.0 ? widget.plan.originLng : 77.4121,
    );
    final dest = LatLng(
      widget.plan.destinationLat != 0.0 ? widget.plan.destinationLat : 28.6328,
      widget.plan.destinationLng != 0.0 ? widget.plan.destinationLng : 77.2197,
    );

    // Calculate initial midpoint center over India region to prevent showing Africa/Atlantic Ocean
    final centerLat = (origin.latitude + dest.latitude) / 2;
    final centerLng = (origin.longitude + dest.longitude) / 2;
    final center = LatLng(centerLat, centerLng);

    // Decode backend OSRM polyline string or GeoJSON coordinates
    final decoded = PolylineUtils.decodePolyline(widget.plan.polyline);
    final points = decoded.isNotEmpty
        ? decoded
        : PolylineUtils.generateFallbackRoute(origin, dest);

    if (mounted) {
      setState(() {
        _originLatLng = origin;
        _destLatLng = dest;
        _initialCenter = center;
        _routePoints = points;
      });
    } else {
      _originLatLng = origin;
      _destLatLng = dest;
      _initialCenter = center;
      _routePoints = points;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fitMapBounds();
      }
    });
  }

  void _fitMapBounds() {
    if (_routePoints.isEmpty) return;

    try {
      final bounds = LatLngBounds.fromPoints([
        _originLatLng,
        _destLatLng,
        ..._routePoints,
      ]);

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(40),
        ),
      );
    } catch (_) {}
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // High-performance CARTO global CDN tile servers (Blazing fast 0ms cached loading)
    final tileUrlTemplate = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialCenter,
                initialZoom: 12.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // Ultra-Fast CARTO Multi-Subdomain CDN Tile Layer
                TileLayer(
                  urlTemplate: tileUrlTemplate,
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.sarthee.ai.sarthe_ai',
                  maxZoom: 19,
                ),

                // Multi-Modal Route Polyline Layer
                PolylineLayer(
                  polylines: [
                    // Outer glow / shadow stroke
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 7.0,
                      color: isDark ? const Color(0xFF6366F1).withValues(alpha: 0.4) : const Color(0xFF4138D9).withValues(alpha: 0.3),
                    ),
                    // Inner main polyline stroke
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.5,
                      color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
                    ),
                  ],
                ),

                // Origin & Destination Markers Layer
                MarkerLayer(
                  markers: [
                    // Origin Marker
                    Marker(
                      point: _originLatLng,
                      width: 48,
                      height: 48,
                      child: Tooltip(
                        message: widget.plan.originName,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    // Destination Marker
                    Marker(
                      point: _destLatLng,
                      width: 48,
                      height: 48,
                      child: Tooltip(
                        message: widget.plan.destinationName,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Glassmorphism Header Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark ? Colors.white24 : Colors.black12),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_rounded, size: 16, color: Color(0xFF6366F1)),
                    const SizedBox(width: 6),
                    Text(
                      "Live High-Speed Map",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Map Control Overlay Buttons (Zoom & Recenter)
            Positioned(
              bottom: 12,
              right: 12,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'map_recenter_btn',
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    foregroundColor: const Color(0xFF6366F1),
                    elevation: 4,
                    onPressed: _fitMapBounds,
                    child: const Icon(Icons.center_focus_strong_rounded, size: 20),
                  ),
                  const SizedBox(height: 6),
                  FloatingActionButton.small(
                    heroTag: 'map_zoom_in_btn',
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                    elevation: 4,
                    onPressed: _zoomIn,
                    child: const Icon(Icons.add_rounded, size: 20),
                  ),
                  const SizedBox(height: 6),
                  FloatingActionButton.small(
                    heroTag: 'map_zoom_out_btn',
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                    elevation: 4,
                    onPressed: _zoomOut,
                    child: const Icon(Icons.remove_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
