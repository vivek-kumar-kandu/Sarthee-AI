enum TransportMode {
  walk,
  auto,
  eRickshaw,
  sharedAuto,
  metro,
  bus,
  cab,
  train,
  ferry,
  ropeway,
  bicycle,
}

class TransportOption {
  final TransportMode mode;
  final String name;
  final String iconName;
  final bool isShared;
  final bool isEcoFriendly;
  final double averageWaitMinutes;
  final String fareType;

  const TransportOption({
    required this.mode,
    required this.name,
    required this.iconName,
    this.isShared = false,
    this.isEcoFriendly = false,
    this.averageWaitMinutes = 2.0,
    required this.fareType,
  });
}
