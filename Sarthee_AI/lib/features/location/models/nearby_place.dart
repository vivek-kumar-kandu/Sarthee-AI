class NearbyPlace {
  const NearbyPlace({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.rating,
    this.openingHours,
    this.tags = const <String>[],
  });

  final String id;
  final String name;
  final String category;
  final String? description;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final double? distance;
  final double? rating;
  final String? openingHours;
  final List<String> tags;

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    return NearbyPlace(
      id: json['id'] as String? ?? json['name'] as String? ?? 'poi_${json['lat']}_${json['lng']}',
      name: json['name'] as String? ?? 'Nearby Point of Interest',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? json['address'] as String?,
      imageUrl: json['imageUrl'] as String?,
      latitude: (json['lat'] ?? json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['lng'] ?? json['longitude'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distanceMeters'] ?? json['distance'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      openingHours: json['openingHours'] as String? ?? 'Open daily',
      tags: json['tags'] is List
          ? (json['tags'] as List).map((e) => e.toString()).toList()
          : const <String>[],
    );
  }
}
