import 'package:flutter/material.dart';
import '../../domain/entities/fare_summary.dart';

class FareBreakdownCard extends StatelessWidget {
  final FareSummary fareSummary;

  const FareBreakdownCard({
    super.key,
    required this.fareSummary,
  });

  Color _getConfidenceColor(DataConfidence confidence) {
    switch (confidence) {
      case DataConfidence.live:
        return Colors.green;
      case DataConfidence.verified:
        return Colors.blue;
      case DataConfidence.estimated:
        return Colors.orange;
      case DataConfidence.cached:
        return Colors.grey;
      case DataConfidence.offline:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF0D9488)),
              const SizedBox(width: 8),
              const Text(
                "Fare & Budget Breakdown",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                "Total ₹${fareSummary.totalAmount.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF0D9488),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...fareSummary.items.map((item) {
            final confColor = _getConfidenceColor(item.confidence);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.legTitle,
                      style: const TextStyle(fontSize: 13.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: confColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.confidence.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: confColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "₹${item.amount.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            );
          }),
          if (fareSummary.smartCardDiscountEligible) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Save ₹${fareSummary.potentialSavings.toStringAsFixed(0)} using DMRC Smart Card (10% Off Peak Discount)",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
