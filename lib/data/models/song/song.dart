import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sporify/domain/entities/songs/song.dart';

class SongModel {
  String? title;
  String? artist;
  double? duration;
  Timestamp? releaseDate;
  String? image;
  String? songUrl;
  bool? isFavorite;
  String? songId;

  SongModel({
    required this.title,
    required this.artist,
    required this.duration,
    required this.releaseDate,
    required this.image,
    required this.songUrl,
    required this.isFavorite,
    required this.songId,
  });

  SongModel.fromJson(Map<String, dynamic> data) {
    title = data['title'];
    artist = data['artist'];
    duration = data['duration'];
    releaseDate = data['releaseDate'];
    image = data['image'];
    songUrl = data['songUrl'];
  }
}

extension SongModelx on SongModel {
  SongEntity toEntity() {
    return SongEntity(
      title: title!,
      artist: artist!,
      duration: duration!,
      releaseDate: releaseDate!,
      image: image!,
      songUrl: songUrl!,
      isFavorite: isFavorite!,
      songId: songId!,
    );
  }
}
