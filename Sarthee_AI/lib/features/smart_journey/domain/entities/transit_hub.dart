import 'transport_option.dart';

enum TransitHubType {
  metroStation,
  busStand,
  autoStand,
  eRickshawHub,
  railwayStation,
  airport,
  parking,
  evCharging,
  bicycleStand,
  ferry,
  ropeway,
}

class TransitHubFacility {
  final bool hasPublicToilet;
  final bool hasAtm;
  final bool hasDrinkingWater;
  final bool hasParking;
  final bool hasElevator;
  final bool hasEscalator;
  final bool hasWheelchairAccess;
  final bool hasFoodCourt;
  final bool hasEvCharging;
  final bool hasBicycleStand;

  const TransitHubFacility({
    this.hasPublicToilet = true,
    this.hasAtm = true,
    this.hasDrinkingWater = true,
    this.hasParking = false,
    this.hasElevator = true,
    this.hasEscalator = true,
    this.hasWheelchairAccess = true,
    this.hasFoodCourt = false,
    this.hasEvCharging = false,
    this.hasBicycleStand = false,
  });
}

class TransitHub {
  final String id;
  final String name;
  final TransitHubType type;
  final double latitude;
  final double longitude;
  final List<TransportMode> supportedModes;
  final TransitHubFacility facilities;
  final String? primaryGate;
  final String? metroLineColor;
  final String? platformInfo;
  final String operatingHours;
  final bool isSharedAvailable;

  const TransitHub({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.supportedModes,
    this.facilities = const TransitHubFacility(),
    this.primaryGate,
    this.metroLineColor,
    this.platformInfo,
    this.operatingHours = "05:30 AM - 11:30 PM",
    this.isSharedAvailable = true,
  });
}
