import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/usecases/song/get_new_songs.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_state.dart';
import 'package:sporify/service_locator.dart';

class GlobalMusicPlayerCubit extends HydratedCubit<GlobalMusicPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  List<SongEntity> playlist = [];
  List<SongEntity> allSongs = [];
  int currentSongIndex = 0;
  bool isPlaylistMode = false;
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

    // Load all songs for random play
    _loadAllSongs();
  }

  Future<void> _loadAllSongs() async {
    try {
      final result = await sl<GetNewSongsUseCase>().call();
      result.fold((failure) => {}, (songs) => allSongs = songs);
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> loadSong(SongEntity song, {List<SongEntity>? songList}) async {
    if (songList != null) {
      // Playlist mode: play in order
      playlist = songList;
      currentSongIndex = playlist.indexWhere((s) => s.songId == song.songId);
      if (currentSongIndex == -1) {
        playlist.insert(0, song);
        currentSongIndex = 0;
      }
      isPlaylistMode = true;
    } else {
      // Random mode: create playlist with current song + shuffled other songs
      playlist = [song];
      currentSongIndex = 0;
      isPlaylistMode = false;

      // Add other random songs to the playlist for continuous play
      if (allSongs.isNotEmpty) {
        final otherSongs = allSongs
            .where((s) => s.songId != song.songId)
            .toList();
        otherSongs.shuffle();
        playlist.addAll(otherSongs);
      }
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
      final nextSong = playlist[currentSongIndex];
      _loadSongAtIndex(nextSong);
    } else if (playlist.isNotEmpty && !isPlaylistMode) {
      // For random mode, if we've reached the end, shuffle and continue
      if (allSongs.isNotEmpty) {
        final currentSong = playlist[currentSongIndex];
        final otherSongs = allSongs
            .where((s) => s.songId != currentSong.songId)
            .toList();
        otherSongs.shuffle();

        playlist = [currentSong, ...otherSongs];
        currentSongIndex = 1; // Move to first shuffled song

        final nextSong = playlist[currentSongIndex];
        _loadSongAtIndex(nextSong);
      }
    }
  }

  void playPrevious() {
    if (playlist.isNotEmpty && currentSongIndex > 0) {
      currentSongIndex--;
      final previousSong = playlist[currentSongIndex];
      _loadSongAtIndex(previousSong);
    }
  }

  Future<void> _loadSongAtIndex(SongEntity song) async {
    emit(state.copyWith(currentSong: song, isLoading: true));

    try {
      await audioPlayer.setUrl(song.songUrl);
      songDuration = audioPlayer.duration ?? Duration.zero;
      emit(state.copyWith(isLoading: false, duration: songDuration));

      // Auto play the next song
      audioPlayer.play();
      emit(state.copyWith(isPlaying: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
  }

  // Get current playlist info
  String get currentPlaylistInfo {
    if (playlist.isEmpty) return '';
    if (isPlaylistMode) {
      return 'Playlist • ${playlist.length} songs';
    } else {
      return 'Random play • Endless queue';
    }
  }

  // Check if there are previous/next songs
  bool get hasPrevious => playlist.isNotEmpty && currentSongIndex > 0;
  bool get hasNext =>
      playlist.isNotEmpty &&
      (currentSongIndex < playlist.length - 1 || !isPlaylistMode);

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
