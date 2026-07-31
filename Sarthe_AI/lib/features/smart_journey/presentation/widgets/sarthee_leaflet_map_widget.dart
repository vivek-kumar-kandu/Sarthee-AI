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
        oldWidget.plan.destinationLat != widget.plan.destinationLat) {
      _initMapData();
    }
  }

  void _initMapData() {
    _originLatLng = LatLng(widget.plan.originLat, widget.plan.originLng);
    _destLatLng = LatLng(widget.plan.destinationLat, widget.plan.destinationLng);

    // Decode backend OSRM polyline string
    final decoded = PolylineUtils.decodePolyline(widget.plan.polyline);
    if (decoded.isNotEmpty) {
      _routePoints = decoded;
    } else {
      _routePoints = PolylineUtils.generateFallbackRoute(_originLatLng, _destLatLng);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapBounds();
    });
  }

  void _fitMapBounds() {
    if (_routePoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints([
      _originLatLng,
      _destLatLng,
      ..._routePoints,
    ]);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(48),
      ),
    );
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

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
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
                initialCenter: _originLatLng,
                initialZoom: 12.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sarthee.ai.sarthe_ai',
                  tileBuilder: isDark
                      ? (context, tileWidget, tile) {
                          return ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              -0.2, 0.0, 0.0, 0.0, 255,
                              0.0, -0.2, 0.0, 0.0, 255,
                              0.0, 0.0, -0.2, 0.0, 255,
                              0.0, 0.0, 0.0, 1.0, 0,
                            ]),
                            child: tileWidget,
                          );
                        }
                      : null,
                ),
                // Route Polyline Layer
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5.5,
                      color: const Color(0xFF4F46E5),
                      borderColor: const Color(0xFF818CF8),
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),
                // Markers Layer (Origin & Destination)
                MarkerLayer(
                  markers: [
                    // Origin Marker
                    Marker(
                      point: _originLatLng,
                      width: 50,
                      height: 50,
                      child: Tooltip(
                        message: widget.plan.originName,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 6),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    // Destination Marker
                    Marker(
                      point: _destLatLng,
                      width: 50,
                      height: 50,
                      child: Tooltip(
                        message: widget.plan.destinationName,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 6),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Top Header Overlay Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black87 : Colors.white).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark ? Colors.white24 : Colors.black12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_rounded, size: 16, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 6),
                    Text(
                      "Leaflet 3D Vector Map",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
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
                    heroTag: 'map_recenter',
                    backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                    foregroundColor: const Color(0xFF4F46E5),
                    onPressed: _fitMapBounds,
                    child: const Icon(Icons.center_focus_strong_rounded),
                  ),
                  const SizedBox(height: 6),
                  FloatingActionButton.small(
                    heroTag: 'map_zoom_in',
                    backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    onPressed: _zoomIn,
                    child: const Icon(Icons.add_rounded),
                  ),
                  const SizedBox(height: 6),
                  FloatingActionButton.small(
                    heroTag: 'map_zoom_out',
                    backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    onPressed: _zoomOut,
                    child: const Icon(Icons.remove_rounded),
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
