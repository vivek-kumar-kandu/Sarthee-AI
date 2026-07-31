class Landmark {
  final String name;
  final String type; // e.g. "shop", "transit", "amenity"
  final int distanceMeters;
  final String landmarkTip;

  const Landmark({
    required this.name,
    required this.type,
    required this.distanceMeters,
    required this.landmarkTip,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      name: json['name'] as String? ?? 'Landmark',
      type: json['type'] as String? ?? 'amenity',
      distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
      landmarkTip: json['landmarkTip'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'distanceMeters': distanceMeters,
      'landmarkTip': landmarkTip,
    };
  }
}
