import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';

/// "Continue Your Journey" Card handling active trips, upcoming bookings, or saved draft itineraries.
class HomeJourneySection extends StatelessWidget {
  const HomeJourneySection({
    required this.journey,
    required this.onJourneyPressed,
    required this.onStartPlanPressed,
    super.key,
  });

  final ActiveJourney? journey;
  final ValueChanged<ActiveJourney> onJourneyPressed;
  final VoidCallback onStartPlanPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Continue Your Journey',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            if (journey != null)
              InkWell(
                onTap: () => onJourneyPressed(journey!),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF0D9488), // Travel Teal
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Journey Card or Empty State
        if (journey != null)
          _buildJourneyCard(context, journey!)
        else
          _buildEmptyStateCard(context),
      ],
    );
  }

  Widget _buildJourneyCard(BuildContext context, ActiveJourney journey) {
    return Semantics(
      container: true,
      label: 'Active trip: ${journey.title}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onJourneyPressed(journey),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF4F46E5), // Royal Indigo
                  Color(0xFF3730A3), // Deep Indigo
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Status Badge & Weather Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        journey.statusLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.wb_sunny_outlined,
                          size: 14,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          journey.weatherForecast,
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Title & Destination
                Text(
                  journey.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: Color(0xFFCBD5E1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      journey.destination,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Footer CTA Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${journey.daysRemaining} days remaining',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B), // Warm Saffron
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: const <Widget>[
                        Text(
                          'Continue Itinerary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA), // Soft Travel Teal tint
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF99F6E4)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFCCFBF1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              size: 24,
              color: Color(0xFF0D9488),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'No active journey',
                  style: TextStyle(
                    color: Color(0xFF0F766E),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Start planning your next AI itinerary in seconds',
                  style: TextStyle(
                    color: Color(0xFF115E59),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onStartPlanPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Plan →',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
