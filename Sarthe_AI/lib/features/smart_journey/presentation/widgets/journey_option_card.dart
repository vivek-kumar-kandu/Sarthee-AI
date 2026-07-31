import 'package:flutter/material.dart';
import '../../domain/entities/journey_plan.dart';

class JourneyOptionCard extends StatelessWidget {
  final JourneyPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const JourneyOptionCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  String _getModeLabel(RecommendationMode mode) {
    switch (mode) {
      case RecommendationMode.all:
        return "✨ Option";
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

  Color _getModeColor(RecommendationMode mode) {
    switch (mode) {
      case RecommendationMode.all:
        return const Color(0xFF6366F1);
      case RecommendationMode.recommended:
        return const Color(0xFF6750A4);
      case RecommendationMode.fastest:
        return const Color(0xFFF59E0B);
      case RecommendationMode.cheapest:
        return const Color(0xFF10B981);
      case RecommendationMode.balanced:
        return const Color(0xFF4F46E5);
      case RecommendationMode.safest:
        return const Color(0xFF0D9488);
      case RecommendationMode.accessible:
        return const Color(0xFF2563EB);
      case RecommendationMode.eco:
        return const Color(0xFF059669);
      case RecommendationMode.comfort:
        return const Color(0xFF7C3AED);
    }
  }

  Widget _buildStepIconPills(List steps, bool isDark) {
    if (steps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: steps.map((s) {
          IconData icon = Icons.directions_walk_rounded;
          Color color = Colors.grey;

          if (s.type.toString().contains('auto') || s.type.toString().contains('eRickshaw')) {
            icon = Icons.electric_rickshaw_rounded;
            color = const Color(0xFFF59E0B);
          } else if (s.type.toString().contains('metro')) {
            icon = Icons.subway_rounded;
            color = const Color(0xFFDC2626);
          } else if (s.type.toString().contains('bus')) {
            icon = Icons.directions_bus_rounded;
            color = const Color(0xFF2563EB);
          } else if (s.type.toString().contains('cab')) {
            icon = Icons.local_taxi_rounded;
            color = const Color(0xFF0D9488);
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: color),
                if (s.durationMinutes > 0) ...[
                  const SizedBox(width: 3),
                  Text(
                    "${s.durationMinutes}m",
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modeColor = _getModeColor(plan.mode);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? modeColor.withValues(alpha: 0.18) : modeColor.withValues(alpha: 0.08))
              : (isDark ? const Color(0xFF111827) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? modeColor : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: modeColor.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getModeLabel(plan.mode),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: modeColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  "₹${plan.totalCost.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF0D9488),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${plan.totalDurationMinutes} mins",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.directions_walk_rounded, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${plan.totalWalkingDistanceMeters.toStringAsFixed(0)}m walk",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_rounded, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        "${plan.compositeSafetyScore}% Safe",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildStepIconPills(plan.steps, isDark),
          ],
        ),
      ),
    );
  }
}
