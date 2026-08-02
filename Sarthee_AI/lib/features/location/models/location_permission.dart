enum LocationPermissionStatus {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

class LocationPermissionState {
  const LocationPermissionState({
    this.status = LocationPermissionStatus.unknown,
    this.message,
  });

  final LocationPermissionStatus status;
  final String? message;

  bool get isGranted => status == LocationPermissionStatus.granted;
  bool get isDenied =>
      status == LocationPermissionStatus.denied ||
      status == LocationPermissionStatus.permanentlyDenied;
}
