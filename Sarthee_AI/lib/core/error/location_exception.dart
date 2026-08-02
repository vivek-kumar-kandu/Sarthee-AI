import 'app_exception.dart';

class LocationException extends AppException {
  const LocationException(super.message, {super.code, super.retryable = false});

  factory LocationException.permissionDenied([
    String message = 'Location permission was denied.',
  ]) {
    return LocationException(message, retryable: false);
  }

  factory LocationException.serviceDisabled([
    String message = 'Location services are disabled.',
  ]) {
    return LocationException(message, retryable: false);
  }

  factory LocationException.timeout([
    String message = 'Location request timed out.',
  ]) {
    return LocationException(message, retryable: true);
  }

  factory LocationException.unknown([
    String message = 'Unable to determine location.',
  ]) {
    return LocationException(message, retryable: true);
  }

  @override
  String toString() => message;
}
