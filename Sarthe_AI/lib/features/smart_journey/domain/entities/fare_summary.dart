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
}
