import 'package:flutter/material.dart';

class ItineraryCard extends StatelessWidget {
  const ItineraryCard({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = data['title']?.toString() ?? 'Trip Plan';
    final city = data['city']?.toString() ?? '';
    final persona = data['persona']?.toString() ?? '';
    final status = data['status']?.toString() ?? 'PLANNED';
    final shareUrl = data['shareUrl']?.toString();

    final costBreakdown = (data['costBreakdown'] is Map<String, dynamic>)
        ? data['costBreakdown'] as Map<String, dynamic>
        : <String, dynamic>{};

    final aiAdvice = (data['aiAdvice'] is Map<String, dynamic>)
        ? data['aiAdvice'] as Map<String, dynamic>
        : <String, dynamic>{};

    final days = (data['days'] is List) ? data['days'] as List : <dynamic>[];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Trip Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                        ),

                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF16A34A)),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (city.isNotEmpty)
                      _buildChip(Icons.location_on_rounded, city, const Color(0xFF4F46E5)),
                    if (persona.isNotEmpty)
                      _buildChip(Icons.people_rounded, persona, const Color(0xFF0D9488)),
                    _buildChip(
                      Icons.currency_rupee_rounded,
                      'Cost: ₹${costBreakdown['total'] ?? 0}',
                      const Color(0xFF16A34A),
                    ),
                  ],
                ),
                if (shareUrl != null && shareUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.share_rounded, size: 16, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SelectableText(
                          shareUrl,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4F46E5),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Cost Breakdown Section
                if (costBreakdown.isNotEmpty) ...[
                  const Text(
                    'Budget & Cost Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCostItem('Transport', '₹${costBreakdown['transport'] ?? 0}'),
                        _buildCostItem('Food', '₹${costBreakdown['food'] ?? 0}'),
                        _buildCostItem('Tickets', '₹${costBreakdown['tickets'] ?? 0}'),
                        _buildCostItem('Buffer', '₹${costBreakdown['buffer'] ?? 0}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 3. AI Travel Advice & Packing Tips
                if (aiAdvice.isNotEmpty) ...[
                  const Text(
                    'Sarthee AI Intelligence',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (aiAdvice['summary'] != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF4F46E5), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              aiAdvice['summary'].toString(),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (aiAdvice['itineraryExplanation'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      aiAdvice['itineraryExplanation'].toString(),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                  if (aiAdvice['packingTips'] is List && (aiAdvice['packingTips'] as List).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Recommended Packing Tips',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (aiAdvice['packingTips'] as List).map((tip) {
                        return Chip(
                          label: Text(
                            tip.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          avatar: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF16A34A)),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],

                // 4. Day-by-Day Itinerary & Stops
                if (days.isNotEmpty) ...[
                  const Text(
                    'Detailed Day-by-Day Schedule',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: days.map((day) {
                      final dayTitle = day['title']?.toString() ?? 'Day Itinerary';
                      final stops = (day['stops'] is List) ? day['stops'] as List : [];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4F46E5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                            ),
                            title: Text(
                              dayTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Text('${stops.length} Scheduled Stops'),
                            children: stops.map((stop) {
                              final name = stop['name']?.toString() ?? 'Stop';
                              final category = stop['category']?.toString() ?? 'place';
                              final duration = stop['durationMinutes'] ?? 60;
                              final cost = stop['cost'] ?? 0;
                              final whyList = (stop['whyRecommended'] is List) ? stop['whyRecommended'] as List : [];

                              return Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _getCategoryIcon(category),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                '⏱️ $duration min',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                '🎟️ ₹$cost',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          if (whyList.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 4,
                                              children: whyList.map((reason) {
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    reason.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFF0D9488),
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
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildCostItem(String label, String amount) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData icon;
    Color color;

    switch (category.toLowerCase()) {
      case 'heritage':
        icon = Icons.account_balance_rounded;
        color = const Color(0xFFB45309);
        break;
      case 'food':
      case 'restaurant':
        icon = Icons.restaurant_rounded;
        color = const Color(0xFFD97706);
        break;
      case 'hotel':
        icon = Icons.hotel_rounded;
        color = const Color(0xFF2563EB);
        break;
      default:
        icon = Icons.place_rounded;
        color = const Color(0xFF4F46E5);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
