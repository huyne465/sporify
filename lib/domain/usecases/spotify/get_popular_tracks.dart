import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/domain/repository/spotify/spotify_repository.dart';
import 'package:sporify/service_locator.dart';

// UseCase để lấy top tracks của một artist cụ thể
class GetArtistTopTracksUseCase
    implements UseCase<List<SpotifyTrackEntity>, String> {
  @override
  Future<List<SpotifyTrackEntity>> call({String? params}) async {
    return sl<SpotifyRepository>().getArtistTopTracks(params!);
  }
}

// UseCase để lấy popular tracks (có thể từ playlist hoặc API khác)
class GetPopularTracksUseCase
    implements UseCase<List<SpotifyTrackEntity>, void> {
  @override
  Future<List<SpotifyTrackEntity>> call({void params}) async {
<<<<<<< HEAD
    // Sử dụng Travis Scott's artist ID - artist có nhiều track phổ biến
=======
    // Sử dụng một artist ID mặc định hoặc playlist để lấy popular tracks
    // Ví dụ: Ariana Grande's top tracks
    // List of popular artist IDs for fetching their top tracks
    // These are some example Spotify artist IDs:
    // '66CXWjxzNUsdJxJ2JdwvnR' - Ariana Grande
    // '06HL4z0CvFAxyc27GXpf02' - Taylor Swift
    // '3TVXtAsR1Inumwj472S9r4' - Drake
    // '6eUKZXaKkcviH0Ku9w2n3V' - Ed Sheeran
    // '1uNFoZAHBGtllmzznpCI3s' - Justin Bieber
    // Using a single artist ID for now, but this could be expanded to fetch and combine
    // top tracks from multiple artists or use a curated playlist ID
    // List of Vietnamese artist IDs
    // '5V0MlUE3xdJFi5UfhoT2b8' - Low G (Vietnamese rapper)
    // You can also include other Vietnamese artists:
    // '1zFt2gGBH04JTZ5rdmHXWY' - Sơn Tùng M-TP
    // '0LyfQWJT6nXafLPZqxe9Of' - Suboi
    // const String defaultArtistId = '66CXWjxzNUsdJxJ2JdwvnR'; // Ariana Grande
    // const String defaultCountryCode = 'US'; // Default market for top tracks
>>>>>>> e0468694e348c49ecdc8bc81ba94b8f169e06cf2
    return sl<SpotifyRepository>().getArtistTopTracks('0Y5tJX1MQlPlqiwlOH1tJY');
  }
}
