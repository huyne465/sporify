import 'package:sporify/domain/entities/songs/song.dart';

class GlobalMusicPlayerState {
  final SongEntity? currentSong;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isLoading;
  final List<SongEntity> playlist;

  GlobalMusicPlayerState({
    this.currentSong,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isLoading = false,
    this.playlist = const [],
  });

  GlobalMusicPlayerState copyWith({
    SongEntity? currentSong,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isLoading,
    List<SongEntity>? playlist,
  }) {
    return GlobalMusicPlayerState(
      currentSong: currentSong ?? this.currentSong,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      playlist: playlist ?? this.playlist,
    );
  }
}
