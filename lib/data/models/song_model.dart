import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sporify/domain/entities/song_entity.dart';

class SongModel extends SongEntity {
  const SongModel({
    required super.id,
    required super.title,
    required super.artist,
    super.albumArt,
    super.audioUrl,
    super.isFavorite,
    super.addedAt,
  });

  factory SongModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SongModel(
      id: doc.id,
      title: data['title'] ?? '',
      artist: data['artist'] ?? '',
      albumArt: data['albumArt'],
      audioUrl: data['audioUrl'],
      isFavorite: data['isFavorite'] ?? false,
      addedAt: data['addedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'audioUrl': audioUrl,
      'isFavorite': isFavorite,
      'addedAt': addedAt != null ? Timestamp.fromDate(addedAt!) : null,
    };
  }
}
