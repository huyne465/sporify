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
  String? album;
  String? genre;
  String? platform;
  String? addedBy;
  Timestamp? addedAt;
  int? fileSize;

  SongModel({
    required this.title,
    required this.artist,
    required this.duration,
    required this.releaseDate,
    required this.image,
    required this.songUrl,
    required this.isFavorite,
    required this.songId,
    this.album,
    this.genre,
    this.platform,
    this.addedBy,
    this.addedAt,
    this.fileSize,
  });

  SongModel.fromJson(Map<String, dynamic> data) {
    title = data['title'];
    artist = data['artist'];
    duration = data['duration'];
    releaseDate = data['releaseDate'];
    image = data['image'];
    songUrl = data['songUrl'];
    isFavorite = data['isFavorite'];
    songId = data['songId'];
    album = data['album'];
    genre = data['genre'];
    platform = data['platform'];
    addedBy = data['addedBy'];
    addedAt = data['addedAt'];
    fileSize = data['fileSize'];
  }

  factory SongModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SongModel(
      title: data['title'],
      artist: data['artist'],
      duration: data['duration']?.toDouble(),
      releaseDate: data['releaseDate'],
      image: data['image'],
      songUrl: data['songUrl'],
      isFavorite: data['isFavorite'] ?? false,
      songId: doc.id,
      album: data['album'],
      genre: data['genre'],
      platform: data['platform'],
      addedBy: data['addedBy'],
      addedAt: data['addedAt'],
      fileSize: data['fileSize'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'artist': artist,
      'duration': duration,
      'releaseDate': releaseDate,
      'image': image,
      'songUrl': songUrl,
      'isFavorite': isFavorite,
      'songId': songId,
      'album': album,
      'genre': genre,
      'platform': platform,
      'addedBy': addedBy,
      'addedAt': addedAt,
      'fileSize': fileSize,
    };
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
      album: album,
      genre: genre,
      platform: platform,
      addedBy: addedBy,
      addedAt: addedAt,
      fileSize: fileSize,
    );
  }
}
