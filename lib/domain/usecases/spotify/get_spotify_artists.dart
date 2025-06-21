import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/domain/repository/spotify/spotify_repository.dart';
import 'package:sporify/service_locator.dart';

class GetSpotifyArtistsUseCase
    extends UseCase<List<SpotifyArtistEntity>, List<String>> {
  @override
  Future<List<SpotifyArtistEntity>> call({List<String>? params}) async {
    if (params == null || params.isEmpty) return [];

    final List<SpotifyArtistEntity> artists = [];

    for (String artistId in params) {
      try {
        final artist = await sl<SpotifyRepository>().getArtist(artistId);
        if (artist != null) {
          artists.add(artist);
        }
      } catch (e) {
        // Continue with other artists if one fails
        print('Failed to get artist $artistId: $e');
      }
    }

    return artists;
  }
}
