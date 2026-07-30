import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/smart_journey_provider.dart';
import '../widgets/journey_option_card.dart';
import '../widgets/sarthee_ai_advisor_card.dart';
import '../../domain/entities/journey_plan.dart';

class SmartJourneyPlannerPage extends ConsumerStatefulWidget {
  const SmartJourneyPlannerPage({super.key});

  @override
  ConsumerState<SmartJourneyPlannerPage> createState() => _SmartJourneyPlannerPageState();
}

class _SmartJourneyPlannerPageState extends ConsumerState<SmartJourneyPlannerPage> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(smartJourneyProvider);
    _originController.text = state.origin;
    _destController.text = state.destination;
  }

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    super.dispose();
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
                  TextField(
                    controller: _originController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.my_location_rounded, color: Color(0xFF0D9488)),
                      labelText: "Origin / Current Location",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _destController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on_rounded, color: Color(0xFFDC2626)),
                      labelText: "Destination",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        notifier.searchJourney(
                          origin: _originController.text,
                          destination: _destController.text,
                        );
                      },
                      icon: const Icon(Icons.route_rounded, color: Colors.white),
                      label: const Text(
                        "Orchestrate Smart Journey",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mode Filter Chips
            const Text(
              "Recommendation Preferences",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: RecommendationMode.values.map((mode) {
                  final isSelected = state.selectedMode == mode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_modeLabel(mode)),
                      selected: isSelected,
                      selectedColor: const Color(0xFF4F46E5),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) notifier.selectMode(mode);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Loading / Error / Results
            if (state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.errorMessage != null)
              Center(
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else ...[
              // AI Advisor Rationale
              if (state.selectedPlan != null)
                SartheeAiAdvisorCard(rationale: state.selectedPlan!.aiRationale),

              const SizedBox(height: 12),
              const Text(
                "Multi-Modal Journey Plans",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              ...state.plans.map((plan) {
                final isSelected = state.selectedMode == plan.mode;
                return JourneyOptionCard(
                  plan: plan,
                  isSelected: isSelected,
                  onTap: () {
                    notifier.selectMode(plan.mode);
                    context.push('/journey-details', extra: plan);
                  },
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  String _modeLabel(RecommendationMode mode) {
    switch (mode) {
      case RecommendationMode.recommended:
        return "🌟 Recommended";
      case RecommendationMode.fastest:
        return "⚡ Fastest";
      case RecommendationMode.cheapest:
        return "💰 Cheapest";
      case RecommendationMode.balanced:
        return "🟢 Balanced";
      case RecommendationMode.safest:
        return "🛡️ Safest";
      case RecommendationMode.accessible:
        return "♿ Accessible";
      case RecommendationMode.eco:
        return "🌱 Eco-Friendly";
      case RecommendationMode.comfort:
        return "🪑 Comfort";
    }
  }
}
