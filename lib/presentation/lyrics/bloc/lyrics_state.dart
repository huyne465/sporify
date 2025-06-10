import 'package:sporify/domain/entities/lyrics/lyrics.dart';

abstract class LyricsState {}

class LyricsLoading extends LyricsState {}

class LyricsLoaded extends LyricsState {
  final LyricsEntity lyrics;
  final List<LyricsLine> lyricsLines;
  final int currentLineIndex;

  LyricsLoaded({
    required this.lyrics,
    required this.lyricsLines,
    this.currentLineIndex = -1,
  });

  LyricsLoaded copyWith({
    LyricsEntity? lyrics,
    List<LyricsLine>? lyricsLines,
    int? currentLineIndex,
  }) {
    return LyricsLoaded(
      lyrics: lyrics ?? this.lyrics,
      lyricsLines: lyricsLines ?? this.lyricsLines,
      currentLineIndex: currentLineIndex ?? this.currentLineIndex,
    );
  }
}

class LyricsNotFound extends LyricsState {}

class LyricsFailure extends LyricsState {
  final String message;

  LyricsFailure(this.message);
}
