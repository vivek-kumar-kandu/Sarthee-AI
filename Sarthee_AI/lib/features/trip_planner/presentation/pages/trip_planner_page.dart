import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/provenance_badge_widget.dart';
import '../controllers/trip_planner_provider.dart';
import '../widgets/itinerary_card.dart';


class TripPlannerPage extends ConsumerStatefulWidget {
  const TripPlannerPage({super.key});

  @override
  ConsumerState<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends ConsumerState<TripPlannerPage> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'Jaipur');
  final TextEditingController _budgetController = TextEditingController(text: '1500');

  String _selectedPersona = 'Family';

  @override
  void dispose() {
    _promptController.dispose();
    _cityController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripPlannerProvider);
    final notifier = ref.read(tripPlannerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.route_rounded, color: Color(0xFF4F46E5)),
            SizedBox(width: 8),
            Text('AI Trip Planner & Optimizer'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.loadSavedTrips(),
            tooltip: 'Refresh Saved Trips',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Planning Form Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Design Custom Itinerary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _promptController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Describe your dream trip',
                        hintText: 'e.g. 2-day heritage & food exploration in Jaipur with family',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.auto_awesome_rounded, color: Color(0xFF4F46E5)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'Destination City',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_city_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max Budget (INR)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.currency_rupee_rounded),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPersona,
                      decoration: const InputDecoration(
                        labelText: 'Travel Persona',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_pin_rounded),
                      ),

                      items: const [
                        DropdownMenuItem(value: 'Family', child: Text('Family')),
                        DropdownMenuItem(value: 'Solo Explorer', child: Text('Solo Explorer')),
                        DropdownMenuItem(value: 'Couple / Romantic', child: Text('Couple / Romantic')),
                        DropdownMenuItem(value: 'Budget / Student', child: Text('Budget / Student')),
                        DropdownMenuItem(value: 'Luxury Travel', child: Text('Luxury Travel')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPersona = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: state.isLoading
                            ? null
                            : () {
                                final prompt = _promptController.text.trim();
                                if (prompt.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please describe your trip prompt.'),
                                    ),
                                  );
                                  return;
                                }
                                notifier.planTrip(
                                  rawPrompt: prompt,
                                  city: _cityController.text.trim(),
                                  maxBudget: double.tryParse(_budgetController.text) ?? 1500.0,
                                  persona: _selectedPersona,
                                );
                              },
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.bolt_rounded),
                        label: Text(
                          state.isLoading ? 'Optimizing Itinerary...' : 'Generate Optimized Trip',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Error Display
              if (state.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: Color(0xFF991B1B)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => notifier.loadSavedTrips(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Active Plan Response Output
              if (state.planResponse != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Generated Itinerary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (state.planResponse!.meta.provenance != null)
                      ProvenanceBadgeWidget(
                        provenance: state.planResponse!.meta.provenance!,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ItineraryCard(data: state.planResponse!.data),
                const SizedBox(height: 24),

              ],

              // Saved Trips Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Trips',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (state.savedTripsResponse?.meta.provenance != null)
                    ProvenanceBadgeWidget(
                      provenance: state.savedTripsResponse!.meta.provenance!,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  if (state.isLoading && state.savedTripsResponse == null) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final data = state.savedTripsResponse?.data;
                  final trips = (data != null && data['trips'] is List)
                      ? data['trips'] as List
                      : [];

                  if (trips.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No saved trips found.'),
                          SizedBox(height: 4),
                          Text(
                            'Generate an itinerary above to save your first trip.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: trips.map((trip) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF4F46E5)),
                          title: Text(trip['title']?.toString() ?? 'Saved Trip'),
                          subtitle: Text(trip['city']?.toString() ?? 'Destination'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
