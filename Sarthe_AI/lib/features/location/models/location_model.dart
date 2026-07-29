class LocationModel {
  const LocationModel({
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.country,
    this.address,
    this.postalCode,
    this.timezone,
    this.accuracy,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? country;
  final String? address;
  final String? postalCode;
  final String? timezone;
  final double? accuracy;
  final DateTime? timestamp;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      address: json['address']?.toString(),
      postalCode: json['postalCode']?.toString(),
      timezone: json['timezone']?.toString(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      timestamp: json['timestamp'] is String
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
      'address': address,
      'postalCode': postalCode,
      'timezone': timezone,
      'accuracy': accuracy,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? country,
    String? address,
    String? postalCode,
    String? timezone,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      timezone: timezone ?? this.timezone,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
