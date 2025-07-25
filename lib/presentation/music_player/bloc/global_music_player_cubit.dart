import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/usecases/song/get_new_songs.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_state.dart';
import 'package:sporify/core/di/service_locator.dart';
import 'package:sporify/core/services/audio_service_checker.dart';

class GlobalMusicPlayerCubit extends HydratedCubit<GlobalMusicPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  List<SongEntity> playlist = [];
  List<SongEntity> allSongs = [];
  int currentSongIndex = 0;
  bool isPlaylistMode = false;
  String currentPlaylistName = '';

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

    // Run audio diagnostics on real devices
    _runAudioDiagnostics();
  }

  Future<void> _runAudioDiagnostics() async {
    try {
      final diagnostics = await AudioServiceChecker.checkAudioCapabilities();
      AudioServiceChecker.printAudioDiagnostics(diagnostics);
    } catch (e) {
      print('🔊 Failed to run audio diagnostics: $e');
    }
  }

  Future<void> _loadAllSongs() async {
    try {
      final result = await sl<GetNewSongsUseCase>().call();
      result.fold((failure) => {}, (songs) => allSongs = songs);
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> loadSong(
    SongEntity song, {
    List<SongEntity>? songList,
    String? playlistName,
  }) async {
    if (songList != null) {
      playlist = songList;
      currentSongIndex = playlist.indexWhere((s) => s.songId == song.songId);
      if (currentSongIndex == -1) {
        playlist.insert(0, song);
        currentSongIndex = 0;
      }
      isPlaylistMode = true;
      currentPlaylistName = playlistName ?? 'Custom Playlist';
    } else {
      playlist = [song];
      currentSongIndex = 0;
      isPlaylistMode = false;
      currentPlaylistName = '';

      if (allSongs.isNotEmpty) {
        final otherSongs = allSongs
            .where((s) => s.songId != song.songId)
            .toList();
        otherSongs.shuffle();
        playlist.addAll(otherSongs.take(50));
      }
    }

    emit(
      state.copyWith(currentSong: song, isLoading: true, playlist: playlist),
    );

    try {
      String audioUrl = song.songUrl;

      // Handle YouTube Music URLs
      if (song.songUrl.startsWith('youtube:')) {
        final videoId = song.songUrl.replaceFirst('youtube:', '');
        print('YouTube Music video ID: $videoId');

        // Try to construct a direct Firebase Storage URL if available
        // This assumes there might be corresponding audio files uploaded to Firebase Storage
        print('Note: YouTube Music URL detected, attempting fallback...');

        // Skip YouTube URLs for now but don't throw an exception
        emit(state.copyWith(isLoading: false));
        print(
          'YouTube Music playback currently unavailable. Song: ${song.title}',
        );
        return;
      }

      // Validate URL format before attempting to load
      if (!_isValidAudioUrl(audioUrl)) {
        print('Invalid audio URL format: $audioUrl');
        emit(state.copyWith(isLoading: false));
        return;
      }

      // Add timeout and error handling for network audio loading
      await audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(audioUrl)), preload: false)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception(
                'Audio loading timeout - network issue or invalid URL',
              );
            },
          );

      songDuration = audioPlayer.duration ?? Duration.zero;
      emit(state.copyWith(isLoading: false, duration: songDuration));
    } catch (e) {
      String errorMessage = 'Failed to load audio';

      if (e.toString().contains('YouTube Music')) {
        errorMessage = 'YouTube Music songs require special handling';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Network timeout - check your connection';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Audio file not found (404)';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied to audio file (403)';
      } else if (e.toString().contains('Invalid')) {
        errorMessage = 'Invalid audio format or URL';
      } else if (e.toString().contains('Unable to load asset') ||
          e.toString().contains('HttpException')) {
        errorMessage =
            'Network error loading audio - check internet connection';
      } else if (e.toString().contains('FormatException') ||
          e.toString().contains('IllegalArgumentException')) {
        errorMessage = 'Unsupported audio format for this device';
      } else if (e.toString().contains('ExoPlayerImplInternal') ||
          e.toString().contains('DefaultAudioSink')) {
        errorMessage =
            'Audio decoder error - unsupported format or corrupted file';
      }

      emit(state.copyWith(isLoading: false));
      print('🔊 Audio loading error on real device: $errorMessage');
      print('🔊 Full error details: ${e.toString()}');
      print('🔊 Song URL: ${song.songUrl}');
      print('🔊 Song title: ${song.title}');
    }
  }

  Future<void> _loadSongAtIndex(SongEntity song) async {
    emit(state.copyWith(currentSong: song, isLoading: true));

    try {
      // Validate URL before loading
      if (!_isValidAudioUrl(song.songUrl)) {
        print('🔊 Invalid audio URL in playlist: ${song.songUrl}');
        emit(state.copyWith(isLoading: false));
        return;
      }

      await audioPlayer
          .setAudioSource(
            AudioSource.uri(Uri.parse(song.songUrl)),
            preload: false,
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Playlist audio loading timeout');
            },
          );

      songDuration = audioPlayer.duration ?? Duration.zero;
      emit(state.copyWith(isLoading: false, duration: songDuration));
    } catch (e) {
      print('🔊 Error loading playlist song: ${song.title} - ${e.toString()}');
      emit(state.copyWith(isLoading: false));

      // Auto-skip to next song if loading fails
      if (hasNext) {
        print('🔊 Auto-skipping to next song due to error...');
        Future.delayed(const Duration(seconds: 1), () => playNext());
      }
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
    if (playlist.isEmpty) return;

    if (isPlaylistMode) {
      // Playlist mode: play next song in order, loop if at end
      if (currentSongIndex < playlist.length - 1) {
        currentSongIndex++;
      } else {
        currentSongIndex = 0; // Loop back to first song
      }
      final nextSong = playlist[currentSongIndex];
      _loadSongAtIndex(nextSong);
    } else {
      // Random mode: continue with shuffled songs
      if (currentSongIndex < playlist.length - 1) {
        currentSongIndex++;
        final nextSong = playlist[currentSongIndex];
        _loadSongAtIndex(nextSong);
      } else {
        // Generate new random playlist when reaching end
        _generateNewRandomPlaylist();
      }
    }
  }

  void playPrevious() {
    if (playlist.isEmpty) return;

    if (isPlaylistMode) {
      // Playlist mode: play previous song in order
      if (currentSongIndex > 0) {
        currentSongIndex--;
      } else {
        currentSongIndex = playlist.length - 1; // Loop to last song
      }
      final previousSong = playlist[currentSongIndex];
      _loadSongAtIndex(previousSong);
    } else {
      // Random mode: go to previous song if available
      if (currentSongIndex > 0) {
        currentSongIndex--;
        final previousSong = playlist[currentSongIndex];
        _loadSongAtIndex(previousSong);
      }
    }
  }

  void _generateNewRandomPlaylist() {
    if (allSongs.isEmpty) return;

    final currentSong = playlist[currentSongIndex];
    final otherSongs = allSongs
        .where((s) => s.songId != currentSong.songId)
        .toList();
    otherSongs.shuffle();

    playlist = [currentSong, ...otherSongs.take(50)];
    currentSongIndex = 1; // Move to first shuffled song

    if (playlist.length > 1) {
      final nextSong = playlist[currentSongIndex];
      _loadSongAtIndex(nextSong);
    }
  }

  void exitPlaylistMode() {
    if (!isPlaylistMode) return;

    final currentSong = state.currentSong;
    if (currentSong == null) return;

    // Switch to random mode
    isPlaylistMode = false;
    currentPlaylistName = '';

    // Create new random playlist starting with current song
    playlist = [currentSong];
    currentSongIndex = 0;

    if (allSongs.isNotEmpty) {
      final otherSongs = allSongs
          .where((s) => s.songId != currentSong.songId)
          .toList();
      otherSongs.shuffle();
      playlist.addAll(otherSongs.take(50));
    }

    // Emit new state
    emit(state.copyWith(playlist: playlist));
  }

  void shuffleCurrentPlaylist() {
    if (playlist.isEmpty) return;

    final currentSong = state.currentSong;
    if (currentSong == null) return;

    if (isPlaylistMode) {
      // In playlist mode, shuffle the playlist but keep current song
      final otherSongs = playlist
          .where((s) => s.songId != currentSong.songId)
          .toList();
      otherSongs.shuffle();

      playlist = [currentSong, ...otherSongs];
      currentSongIndex = 0;
    } else {
      // In random mode, generate new random order
      _generateNewRandomPlaylist();
    }

    emit(state.copyWith(playlist: playlist));
  }

  // Get current playlist info
  String get currentPlaylistInfo {
    if (playlist.isEmpty) return '';
    if (isPlaylistMode) {
      return '$currentPlaylistName • ${playlist.length} songs';
    } else {
      return 'Random play • Endless queue';
    }
  }

  // Check if there are previous/next songs
  bool get hasPrevious {
    if (playlist.isEmpty) return false;
    return isPlaylistMode || currentSongIndex > 0;
  }

  bool get hasNext {
    if (playlist.isEmpty) return false;
    return isPlaylistMode ||
        currentSongIndex < playlist.length - 1 ||
        allSongs.isNotEmpty;
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
  }

  // URL validation helper method
  bool _isValidAudioUrl(String url) {
    if (url.isEmpty) return false;

    // Check if it's a valid HTTP/HTTPS URL
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }

    // Check if it's a Firebase Storage URL or has supported audio extensions
    if (url.contains('firebasestorage.googleapis.com') ||
        url.contains('.mp3') ||
        url.contains('.wav') ||
        url.contains('.m4a') ||
        url.contains('.aac') ||
        url.contains('.ogg') ||
        url.contains('.flac')) {
      return true;
    }

    // Allow other HTTP URLs but log them for debugging
    print(
      'Audio URL validation: Allowing URL without explicit audio extension: $url',
    );
    return true;
  }

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
