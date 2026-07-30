import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';

/// Reusable Home Greeting Header Widget featuring dynamic time greeting & location weather badge.
class HomeGreetingSection extends StatelessWidget {
  const HomeGreetingSection({
    required this.greeting,
    required this.onPassportPressed,
    super.key,
  });

  final HomeGreeting greeting;
  final VoidCallback onPassportPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String greetingTitle = '${greeting.dynamicGreetingText}, ${greeting.userName}!';

    return Semantics(
      container: true,
      label: 'Home header: $greetingTitle in ${greeting.city}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Left Side: Time-Aware Greeting & Location Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  greetingTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: Color(0xFF0D9488), // Travel Teal
                    ),
                    const SizedBox(width: 4),
                    Text(
                      greeting.city,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.wb_sunny_rounded,
                            size: 12,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            greeting.temperature,
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right Side: Travel Passport Avatar Button
          InkWell(
            onTap: onPassportPressed,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                border: Border.all(
                  color: const Color(0xFF4F46E5),
                  width: 1.8,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: greeting.avatarUrl != null && greeting.avatarUrl!.isNotEmpty
                  ? Image.network(
                      greeting.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildInitialBadge(greeting.userName),
                    )
                  : _buildInitialBadge(greeting.userName),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialBadge(String name) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Container(
      color: const Color(0xFF4F46E5),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
