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
}
