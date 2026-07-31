import 'package:flutter/material.dart';
import '../../domain/entities/journey_step.dart';

class StepDetailTile extends StatelessWidget {
  final JourneyStep step;
  final bool isCurrentStep;

  const StepDetailTile({
    super.key,
    required this.step,
    this.isCurrentStep = false,
  });

  IconData _getStepIcon(StepType type) {
    switch (type) {
      case StepType.walk:
        return Icons.directions_walk_rounded;
      case StepType.auto:
      case StepType.sharedAuto:
        return Icons.electric_rickshaw_rounded;
      case StepType.eRickshaw:
        return Icons.two_wheeler_rounded;
      case StepType.metro:
        return Icons.subway_rounded;
      case StepType.bus:
        return Icons.directions_bus_rounded;
      case StepType.cab:
        return Icons.local_taxi_rounded;
      case StepType.train:
        return Icons.train_rounded;
    }
  }

  Color _getStepColor(StepType type) {
    switch (type) {
      case StepType.walk:
        return Colors.blueGrey;
      case StepType.auto:
      case StepType.eRickshaw:
      case StepType.sharedAuto:
        return const Color(0xFFF59E0B);
      case StepType.metro:
        return const Color(0xFFDC2626);
      case StepType.bus:
        return const Color(0xFF2563EB);
      case StepType.cab:
        return const Color(0xFF0D9488);
      case StepType.train:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stepColor = _getStepColor(step.type);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentStep
            ? stepColor.withValues(alpha: 0.1)
            : (isDark ? const Color(0xFF172033) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentStep ? stepColor : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isCurrentStep ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stepColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStepIcon(step.type), color: stepColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: isCurrentStep ? stepColor : null,
                        ),
                      ),
                    ),
                    if (step.estimatedFare > 0)
                      Text(
                        "₹${step.estimatedFare.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  step.instruction,
                  style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.35),
                ),
                if (step.metroGateNumber != null || step.platformNumber != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (step.metroGateNumber != null)
                        _buildBadge(Icons.door_sliding_outlined, step.metroGateNumber!, Colors.indigo),
                      if (step.platformNumber != null)
                        _buildBadge(Icons.train_outlined, step.platformNumber!, Colors.deepOrange),
                      if (step.nextDepartureInMinutes != null)
                        _buildBadge(Icons.access_time_rounded, "ETA ${step.nextDepartureInMinutes} min", Colors.teal),
                    ],
                  ),
                ],
                if (step.landmarkTip != null && step.landmarkTip!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.storefront_rounded, size: 15, color: Colors.amber.shade900),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            step.landmarkTip!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
