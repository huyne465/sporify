import 'package:sporify/domain/entities/spotify/spotify_artist.dart';

abstract class SpotifyRepository {
  Future<List<SpotifyArtistEntity>> searchArtists(String query);
  Future<SpotifyArtistEntity?> getArtist(String artistId);
  Future<List<SpotifyTrackEntity>> getArtistTopTracks(String artistId);
  Future<List<SpotifyAlbumEntity>> getArtistAlbums(String artistId);
}
