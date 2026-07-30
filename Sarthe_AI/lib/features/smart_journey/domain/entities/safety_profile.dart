class SafetyProfile {
  final int lightingRating;       // 0 - 10
  final int crowdRating;          // 0 - 10
  final int policePresenceRating; // 0 - 10
  final int cctvRating;           // 0 - 10
  final int womensSafetyRating;   // 0 - 10
  final int medicalAccessRating;  // 0 - 10
  final String safetyAdvisory;
  final String safeWaitingArea;

  const SafetyProfile({
    this.lightingRating = 8,
    this.crowdRating = 7,
    this.policePresenceRating = 7,
    this.cctvRating = 9,
    this.womensSafetyRating = 8,
    this.medicalAccessRating = 8,
    this.safetyAdvisory = 'Safe illuminated main corridor route.',
    this.safeWaitingArea = 'Station Concourse / Gate 2 Verified Booth',
  });

  /// Calculates composite safety score (0 to 100)
  int get compositeScore {
    final double total = (lightingRating * 2.0) +
        (crowdRating * 1.5) +
        (policePresenceRating * 1.5) +
        (cctvRating * 1.5) +
        (womensSafetyRating * 2.0) +
        (medicalAccessRating * 1.5);
    return (total).round().clamp(0, 100);
  }

  bool get isSafeForNightTravel => compositeScore >= 65;
}
