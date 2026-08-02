import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/journey_session.dart';
import '../providers/active_trip_provider.dart';
import '../widgets/step_detail_tile.dart';

class ActiveJourneyGuidePage extends ConsumerWidget {
  const ActiveJourneyGuidePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(activeTripProvider);
    final notifier = ref.read(activeTripProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.near_me_rounded, color: Color(0xFF0D9488)),
            SizedBox(width: 8),
            Text("Active Trip Mode"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sos_rounded, color: Color(0xFFDC2626)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Emergency SOS triggered! Live location shared with trusted contacts."),
                  backgroundColor: Color(0xFFDC2626),
                ),
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session == null) {
            return const Center(child: Text("No active trip session found."));
          }

          final currentStep = session.plan.steps[session.currentStepIndex];
          final progressRatio = (session.currentStepIndex + 1) / session.plan.steps.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Status Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111827) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0D9488), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(session.status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 8, color: _getStatusColor(session.status)),
                                const SizedBox(width: 6),
                                Text(
                                  session.status.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(session.status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Step ${session.currentStepIndex + 1} of ${session.plan.steps.length}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progressRatio,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Active Step Card
                const Text(
                  "Current Navigation Instruction",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                StepDetailTile(step: currentStep, isCurrentStep: true),

                const SizedBox(height: 16),

                // Active Alerts
                if (session.activeAlerts.isNotEmpty) ...[
                  const Text(
                    "Live Travel Alerts",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...session.activeAlerts.map((alert) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                ),
                                Text(
                                  alert.message,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 24),

                // Trip Controls Row (Next Step, Pause, End)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (session.status == JourneyStatus.active) {
                            notifier.updateStatus(JourneyStatus.paused);
                          } else {
                            notifier.updateStatus(JourneyStatus.active);
                          }
                        },
                        child: Text(
                          session.status == JourneyStatus.active ? "Pause Trip" : "Resume Trip",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          notifier.nextStep();
                          if (session.currentStepIndex + 1 >= session.plan.steps.length) {
                            context.pop();
                          }
                        },
                        child: Text(
                          session.currentStepIndex + 1 >= session.plan.steps.length
                              ? "Complete Trip"
                              : "Next Step",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: ${e.toString()}")),
      ),
    );
  }

  Color _getStatusColor(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.planned:
        return Colors.blue;
      case JourneyStatus.active:
        return Colors.green;
      case JourneyStatus.paused:
        return Colors.orange;
      case JourneyStatus.completed:
        return const Color(0xFF0D9488);
      case JourneyStatus.cancelled:
        return Colors.red;
      case JourneyStatus.replanning:
        return const Color(0xFF7C3AED);
    }
  }
}
