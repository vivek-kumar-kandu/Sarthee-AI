import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';

/// Contextual Nearby Recommendations Section Widget for Home Dashboard.
class HomeNearbySection extends StatelessWidget {
  const HomeNearbySection({
    required this.places,
    required this.onPlacePressed,
    required this.onExploreAllPressed,
    super.key,
  });

  final List<NearbyPlace> places;
  final ValueChanged<NearbyPlace> onPlacePressed;
  final VoidCallback onExploreAllPressed;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Explore Nearby',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            InkWell(
              onTap: onExploreAllPressed,
              child: const Text(
                'Explore All',
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

        // Places Cards List
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: places.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final place = places[index];
              return _buildPlaceCard(context, place);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceCard(BuildContext context, NearbyPlace place) {
    return Semantics(
      button: true,
      label: 'Nearby place: ${place.name}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPlacePressed(place),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 160,
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
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Image Header Container
                Container(
                  height: 100,
                  width: double.infinity,
                  color: const Color(0xFFE2E8F0),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Icon(
                          Icons.image_rounded,
                          size: 32,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: <Widget>[
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                place.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Details Content
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        place.name,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${place.category} • ${place.distance}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
