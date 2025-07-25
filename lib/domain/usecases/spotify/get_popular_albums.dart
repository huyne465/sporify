import 'package:sporify/domain/usecases/usecase.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/domain/repository/spotify/spotify_repository.dart';
import 'package:sporify/core/di/service_locator.dart';

class GetPopularAlbumsUseCase
    implements UseCase<List<SpotifyAlbumEntity>, void> {
  final List<String> popularArtistIds = [
    '6eUKZXaKkcviH0Ku9w2n3V', // Ed Sheeran
    '0du5cEVh5yTK9QJze8zA0C', // Bruno Mars
    '246dkjvS1zLTtiykXe5h60', // Post Malone
    '66CXWjxzNUsdJxJ2JdwvnR', // Ariana Grande
    '3TVXtAsR1Inumwj472S9r4', // Drake
    '06HL4z0CvFAxyc27GXpf02', // Taylor Swift
    '1uNFoZAHBGtllmzznpCI3s', // Justin Bieber
    '4q3ewBCX7sLwd24euuV69X', // Bad Bunny
    '0Y5tJX1MQlPlqiwlOH1tJY', // Travis Scott
  ];

  @override
  Future<List<SpotifyAlbumEntity>> call({void params}) async {
    final List<SpotifyAlbumEntity> allAlbums = [];

    // Lấy albums từ một số artists phổ biến
    final random = popularArtistIds..shuffle();
    final selectedArtists = random.take(5).toList(); // Lấy ngẫu nhiên 3 artists

    for (final artistId in selectedArtists) {
      final albums = await sl<SpotifyRepository>().getArtistAlbums(artistId);
      allAlbums.addAll(albums);
    }

    return allAlbums;
  }
}
