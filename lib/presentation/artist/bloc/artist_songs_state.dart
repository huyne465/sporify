import 'package:sporify/domain/entities/songs/song.dart';

abstract class ArtistSongsState {}

class ArtistSongsLoading extends ArtistSongsState {}

class ArtistSongsLoaded extends ArtistSongsState {
  final List<SongEntity> songs;

  ArtistSongsLoaded(this.songs);
}

class ArtistSongsFailure extends ArtistSongsState {
  final String message;

  ArtistSongsFailure(this.message);
}
