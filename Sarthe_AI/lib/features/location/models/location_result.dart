import 'location_failure.dart';

abstract class LocationResult<T> {
  const LocationResult();

  bool get isSuccess;

  T? get value;

  LocationFailure? get failure;
}

class LocationSuccess<T> extends LocationResult<T> {
  const LocationSuccess(this.value);

  @override
  final T value;

  @override
  bool get isSuccess => true;

  @override
  LocationFailure? get failure => null;
}

class LocationFailureResult<T> extends LocationResult<T> {
  const LocationFailureResult(this.failure);

  @override
  final LocationFailure? failure;

  @override
  bool get isSuccess => false;

  @override
  T? get value => null;
}
