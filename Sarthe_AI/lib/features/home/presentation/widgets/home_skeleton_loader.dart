import 'package:flutter/material.dart';

/// Shimmer Skeleton Placeholder loader for zero-cache first launches.
class HomeSkeletonLoader extends StatelessWidget {
  const HomeSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header Skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildShimmerBox(width: 180, height: 24, radius: 8),
                const SizedBox(height: 6),
                _buildShimmerBox(width: 120, height: 16, radius: 6),
              ],
            ),
            _buildShimmerBox(width: 46, height: 46, radius: 23),
          ],
        ),

        const SizedBox(height: 20),

        // Search Bar Skeleton
        _buildShimmerBox(width: double.infinity, height: 50, radius: 16),

        const SizedBox(height: 24),

        // Quick Actions Skeleton
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildShimmerBox(width: double.infinity, height: 75, radius: 16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Active Journey Skeleton Card
        _buildShimmerBox(width: double.infinity, height: 160, radius: 20),

        const SizedBox(height: 24),

        // AI Prompts Skeleton
        _buildShimmerBox(width: 140, height: 20, radius: 6),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            _buildShimmerBox(width: 200, height: 90, radius: 16),
            const SizedBox(width: 12),
            _buildShimmerBox(width: 140, height: 90, radius: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
