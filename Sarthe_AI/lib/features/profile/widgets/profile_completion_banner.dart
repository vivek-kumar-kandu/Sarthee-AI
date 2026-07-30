import 'package:flutter/material.dart';

import '../domain/entities/profile_entity.dart';

/// Reusable Profile Completion Banner prompting users to enrich their travel profile.
class ProfileCompletionBanner extends StatelessWidget {
  const ProfileCompletionBanner({
    required this.profile,
    required this.onCompletePressed,
    super.key,
  });

  final ProfileEntity profile;
  final VoidCallback onCompletePressed;

  @override
  Widget build(BuildContext context) {
    if (profile.completionPercentage >= 1.0) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final List<String> missing = profile.missingFields;
    final String missingSummary = missing.isNotEmpty
        ? 'Add: ${missing.join(", ")}'
        : 'Complete your details to unlock full AI travel recommendations';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Soft Warm Saffron tint
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Warning / Info Icon Badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              size: 20,
              color: Color(0xFFD97706),
            ),
          ),

          const SizedBox(width: 12),

          // Content & Actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Complete your profile for better AI recommendations',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF92400E),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  missingSummary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFB45309),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: onCompletePressed,
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Text(
                        'Complete Profile',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFFD97706),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
