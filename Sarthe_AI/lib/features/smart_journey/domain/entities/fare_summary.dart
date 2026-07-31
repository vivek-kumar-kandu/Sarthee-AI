enum DataConfidence {
  live,
  verified,
  estimated,
  cached,
  offline,
}

class FareItem {
  final String legTitle;
  final double amount;
  final String paymentMethod;
  final DataConfidence confidence;

  const FareItem({
    required this.legTitle,
    required this.amount,
    required this.paymentMethod,
    this.confidence = DataConfidence.estimated,
  });

  factory FareItem.fromJson(Map<String, dynamic> json) {
    return FareItem(
      legTitle: json['legTitle'] as String? ?? 'Fare Item',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
      confidence: _parseConfidence(json['confidence'] as String?),
    );
  }

  static DataConfidence _parseConfidence(String? str) {
    switch (str) {
      case 'live':
        return DataConfidence.live;
      case 'verified':
        return DataConfidence.verified;
      case 'cached':
        return DataConfidence.cached;
      case 'offline':
        return DataConfidence.offline;
      default:
        return DataConfidence.estimated;
    }
  }
}

class FareSummary {
  final double totalAmount;
  final String currencySymbol;
  final List<FareItem> items;
  final bool smartCardDiscountEligible;
  final double potentialSavings;

  const FareSummary({
    required this.totalAmount,
    this.currencySymbol = '₹',
    required this.items,
    this.smartCardDiscountEligible = false,
    this.potentialSavings = 0.0,
  });

  factory FareSummary.fromJson(Map<String, dynamic> json) {
    return FareSummary(
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currencySymbol: json['currency'] == 'INR' ? '₹' : (json['currencySymbol'] as String? ?? '₹'),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => FareItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      smartCardDiscountEligible: json['smartCardDiscountEligible'] as bool? ?? false,
      potentialSavings: (json['potentialSavings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
