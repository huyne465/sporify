import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/domain/repository/spotify/spotify_repository.dart';
import 'package:sporify/service_locator.dart';

class GetPopularAlbumsUseCase
    implements UseCase<List<SpotifyAlbumEntity>, void> {
  @override
  Future<List<SpotifyAlbumEntity>> call({void params}) async {
    // Lấy albums từ các artist phổ biến
    const popularArtistIds = [
      '66CXWjxzNUsdJxJ2JdwvnR', // Ariana Grande
      '06HL4z0CvFAx86XM2NjONE', // Taylor Swift
      '6eUKZXaKkcviH0Ku9w2n3V', // Ed Sheeran
      '6qqNVTkY8uBg9cP3Jd7DAH', // Billie Eilish
    ];

    List<SpotifyAlbumEntity> allAlbums = [];

    for (String artistId in popularArtistIds) {
      try {
        final albums = await sl<SpotifyRepository>().getArtistAlbums(artistId);
        allAlbums.addAll(albums.take(2)); // Lấy 2 album từ mỗi artist
      } catch (e) {
        print('Error getting albums for $artistId: $e');
      }
    }

    return allAlbums.take(8).toList(); // Trả về tối đa 8 albums
  }
}
