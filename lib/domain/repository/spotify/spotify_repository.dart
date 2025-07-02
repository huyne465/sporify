import 'package:sporify/domain/entities/spotify/spotify_artist.dart';

abstract class SpotifyRepository {
  Future<List<SpotifyArtistEntity>> searchArtists(String query);
  Future<List<SpotifyTrackEntity>> getArtistTopTracks(String artistId);
  Future<SpotifyArtistEntity?> getArtist(String artistId);
  Future<List<SpotifyAlbumEntity>> getArtistAlbums(String artistId);
<<<<<<< HEAD
  Future<SpotifyTrackEntity> getTrack(String trackId);
=======
  Future<List<SpotifyAlbumEntity>> getSeveralAlbums(String popularAlbumIds);
>>>>>>> e0468694e348c49ecdc8bc81ba94b8f169e06cf2
}
