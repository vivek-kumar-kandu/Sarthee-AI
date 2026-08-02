import 'package:flutter/material.dart';

import '../domain/entities/profile_entity.dart';

/// Reusable Travel Passport Header Card for Sarthee AI.
///
/// Features:
/// • Design System v1.2 Royal Indigo gradient backdrop
/// • Avatar photo / fallback initial badge
/// • Member status, location, and travel style badges
/// • Sleek profile completion indicator
class ProfilePassportCard extends StatelessWidget {
  const ProfilePassportCard({
    required this.profile,
    super.key,
    this.onEditPressed,
  });

  final ProfileEntity profile;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double completionFraction = profile.completionPercentage;
    final int completionPercent = (completionFraction * 100).round();
    final String memberSince = profile.createdAt.year.toString();

    return Semantics(
      container: true,
      label: 'Sarthee AI Travel Passport card for ${profile.name}',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF4F46E5), // Royal Indigo
              Color(0xFF3730A3), // Deep Indigo
              Color(0xFF0D9488), // Travel Teal accent glow
            ],
            stops: <double>[0.0, 0.65, 1.0],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.32),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header Row: Passport Label & Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: const <Widget>[
                          Icon(
                            Icons.card_membership_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B), // Warm Saffron
                          ),
                          SizedBox(width: 6),
                          Text(
                            'TRAVEL PASSPORT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (onEditPressed != null)
                  IconButton(
                    onPressed: onEditPressed,
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    tooltip: 'Edit Profile',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            // Profile Info Row: Avatar + Name + Details
            Row(
              children: <Widget>[
                // Avatar Photo / Initial
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 2,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: profile.picture != null && profile.picture!.isNotEmpty
                      ? Image.network(
                          profile.picture!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildInitialAvatar(profile.name),
                        )
                      : _buildInitialAvatar(profile.name),
                ),

                const SizedBox(width: 16),

                // Name & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        profile.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFFE2E8F0),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              profile.location.city ?? 'Explorer',
                              style: const TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• Member since $memberSince',
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Completion Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Profile Completeness',
                      style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$completionPercent%',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completionFraction,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.20),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFF59E0B), // Warm Saffron fill
                    ),
                  ),
                ),
              ],
            ),

            // Persona Badges Row (if populated)
            if (profile.profile.travelInterests != null && profile.profile.travelInterests!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: profile.profile.travelInterests!.take(3).map((badge) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String name) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Container(
      color: const Color(0xFF312E81),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
