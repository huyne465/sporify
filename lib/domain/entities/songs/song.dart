import 'package:cloud_firestore/cloud_firestore.dart';

class SongEntity {
  final String title;
  final String artist;
  final double duration;
  final Timestamp releaseDate;
  final String image;
  final String songUrl;
  final bool isFavorite;
  final String songId;
  final String? album;
  final String? genre;
  final String? platform;
  final String? addedBy;
  final Timestamp? addedAt;
  final int? fileSize;

  SongEntity({
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
}
