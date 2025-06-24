import 'package:sporify/domain/entities/spotify/spotify_artist.dart';

abstract class SpotifyArtistState {}

class SpotifyArtistInitial extends SpotifyArtistState {}

class SpotifyArtistLoading extends SpotifyArtistState {}

class SpotifyArtistTopTracksLoaded extends SpotifyArtistState {
  final List<SpotifyTrackEntity> tracks;

  SpotifyArtistTopTracksLoaded({required this.tracks});
}

class SpotifyPopularArtistsLoaded extends SpotifyArtistState {
  final List<SpotifyArtistEntity> artists;

  SpotifyPopularArtistsLoaded({required this.artists});
}

class SpotifyArtistError extends SpotifyArtistState {
  final String message;

  SpotifyArtistError({required this.message});
}
