import '../../../core/error/app_exception.dart';

class LocationFailure extends AppException {
  const LocationFailure(this.kind, {String? code, String message = ''})
    : super(message, code: code);

  final LocationFailureKind kind;

  factory LocationFailure.permissionDenied() {
    return const LocationFailure(
      LocationFailureKind.permissionDenied,
      message: 'Location permission was denied.',
    );
  }

  factory LocationFailure.gpsDisabled() {
    return const LocationFailure(
      LocationFailureKind.gpsDisabled,
      message: 'GPS is disabled.',
    );
  }

  factory LocationFailure.networkError() {
    return const LocationFailure(
      LocationFailureKind.networkError,
      message: 'Network error while loading location data.',
    );
  }

  factory LocationFailure.unknown({
    String message = 'Unable to determine your location.',
  }) {
    return LocationFailure(LocationFailureKind.unknown, message: message);
  }
}

enum LocationFailureKind {
  permissionDenied,
  gpsDisabled,
  networkError,
  unknown,
}
