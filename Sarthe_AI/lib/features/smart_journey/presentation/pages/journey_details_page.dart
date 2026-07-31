import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/journey_plan.dart';
import '../providers/active_trip_provider.dart';
import '../widgets/sarthee_ai_advisor_card.dart';
import '../widgets/sarthee_leaflet_map_widget.dart';
import '../widgets/step_detail_tile.dart';
import '../widgets/fare_breakdown_card.dart';
import '../widgets/active_trip_guidance_widget.dart';

class JourneyDetailsPage extends ConsumerWidget {
  final JourneyPlan plan;

  const JourneyDetailsPage({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeSession = ref.watch(activeTripProvider).value;
    final isTripActive = activeSession != null && activeSession.plan.id == plan.id;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("${plan.originName} ➔ ${plan.destinationName}"),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Journey Time",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${plan.totalDurationMinutes} minutes",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Total Fare",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${plan.totalCost.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Leaflet Vector Map
            SartheeLeafletMapWidget(
              plan: plan,
              height: 260,
            ),
            const SizedBox(height: 16),

            // AI Advisor
            SartheeAiAdvisorCard(rationale: plan.aiRationale),
            const SizedBox(height: 16),

            // Door-to-Door Step Timeline
            const Text(
              "Door-to-Door Journey Timeline",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            ...plan.steps.map((step) => StepDetailTile(step: step)),

            const SizedBox(height: 16),

            // Fare breakdown
            FareBreakdownCard(fareSummary: plan.fareSummary),

            const SizedBox(height: 24),

            // Start Journey Button & Live Guidance View
            isTripActive
                ? ActiveTripGuidanceWidget(
                    plan: plan,
                    onEndTrip: () {
                      ref.read(activeTripProvider.notifier).cancelTrip();
                    },
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      onPressed: () async {
                        await ref.read(activeTripProvider.notifier).startTrip(plan);
                      },
                      icon: const Icon(Icons.navigation_rounded, color: Colors.white),
                      label: const Text(
                        "Start Active Trip Guidance",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
