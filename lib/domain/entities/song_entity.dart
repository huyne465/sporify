class SongEntity {
  final String id;
  final String title;
  final String artist;
  final String? albumArt;
  final String? audioUrl;
  final bool isFavorite;
  final DateTime? addedAt;

  const SongEntity({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArt,
    this.audioUrl,
    this.isFavorite = false,
    this.addedAt,
  });
}
