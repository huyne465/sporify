class LyricsEntity {
  final int id;
  final String trackName;
  final String artistName;
  final String? albumName;
  final int duration;
  final bool instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  LyricsEntity({
    required this.id,
    required this.trackName,
    required this.artistName,
    this.albumName,
    required this.duration,
    required this.instrumental,
    this.plainLyrics,
    this.syncedLyrics,
  });
}

class LyricsLine {
  final Duration timestamp;
  final String text;

  LyricsLine({required this.timestamp, required this.text});
}
