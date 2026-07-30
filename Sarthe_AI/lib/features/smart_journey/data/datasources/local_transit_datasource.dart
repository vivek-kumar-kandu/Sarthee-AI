import '../models/dmrc_station_model.dart';
import '../../domain/entities/transit_hub.dart';
import '../../domain/entities/transport_option.dart';

class LocalTransitDatasource {
  /// Seeded DMRC Metro Stations
  static const List<DmrcStationModel> dmrcStations = [
    DmrcStationModel(
      stationId: "dmrc_shaheed_sthal",
      stationName: "Shaheed Sthal (New Bus Adda)",
      lineName: "Red Line",
      lineColorHex: "#DC2626",
      latitude: 28.6715,
      longitude: 77.4121,
      isInterchange: false,
      gateNumbers: ["Gate 1 (Old Bus Stand)", "Gate 2 (GT Road)", "Gate 3 (Auto Hub)"],
    ),
    DmrcStationModel(
      stationId: "dmrc_rajiv_chowk",
      stationName: "Rajiv Chowk (Connaught Place)",
      lineName: "Yellow / Blue Line",
      lineColorHex: "#2563EB",
      latitude: 28.6328,
      longitude: 77.2197,
      isInterchange: true,
      interchangeLines: ["Yellow Line", "Blue Line"],
      gateNumbers: ["Gate 1 (Radial Rd 1)", "Gate 2 (Inner Circle)", "Gate 3 (PVR Plaza)", "Gate 5 (Palika Bazaar)"],
    ),
    DmrcStationModel(
      stationId: "dmrc_kashmere_gate",
      stationName: "Kashmere Gate ISBT",
      lineName: "Red / Yellow / Violet Line",
      lineColorHex: "#DC2626",
      latitude: 28.6675,
      longitude: 77.2285,
      isInterchange: true,
      interchangeLines: ["Red Line", "Yellow Line", "Violet Line"],
      gateNumbers: ["Gate 1 (ISBT Bus Terminal)", "Gate 2 (Lothian Road)", "Gate 7 (Yamuna Bazaar)"],
    ),
    DmrcStationModel(
      stationId: "dmrc_anand_vihar",
      stationName: "Anand Vihar ISBT & Railway Station",
      lineName: "Blue Line / Pink Line",
      lineColorHex: "#2563EB",
      latitude: 28.6469,
      longitude: 77.3160,
      isInterchange: true,
      interchangeLines: ["Blue Line", "Pink Line"],
      gateNumbers: ["Gate 1 (Railway Station)", "Gate 2 (ISBT Bus Stand)"],
    ),
  ];

  /// Seeded Local Auto & E-Rickshaw Hubs
  static const List<TransitHub> autoAndERickshawHubs = [
    TransitHub(
      id: "hub_ghaziabad_auto_stand",
      name: "Old Bus Stand Auto Hub",
      type: TransitHubType.autoStand,
      latitude: 28.6700,
      longitude: 77.4100,
      supportedModes: [TransportMode.auto, TransportMode.eRickshaw, TransportMode.sharedAuto],
      primaryGate: "Near Ghaziabad Railway Station Road",
      operatingHours: "24x7",
      isSharedAvailable: true,
    ),
    TransitHub(
      id: "hub_rajiv_chowk_auto_stand",
      name: "Connaught Place Gate 5 Auto & Cab Stand",
      type: TransitHubType.autoStand,
      latitude: 28.6335,
      longitude: 77.2205,
      supportedModes: [TransportMode.auto, TransportMode.cab],
      primaryGate: "Exit Gate 5, Palika Concourse",
      operatingHours: "06:00 AM - 11:30 PM",
      isSharedAvailable: false,
    ),
  ];
}
