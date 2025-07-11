import 'package:sporify/domain/entities/artist/artist.dart';

class ArtistModel {
  final String? id;
  final String? name;
  final String? imageUrl;
  final int? albums;
  final double? followers;
  final int? songs;
  final String? describe;

  ArtistModel({
    this.id,
    this.name,
    this.imageUrl,
    this.albums,
    this.followers,
    this.songs,
    this.describe,
  });

  factory ArtistModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ArtistModel(
      id: documentId,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      albums: data['albums'] ?? 0,
      followers: (data['followers'] ?? 0.0).toDouble(),
      songs: data['songs'] ?? 0,
      describe: data['describe'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'albums': albums,
      'followers': followers,
      'songs': songs,
      'describe': describe,
    };
  }
}

extension ArtistModelX on ArtistModel {
  ArtistEntity toEntity() {
    return ArtistEntity(
      id: id!,
      name: name!,
      imageUrl: imageUrl!,
      albums: albums!,
      followers: followers!,
      songs: songs!,
      describe: describe!,
    );
  }
}
