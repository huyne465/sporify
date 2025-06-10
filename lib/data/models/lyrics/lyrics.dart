import 'package:sporify/domain/entities/lyrics/lyrics.dart';

class LyricsModel {
  final int? id;
  final String? trackName;
  final String? artistName;
  final String? albumName;
  final int? duration;
  final bool? instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  LyricsModel({
    this.id,
    this.trackName,
    this.artistName,
    this.albumName,
    this.duration,
    this.instrumental,
    this.plainLyrics,
    this.syncedLyrics,
  });

  factory LyricsModel.fromJson(Map<String, dynamic> json) {
    return LyricsModel(
      id: _parseToInt(json['id']),
      trackName: json['trackName'] as String?,
      artistName: json['artistName'] as String?,
      albumName: json['albumName'] as String?,
      duration: _parseToInt(json['duration']),
      instrumental: json['instrumental'] as bool? ?? false,
      plainLyrics: json['plainLyrics'] as String?,
      syncedLyrics: json['syncedLyrics'] as String?,
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

extension LyricsModelX on LyricsModel {
  LyricsEntity toEntity() {
    return LyricsEntity(
      id: id ?? 0,
      trackName: trackName ?? '',
      artistName: artistName ?? '',
      albumName: albumName,
      duration: duration ?? 0,
      instrumental: instrumental ?? false,
      plainLyrics: plainLyrics,
      syncedLyrics: syncedLyrics,
    );
  }
}
