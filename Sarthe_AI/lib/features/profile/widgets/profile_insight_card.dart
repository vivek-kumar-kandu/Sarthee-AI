import 'package:flutter/material.dart';

import '../domain/entities/profile_entity.dart';

/// Reusable Profile Insight Card presenting context-aware profile enrichment tips.
class ProfileInsightCard extends StatelessWidget {
  const ProfileInsightCard({
    required this.profile,
    required this.onActionPressed,
    super.key,
  });

  final ProfileEntity profile;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final List<_InsightItem> insights = _generateInsights(profile);

    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final _InsightItem primaryInsight = insights.first;

    return Semantics(
      container: true,
      label: 'Profile recommendation: ${primaryInsight.title}',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryInsight.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryInsight.color.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            // Insight Icon Badge
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryInsight.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                primaryInsight.icon,
                size: 20,
                color: primaryInsight.color,
              ),
            ),

            const SizedBox(width: 14),

            // Content & Action Button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    primaryInsight.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    primaryInsight.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Action Arrow / Button
            InkWell(
              onTap: onActionPressed,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryInsight.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_InsightItem> _generateInsights(ProfileEntity profile) {
    final list = <_InsightItem>[];

    if (profile.preferences.dietaryPreference == null ||
        profile.preferences.dietaryPreference!.isEmpty) {
      list.add(
        const _InsightItem(
          icon: Icons.restaurant_menu_rounded,
          title: 'Add Dietary Preference',
          subtitle: 'Receive pure veg, vegan, or Jain restaurant recommendations',
          color: Color(0xFF0D9488), // Travel Teal
        ),
      );
    }

    if (profile.profile.travelInterests == null ||
        profile.profile.travelInterests!.isEmpty) {
      list.add(
        const _InsightItem(
          icon: Icons.travel_explore_rounded,
          title: 'Select Travel Interests',
          subtitle: 'Improve personalized destination and attraction suggestions',
          color: Color(0xFF4F46E5), // Royal Indigo
        ),
      );
    }

    if (profile.preferences.budgetTier == null ||
        profile.preferences.budgetTier!.isEmpty) {
      list.add(
        const _InsightItem(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Set Budget Comfort Tier',
          subtitle: 'Tailor hotel, stay, and transport recommendations',
          color: Color(0xFFF59E0B), // Warm Saffron
        ),
      );
    }

    return list;
  }
}

class _InsightItem {
  const _InsightItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}
