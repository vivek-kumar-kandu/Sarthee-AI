import 'package:flutter/material.dart';

import '../domain/entities/profile_entity.dart';

/// Reusable Travel Persona Summary Widget displaying active travel preferences.
class ProfileSummaryWidget extends StatelessWidget {
  const ProfileSummaryWidget({
    required this.profile,
    super.key,
    this.onEditPressed,
  });

  final ProfileEntity profile;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final List<String> interests = profile.profile.travelInterests ?? <String>[];
    final String? pace = profile.profile.travelPace;
    final String? companion = profile.profile.companionPreference;
    final String? diet = profile.preferences.dietaryPreference;
    final String? budget = profile.preferences.budgetTier;
    final String? transport = profile.preferences.preferredTransport;

    final bool hasData = interests.isNotEmpty ||
        pace != null ||
        companion != null ||
        diet != null ||
        budget != null ||
        transport != null;

    if (!hasData) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Row: Title & Edit Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_pin_rounded,
                      size: 20,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Travel Persona',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (onEditPressed != null)
                InkWell(
                  onTap: onEditPressed,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: Color(0xFF0D9488),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 1. Travel Interests Chips
          if (interests.isNotEmpty) ...<Widget>[
            const Text(
              'Interests',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: interests
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF99F6E4)),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xFF0F766E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
          ],

          // 2. Preferences Grid Badges
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              if (pace != null && pace.isNotEmpty)
                _buildBadge(Icons.speed_rounded, 'Pace: $pace', const Color(0xFF4F46E5)),
              if (companion != null && companion.isNotEmpty)
                _buildBadge(Icons.group_outlined, 'Companion: $companion', const Color(0xFF3B82F6)),
              if (diet != null && diet.isNotEmpty)
                _buildBadge(Icons.restaurant_rounded, 'Diet: $diet', const Color(0xFF0D9488)),
              if (budget != null && budget.isNotEmpty)
                _buildBadge(Icons.account_balance_wallet_rounded, 'Budget: $budget', const Color(0xFFF59E0B)),
              if (transport != null && transport.isNotEmpty)
                _buildBadge(Icons.commute_rounded, 'Transport: $transport', const Color(0xFF8B5CF6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
