import 'package:flutter/material.dart';
import '../../domain/entities/journey_plan.dart';
import '../../domain/entities/journey_step.dart';
import '../services/voice_guidance_service.dart';

class ActiveTripGuidanceWidget extends StatefulWidget {
  final JourneyPlan plan;
  final VoidCallback onEndTrip;

  const ActiveTripGuidanceWidget({
    super.key,
    required this.plan,
    required this.onEndTrip,
  });

  @override
  State<ActiveTripGuidanceWidget> createState() => _ActiveTripGuidanceWidgetState();
}

class _ActiveTripGuidanceWidgetState extends State<ActiveTripGuidanceWidget> {
  int _currentStepIndex = 0;
  final VoiceGuidanceService _voiceService = VoiceGuidanceService();

  @override
  void initState() {
    super.initState();
    _triggerVoicePrompt();
  }

  void _triggerVoicePrompt() {
    if (widget.plan.steps.isNotEmpty && _currentStepIndex < widget.plan.steps.length) {
      final step = widget.plan.steps[_currentStepIndex];
      _voiceService.speakPrompt("${step.title}. ${step.instruction}");
    }
  }

  void _nextStep() {
    if (_currentStepIndex < widget.plan.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _triggerVoicePrompt();
    } else {
      widget.onEndTrip();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
      _triggerVoicePrompt();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSteps = widget.plan.steps.isNotEmpty ? widget.plan.steps.length : 1;
    final progress = (_currentStepIndex + 1) / totalSteps;
    final currentStep = widget.plan.steps.isNotEmpty ? widget.plan.steps[_currentStepIndex] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge & Progress Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.navigation_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      "LIVE TRIP GUIDANCE",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _voiceService.isVoiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  color: const Color(0xFF2563EB),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _voiceService.toggleVoiceGuidance();
                  });
                },
                tooltip: "Toggle Voice Navigation",
              ),
              const SizedBox(width: 8),
              Text(
                "Step ${_currentStepIndex + 1} of $totalSteps",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2563EB)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Linear Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFDBEAFE),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          ),

          const SizedBox(height: 14),

          // Current Active Step Details Card
          if (currentStep != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStepIcon(currentStep.type),
                    color: const Color(0xFF2563EB),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStep.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStep.instruction,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      if (currentStep.landmarkTip != null && currentStep.landmarkTip!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.storefront_rounded, size: 14, color: Colors.amber.shade900),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                currentStep.landmarkTip!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Action Navigation Controls (Previous / Next / Finish)
          Row(
            children: [
              if (_currentStepIndex > 0)
                OutlinedButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text("Previous"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(
                  _currentStepIndex == totalSteps - 1 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                  size: 18,
                ),
                label: Text(
                  _currentStepIndex == totalSteps - 1 ? "Complete Trip" : "Next Milestone",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
}
