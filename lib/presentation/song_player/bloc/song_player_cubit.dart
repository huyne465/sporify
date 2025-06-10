import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sporify/presentation/song_player/bloc/song_player_state.dart';

class SongPlayerCubit extends HydratedCubit<SongPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  String? currentSongUrl;

  SongPlayerCubit() : super(SongPlayerLoading()) {
    // Listen to player state changes
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        audioPlayer.seek(Duration.zero);
        audioPlayer.pause();
      }
    });

    // Listen to duration changes
    audioPlayer.durationStream.listen((updatedDuration) {
      if (updatedDuration != null) {
        songDuration = updatedDuration;
        emit(SongPlayerLoaded());
      }
    });

    // Listen to position changes
    audioPlayer.positionStream.listen((updatedPosition) {
      songPosition = updatedPosition;
      emit(SongPlayerLoaded());
    });
  }

  Future<void> LoadSong(String? songUrl) async {
    if (songUrl == null || songUrl.isEmpty) {
      emit(SongPlayerFailure());
      return;
    }

    // Check if we're loading the same song
    if (currentSongUrl == songUrl) {
      // Resume from saved position
      if (songPosition > Duration.zero) {
        audioPlayer.seek(songPosition);
      }
      emit(SongPlayerLoaded());
      return;
    }

    // If new song, load it
    currentSongUrl = songUrl;
    emit(SongPlayerLoading());

    try {
      await audioPlayer.setUrl(songUrl);
      songDuration = audioPlayer.duration ?? Duration.zero;
      emit(SongPlayerLoaded());
    } catch (e) {
      emit(SongPlayerFailure());
    }
  }

  void PlayOrPauseSong() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    emit(SongPlayerLoaded());
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }

  @override
  SongPlayerState? fromJson(Map<String, dynamic> json) {
    try {
      currentSongUrl = json['currentSongUrl'];
      // Fix: Ensure we handle both int and double types
      songPosition = Duration(
        milliseconds: (json['positionMillis'] ?? 0).toInt(),
      );
      songDuration = Duration(
        milliseconds: (json['durationMillis'] ?? 0).toInt(),
      );

      return SongPlayerLoaded();
    } catch (_) {
      return SongPlayerLoading();
    }
  }

  @override
  Map<String, dynamic>? toJson(SongPlayerState state) {
    if (state is SongPlayerLoaded) {
      return {
        'currentSongUrl': currentSongUrl,
        'positionMillis': songPosition.inMilliseconds,
        'durationMillis': songDuration.inMilliseconds,
      };
    }
    return null;
  }
}
