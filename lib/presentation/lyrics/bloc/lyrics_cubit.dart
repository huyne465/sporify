import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/entities/lyrics/lyrics.dart';
import 'package:sporify/domain/usecases/lyrics/get_lyrics.dart';
import 'package:sporify/presentation/lyrics/bloc/lyrics_state.dart';
import 'package:sporify/core/di/service_locator.dart';

class LyricsCubit extends Cubit<LyricsState> {
  LyricsCubit() : super(LyricsLoading());

  Future<void> getLyrics(String artist, String track) async {
    emit(LyricsLoading());

    try {
      final result = await sl<GetLyricsUseCase>().call(
        params: GetLyricsParams(artist: artist, track: track),
      );

      result.fold((failure) => emit(LyricsFailure(failure)), (lyrics) {
        if (lyrics == null) {
          emit(LyricsNotFound());
        } else {
          final lyricsLines = _parseSyncedLyrics(lyrics.syncedLyrics);
          emit(LyricsLoaded(lyrics: lyrics, lyricsLines: lyricsLines));
        }
      });
    } catch (e) {
      emit(LyricsFailure(e.toString()));
    }
  }

  void updateCurrentLine(Duration position) {
    if (state is LyricsLoaded) {
      final currentState = state as LyricsLoaded;
      final currentIndex = _findCurrentLineIndex(
        currentState.lyricsLines,
        position,
      );

      if (currentIndex != currentState.currentLineIndex) {
        emit(currentState.copyWith(currentLineIndex: currentIndex));
      }
    }
  }

  List<LyricsLine> _parseSyncedLyrics(String? syncedLyrics) {
    if (syncedLyrics == null || syncedLyrics.isEmpty) return [];

    final lines = <LyricsLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2}\.\d{2})\] (.*)');

    for (final line in syncedLyrics.split('\n')) {
      final match = regex.firstMatch(line.trim());
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = double.parse(match.group(2)!);
        final text = match.group(3)!;

        final timestamp = Duration(
          minutes: minutes,
          milliseconds: (seconds * 1000).round(),
        );

        lines.add(LyricsLine(timestamp: timestamp, text: text));
      }
    }

    return lines;
  }

  int _findCurrentLineIndex(List<LyricsLine> lines, Duration position) {
    for (int i = lines.length - 1; i >= 0; i--) {
      if (position >= lines[i].timestamp) {
        return i;
      }
    }
    return -1;
  }
}
