export class FareSummaryVO {
  constructor(totalAmount, currency = 'INR', items = [], smartCardDiscountEligible = false) {
    if (typeof totalAmount !== 'number' || totalAmount < 0) {
      throw new Error(`Invalid totalAmount: ${totalAmount}. Cannot be negative.`);
    }
    this.totalAmount = totalAmount;
    this.currency = currency;
    this.items = items;
    this.smartCardDiscountEligible = smartCardDiscountEligible;
  }
}

