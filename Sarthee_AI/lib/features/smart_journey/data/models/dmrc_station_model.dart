class DmrcStationModel {
  final String stationId;
  final String stationName;
  final String lineName;
  final String lineColorHex;
  final double latitude;
  final double longitude;
  final bool isInterchange;
  final List<String> interchangeLines;
  final List<String> gateNumbers;
  final bool elevatorAvailable;

  const DmrcStationModel({
    required this.stationId,
    required this.stationName,
    required this.lineName,
    required this.lineColorHex,
    required this.latitude,
    required this.longitude,
    this.isInterchange = false,
    this.interchangeLines = const [],
    this.gateNumbers = const ["Gate 1", "Gate 2"],
    this.elevatorAvailable = true,
  });
}
