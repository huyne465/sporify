import 'package:sporify/domain/usecases/usecase.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/domain/repository/spotify/spotify_repository.dart';
import 'package:sporify/core/di/service_locator.dart';

class GetPopularArtistsUseCase
    implements UseCase<List<SpotifyArtistEntity>, void> {
  @override
  Future<List<SpotifyArtistEntity>> call({void params}) async {
    // Tìm kiếm các artist phổ biến
    const popularArtistQueries = [
      'Ariana Grande',
      'Taylor Swift',
      'Ed Sheeran',
      'Billie Eilish',
      'The Weeknd',
      'Drake',
      'Travis Scott',
      'Low G',
      'Đen',
      'Sơn Tùng M-TP',
    ];

    List<SpotifyArtistEntity> allArtists = [];

    for (String query in popularArtistQueries) {
      try {
        final artists = await sl<SpotifyRepository>().searchArtists(query);
        if (artists.isNotEmpty) {
          allArtists.add(artists.first);
        }
      } catch (e) {
        print('Error searching for $query: $e');
      }
    }

    return allArtists;
  }
}
