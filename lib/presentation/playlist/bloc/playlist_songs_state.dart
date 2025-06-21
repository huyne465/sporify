import 'package:sporify/domain/entities/songs/song.dart';

abstract class PlaylistSongsState {}

class PlaylistSongsLoading extends PlaylistSongsState {}

class PlaylistSongsLoaded extends PlaylistSongsState {
  final List<SongEntity> songs;
  PlaylistSongsLoaded(this.songs);
}

class PlaylistSongsError extends PlaylistSongsState {
  final String message;
  PlaylistSongsError(this.message);
}
