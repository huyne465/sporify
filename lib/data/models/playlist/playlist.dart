class PlaylistModel {
  final String id;
  final String name;
  final String description;
  final String coverImageUrl;
  final List<String> songIds;
  final String userId;
  final DateTime createdAt;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImageUrl,
    required this.songIds,
    required this.userId,
    required this.createdAt,
  });

  int get songCount => songIds.length;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'songIds': songIds,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  // Create from Map (Firestore data)
  factory PlaylistModel.fromMap(Map<String, dynamic> map, String id) {
    return PlaylistModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      songIds: List<String>.from(map['songIds'] ?? []),
      userId: map['userId'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    List<String>? songIds,
    String? userId,
    DateTime? createdAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      songIds: songIds ?? this.songIds,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
