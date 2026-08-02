class ProfileModel {
  const ProfileModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.language,
    this.travelInterests = const <String>[],
    this.favoriteCategories = const <String>[],
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? language;
  final List<String> travelInterests;
  final List<String> favoriteCategories;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uid: json['uid']?.toString() ?? '',
      email: json['email']?.toString(),
      displayName: json['displayName']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      language: json['language']?.toString(),
      travelInterests: _parseStringList(json['travelInterests']),
      favoriteCategories: _parseStringList(json['favoriteCategories']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'language': language,
      'travelInterests': travelInterests,
      'favoriteCategories': favoriteCategories,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }

    return <String>[];
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
