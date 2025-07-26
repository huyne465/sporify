import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sporify/presentation/song_player/bloc/song_player_state.dart';

class SongPlayerCubit extends HydratedCubit<SongPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  String? currentSongUrl;

  SongPlayerCubit() : super(SongPlayerLoading()) {
    // Listen to player state changes with error handling
    audioPlayer.playerStateStream.listen(
      (playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          audioPlayer.seek(Duration.zero);
          audioPlayer.pause();
        }
      },
      onError: (error) {
        print('🔊 Player state stream error: $error');
        emit(SongPlayerFailure());
      },
    );

    // Listen to duration changes
    audioPlayer.durationStream.listen(
      (updatedDuration) {
        if (updatedDuration != null) {
          songDuration = updatedDuration;
          emit(SongPlayerLoaded());
        }
      },
      onError: (error) {
        print('🔊 Duration stream error: $error');
      },
    );

    // Listen to position changes
    audioPlayer.positionStream.listen(
      (updatedPosition) {
        songPosition = updatedPosition;
        emit(SongPlayerLoaded());
      },
      onError: (error) {
        print('🔊 Position stream error: $error');
      },
    );
  }

  Future<void> loadSong(String? songUrl) async {
    if (songUrl == null || songUrl.isEmpty) {
      print('🔊 Empty song URL provided');
      emit(SongPlayerFailure());
      return;
    }

    // Skip YouTube Music URLs
    if (songUrl.startsWith('youtube:')) {
      print('🔊 YouTube Music URL detected, skipping: $songUrl');
      emit(SongPlayerFailure());
      return;
    }

    // Validate URL format
    if (!_isValidAudioUrl(songUrl)) {
      print('🔊 Invalid audio URL format: $songUrl');
      emit(SongPlayerFailure());
      return;
    }

    if (currentSongUrl == songUrl) {
      if (songPosition > Duration.zero) {
        audioPlayer.seek(songPosition);
      }
      emit(SongPlayerLoaded());
      return;
    }

    // Stop current playback before loading new song
    try {
      await audioPlayer.stop();
    } catch (e) {
      print('🔊 Error stopping current playback: $e');
    }

    currentSongUrl = songUrl;
    emit(SongPlayerLoading());

    try {
      print('🔊 Loading song URL: $songUrl');

      // Use setAudioSource with better error handling
      await audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(songUrl)), preload: false)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception(
                'Song loading timeout - check network connection or audio format',
              );
            },
          );

      songDuration = audioPlayer.duration ?? Duration.zero;
      print(
        '🔊 Song loaded successfully. Duration: ${songDuration.inSeconds}s',
      );
      emit(SongPlayerLoaded());
    } catch (e) {
      // More detailed error handling
      String errorMessage = 'Unknown error';

      if (e.toString().contains('timeout')) {
        errorMessage = 'Network timeout - check connection';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Audio file not found (404)';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied to audio file (403)';
      } else if (e.toString().contains('FormatException') ||
          e.toString().contains('IllegalArgumentException')) {
        errorMessage = 'Unsupported audio format';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('HttpException')) {
        errorMessage = 'Network error loading audio';
      } else if (e.toString().contains('Invalid')) {
        errorMessage = 'Invalid audio URL or corrupted file';
      }

      print('🔊 Error loading song: $errorMessage');
      print('🔊 Full error: ${e.toString()}');
      print('🔊 Failed URL: $songUrl');
      emit(SongPlayerFailure());
    }
  }

  // URL validation helper
  bool _isValidAudioUrl(String url) {
    if (url.isEmpty) return false;

    // Check if it's a valid HTTP/HTTPS URL
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme ||
          (!url.startsWith('http://') && !url.startsWith('https://'))) {
        return false;
      }
    } catch (e) {
      return false;
    }

    // Check for supported audio formats or Firebase Storage
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('firebasestorage.googleapis.com') ||
        lowerUrl.contains('.mp3') ||
        lowerUrl.contains('.wav') ||
        lowerUrl.contains('.m4a') ||
        lowerUrl.contains('.aac') ||
        lowerUrl.contains('.ogg') ||
        lowerUrl.contains('.flac') ||
        lowerUrl.contains('.wma');
  }

  void playOrPauseSong() {
    try {
      if (audioPlayer.playing) {
        audioPlayer.pause();
      } else {
        audioPlayer.play();
      }
      emit(SongPlayerLoaded());
    } catch (e) {
      print('🔊 Error in play/pause: $e');
      emit(SongPlayerFailure());
    }
  }

  void seekTo(Duration position) {
    try {
      audioPlayer.seek(position);
      songPosition = position;
      emit(SongPlayerLoaded());
    } catch (e) {
      print('🔊 Error seeking: $e');
    }
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
