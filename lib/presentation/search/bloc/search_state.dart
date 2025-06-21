import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<SongEntity> songs;
  final String query;

  SearchLoaded({required this.songs, required this.query});
}

class SearchSpotifyArtistsLoaded extends SearchState {
  final List<SpotifyArtistEntity> artists;
  final String query;

  SearchSpotifyArtistsLoaded({required this.artists, required this.query});
}

class SearchEmpty extends SearchState {
  final String query;

  SearchEmpty({required this.query});
}

class SearchFailure extends SearchState {
  final String message;

  SearchFailure({required this.message});
}
