import 'package:sporify/data/sources/spotify/spotify_api_service.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/domain/repository/spotify/spotify_repository.dart';

class SpotifyRepositoryImpl extends SpotifyRepository {
  final SpotifyApiService spotifyApiService;

  SpotifyRepositoryImpl({required this.spotifyApiService});

  @override
  Future<List<SpotifyArtistEntity>> searchArtists(String query) async {
    final artistModels = await spotifyApiService.searchArtists(query);

    return artistModels
        .map(
          (model) => SpotifyArtistEntity(
            id: model.id,
            name: model.name,
            imageUrl: model.images.isNotEmpty ? model.images.first.url : '',
            followers: model.followers,
            genres: model.genres,
            spotifyUrl: model.spotifyUrl,
          ),
        )
        .toList();
  }

  @override
  Future<List<SpotifyTrackEntity>> getArtistTopTracks(String artistId) async {
    final trackModels = await spotifyApiService.getArtistTopTracks(artistId);

    return trackModels
        .map(
          (model) => SpotifyTrackEntity(
            id: model.id,
            name: model.name,
            artists: model.artists,
            albumName: model.album.name,
            albumImageUrl: model.album.images.isNotEmpty
                ? model.album.images.first.url
                : '',
            previewUrl: model.previewUrl,
            spotifyUrl: model.spotifyUrl,
          ),
        )
        .toList();
  }

  @override
  Future<SpotifyArtistEntity?> getArtist(String artistId) async {
    // Implementation for getting a single artist
    throw UnimplementedError();
  }

  @override
  Future<List<SpotifyAlbumEntity>> getArtistAlbums(String artistId) {
    // TODO: implement getArtistAlbums
    throw UnimplementedError();
  }
}
