import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_state.dart';

class GlobalMusicPlayerCubit extends HydratedCubit<GlobalMusicPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  List<SongEntity> playlist = [];
  int currentSongIndex = 0;

  GlobalMusicPlayerCubit() : super(GlobalMusicPlayerState()) {
    // Listen to player state changes
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        playNext();
      }
    });

    // Listen to duration changes
    audioPlayer.durationStream.listen((updatedDuration) {
      if (updatedDuration != null) {
        songDuration = updatedDuration;
        emit(state.copyWith(duration: updatedDuration));
      }
    });

    // Listen to position changes
    audioPlayer.positionStream.listen((updatedPosition) {
      songPosition = updatedPosition;
      emit(state.copyWith(position: updatedPosition));
    });
  }
  Future<void> loadSong(SongEntity song, {List<SongEntity>? songList}) async {
    if (songList != null) {
      playlist = songList;
      currentSongIndex = playlist.indexWhere((s) => s.songId == song.songId);
      if (currentSongIndex == -1) {
        playlist.insert(0, song);
        currentSongIndex = 0;
      }
    } else {
      // If no playlist provided, create a single-song playlist
      playlist = [song];
      currentSongIndex = 0;
    }

    emit(
      state.copyWith(currentSong: song, isLoading: true, playlist: playlist),
    );

    try {
      await audioPlayer.setUrl(song.songUrl);
      songDuration = audioPlayer.duration ?? Duration.zero;
      emit(state.copyWith(isLoading: false, duration: songDuration));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void playOrPause() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    emit(state.copyWith(isPlaying: audioPlayer.playing));
  }

  void playNext() {
    if (playlist.isNotEmpty && currentSongIndex < playlist.length - 1) {
      currentSongIndex++;
      loadSong(playlist[currentSongIndex]);
    }
  }

  void playPrevious() {
    if (playlist.isNotEmpty && currentSongIndex > 0) {
      currentSongIndex--;
      loadSong(playlist[currentSongIndex]);
    }
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
  }

  // Get current playlist info
  String get currentPlaylistInfo {
    if (playlist.isEmpty) return '';
    if (playlist.length == 1) return 'Single track';
    return 'Playlist • ${playlist.length} songs';
  }

  // Check if there are previous/next songs
  bool get hasPrevious => playlist.isNotEmpty && currentSongIndex > 0;
  bool get hasNext =>
      playlist.isNotEmpty && currentSongIndex < playlist.length - 1;

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }

  @override
  GlobalMusicPlayerState? fromJson(Map<String, dynamic> json) {
    try {
      return GlobalMusicPlayerState(
        currentSong: json['currentSong'] != null
            ? SongEntity(
                title: json['currentSong']['title'] ?? '',
                artist: json['currentSong']['artist'] ?? '',
                duration: json['currentSong']['duration'] ?? 0,
                releaseDate: json['currentSong']['releaseDate'],
                image: json['currentSong']['image'] ?? '',
                songUrl: json['currentSong']['songUrl'] ?? '',
                isFavorite: json['currentSong']['isFavorite'] ?? false,
                songId: json['currentSong']['songId'] ?? '',
              )
            : null,
        position: Duration(milliseconds: json['position'] ?? 0),
        duration: Duration(milliseconds: json['duration'] ?? 0),
        isPlaying: json['isPlaying'] ?? false,
      );
    } catch (_) {
      return GlobalMusicPlayerState();
    }
  }

  @override
  Map<String, dynamic>? toJson(GlobalMusicPlayerState state) {
    return {
      'currentSong': state.currentSong != null
          ? {
              'title': state.currentSong!.title,
              'artist': state.currentSong!.artist,
              'duration': state.currentSong!.duration,
              'image': state.currentSong!.image,
              'songUrl': state.currentSong!.songUrl,
              'isFavorite': state.currentSong!.isFavorite,
              'songId': state.currentSong!.songId,
            }
          : null,
      'position': state.position.inMilliseconds,
      'duration': state.duration.inMilliseconds,
      'isPlaying': state.isPlaying,
    };
  }
}
