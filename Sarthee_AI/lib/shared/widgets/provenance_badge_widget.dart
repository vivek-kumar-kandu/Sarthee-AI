import 'package:flutter/material.dart';
import '../../../core/network/api_response.dart';

/// ProvenanceBadgeWidget — Visual Data Provenance UI Component
///
/// Renders clear provider transparency badges matching the "Never Fake Real-Time" principle:
///
/// 🟢 Live (Provider Name)
/// 🔵 Scheduled (Static Timetable)
/// 🟡 Cached (LRU / Redis)
/// ⚪ Offline / Fallback
class ProvenanceBadgeWidget extends StatelessWidget {
  const ProvenanceBadgeWidget({
    required this.provenance,
    this.showLatency = true,
    this.compact = false,
    super.key,
  });

  final Provenance? provenance;
  final bool showLatency;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (provenance == null) return const SizedBox.shrink();

    final prov = provenance!;
    final Color badgeColor;
    final String statusIcon;
    final String statusLabel;

    if (prov.fallback) {
      badgeColor = Colors.grey;
      statusIcon = '⚪';
      statusLabel = 'Fallback (${prov.provider})';
    } else if (prov.cache) {
      badgeColor = Colors.amber.shade700;
      statusIcon = '🟡';
      statusLabel = 'Cached (${prov.provider})';
    } else if (prov.confidence <= 0.65) {
      badgeColor = Colors.blue.shade600;
      statusIcon = '🔵';
      statusLabel = 'Scheduled (${prov.provider})';
    } else {
      badgeColor = Colors.green.shade600;
      statusIcon = '🟢';
      statusLabel = 'Live (${prov.provider})';
    }

    final confidencePercent = (prov.confidence * 100).toInt();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(statusIcon, style: TextStyle(fontSize: compact ? 10 : 12)),
          const SizedBox(width: 4),
          Text(
            statusLabel,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 10 : 12,
            ),
          ),
          if (showLatency && prov.latencyMs > 0) ...[
            const SizedBox(width: 6),
            Text(
              '• ${prov.latencyMs}ms',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: compact ? 9 : 11,
              ),
            ),
          ],
          if (confidencePercent < 100) ...[
            const SizedBox(width: 4),
            Text(
              '($confidencePercent%)',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: compact ? 9 : 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
