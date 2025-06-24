import 'package:sporify/domain/entities/spotify/spotify_artist.dart';

abstract class SpotifyPopularArtistsState {}

class SpotifyPopularArtistsInitial extends SpotifyPopularArtistsState {}

class SpotifyPopularArtistsLoading extends SpotifyPopularArtistsState {}

class SpotifyPopularArtistsLoaded extends SpotifyPopularArtistsState {
  final List<SpotifyArtistEntity> artists;
  SpotifyPopularArtistsLoaded(this.artists);
}

class SpotifyPopularArtistsError extends SpotifyPopularArtistsState {
  final String message;
  SpotifyPopularArtistsError(this.message);
}
