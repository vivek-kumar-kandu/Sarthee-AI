import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/nominatim_search_datasource.dart';
import '../providers/smart_journey_provider.dart';
import '../widgets/journey_option_card.dart';
import '../widgets/sarthee_ai_advisor_card.dart';
import '../widgets/sarthee_leaflet_map_widget.dart';
import '../../domain/entities/journey_plan.dart';

class SmartJourneyPlannerPage extends ConsumerStatefulWidget {
  const SmartJourneyPlannerPage({super.key});

  @override
  ConsumerState<SmartJourneyPlannerPage> createState() => _SmartJourneyPlannerPageState();
}

class _SmartJourneyPlannerPageState extends ConsumerState<SmartJourneyPlannerPage> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  final NominatimSearchDatasource _nominatimDatasource = NominatimSearchDatasource();

  Timer? _debounceTimer;

  // Selected Coordinates State
  double? _selectedOriginLat;
  double? _selectedOriginLng;
  double? _selectedDestLat;
  double? _selectedDestLng;

  // Autocomplete Overlay State
  List<NominatimSearchResult> _originSuggestions = [];
  List<NominatimSearchResult> _destSuggestions = [];
  bool _isSearchingOrigin = false;
  bool _isSearchingDest = false;
  bool _showOriginSuggestions = false;
  bool _showDestSuggestions = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(smartJourneyProvider);
    _originController.text = state.origin;
    _destController.text = state.destination;

    _selectedOriginLat = state.originLat;
    _selectedOriginLng = state.originLng;
    _selectedDestLat = state.destinationLat;
    _selectedDestLng = state.destinationLng;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _originController.dispose();
    _destController.dispose();
    super.dispose();
  }

  void _onOriginQueryChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      if (query.trim().length < 3) {
        if (mounted) {
          setState(() {
            _originSuggestions = [];
            _showOriginSuggestions = false;
            _isSearchingOrigin = false;
          });
        }
        return;
      }

      if (mounted) setState(() => _isSearchingOrigin = true);
      final results = await _nominatimDatasource.searchLocation(query);

      if (mounted) {
        setState(() {
          _originSuggestions = results;
          _showOriginSuggestions = results.isNotEmpty;
          _isSearchingOrigin = false;
        });
      }
    });
  }

  void _onDestQueryChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      if (query.trim().length < 3) {
        if (mounted) {
          setState(() {
            _destSuggestions = [];
            _showDestSuggestions = false;
            _isSearchingDest = false;
          });
        }
        return;
      }

      if (mounted) setState(() => _isSearchingDest = true);
      final results = await _nominatimDatasource.searchLocation(query);

      if (mounted) {
        setState(() {
          _destSuggestions = results;
          _showDestSuggestions = results.isNotEmpty;
          _isSearchingDest = false;
        });
      }
    });
  }

  void _selectOriginItem(NominatimSearchResult item) {
    setState(() {
      _originController.text = item.displayName;
      _selectedOriginLat = item.latitude;
      _selectedOriginLng = item.longitude;
      _showOriginSuggestions = false;
      _originSuggestions = [];
    });
  }

  void _selectDestItem(NominatimSearchResult item) {
    setState(() {
      _destController.text = item.displayName;
      _selectedDestLat = item.latitude;
      _selectedDestLng = item.longitude;
      _showDestSuggestions = false;
      _destSuggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartJourneyProvider);
    final notifier = ref.read(smartJourneyProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.explore_rounded, color: Color(0xFF0D9488)),
            SizedBox(width: 8),
            Text("Smart Journey Assistant"),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Origin TextField
                  TextField(
                    controller: _originController,
                    onChanged: _onOriginQueryChanged,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.my_location_rounded, color: Color(0xFF0D9488)),
                      suffixIcon: _isSearchingOrigin
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      labelText: "Origin / Current Location",
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  // Origin Autocomplete Suggestions List
                  if (_showOriginSuggestions && _originSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4, bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: _originSuggestions.map((item) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.place_rounded, size: 18, color: Color(0xFF0D9488)),
                            title: Text(
                              item.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(
                              "GPS: ${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}",
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            onTap: () => _selectOriginItem(item),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 4),

                  // Swap Locations Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        final tempText = _originController.text;
                        _originController.text = _destController.text;
                        _destController.text = tempText;

                        final tempLat = _selectedOriginLat;
                        final tempLng = _selectedOriginLng;
                        _selectedOriginLat = _selectedDestLat;
                        _selectedOriginLng = _selectedDestLng;
                        _selectedDestLat = tempLat;
                        _selectedDestLng = tempLng;

                        setState(() {});
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.swap_vert_rounded, size: 18, color: Color(0xFF4F46E5)),
                      ),
                      tooltip: "Swap Origin & Destination",
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Destination TextField
                  TextField(
                    controller: _destController,
                    onChanged: _onDestQueryChanged,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFDC2626)),
                      suffixIcon: _isSearchingDest
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      labelText: "Destination Location",
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  // Destination Autocomplete Suggestions List
                  if (_showDestSuggestions && _destSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4, bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: _destSuggestions.map((item) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.place_rounded, size: 18, color: Color(0xFFDC2626)),
                            title: Text(
                              item.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(
                              "GPS: ${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}",
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            onTap: () => _selectDestItem(item),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: state.isLoading
                          ? null
                          : () {
                              notifier.searchJourney(
                                origin: _originController.text,
                                originLat: _selectedOriginLat,
                                originLng: _selectedOriginLng,
                                destination: _destController.text,
                                destinationLat: _selectedDestLat,
                                destinationLng: _selectedDestLng,
                              );
                            },
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.alt_route_rounded),
                      label: Text(
                        state.isLoading ? "Orchestrating Route..." : "Orchestrate Smart Journey",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (state.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Color(0xFF991B1B)),
                ),
              ),

            // Interactive Leaflet 3D Vector Route Map
            if (state.selectedPlan != null) ...[
              SartheeLeafletMapWidget(
                plan: state.selectedPlan!,
              ),
              const SizedBox(height: 16),
            ],

            // AI Recommendation Banner
            if (state.selectedPlan?.aiRationale != null)
              SartheeAiAdvisorCard(
                rationale: state.selectedPlan!.aiRationale,
              ),

            const SizedBox(height: 16),

            // Mode Selector Chips
            const Text(
              "Route Optimization Profiles",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChoiceChip(context, notifier, RecommendationMode.all, "✨ All Routes", state.selectedMode),
                  _buildChoiceChip(context, notifier, RecommendationMode.recommended, "🌟 Recommended", state.selectedMode),
                  _buildChoiceChip(context, notifier, RecommendationMode.fastest, "⚡ Fastest", state.selectedMode),
                  _buildChoiceChip(context, notifier, RecommendationMode.cheapest, "💰 Cheapest", state.selectedMode),
                  _buildChoiceChip(context, notifier, RecommendationMode.balanced, "🟢 Balanced", state.selectedMode),
                  _buildChoiceChip(context, notifier, RecommendationMode.safest, "🛡️ Safest", state.selectedMode),
                  _buildChoiceChip(context, notifier, RecommendationMode.accessible, "♿ Accessible", state.selectedMode),
                  _buildChoiceChip(context, notifier, RecommendationMode.eco, "🌱 Eco", state.selectedMode),
                  _buildChoiceChip(context, notifier, RecommendationMode.comfort, "🪑 Comfort", state.selectedMode),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Journey Card Details (All Routes or Selected Mode)
            if (state.plans.isNotEmpty) ...[
              if (state.selectedMode == RecommendationMode.all)
                Column(
                  children: state.plans.map((p) {
                    return JourneyOptionCard(
                      plan: p,
                      isSelected: true,
                      onTap: () {
                        context.push('/journey-details', extra: p);
                      },
                    );
                  }).toList(),
                )
              else if (state.selectedPlan != null)
                JourneyOptionCard(
                  plan: state.selectedPlan!,
                  isSelected: true,
                  onTap: () {
                    context.push('/journey-details', extra: state.selectedPlan);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(
    BuildContext context,
    SmartJourneyNotifier notifier,
    RecommendationMode mode,
    String label,
    RecommendationMode currentSelection,
  ) {
    final isSelected = mode == currentSelection;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF4F46E5),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            notifier.selectMode(mode);
          }
        },
      ),
    );
  }
}
