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
    // Sử dụng một artist ID mặc định hoặc playlist để lấy popular tracks
    // Ví dụ: Ariana Grande's top tracks
    return sl<SpotifyRepository>().getArtistTopTracks('66CXWjxzNUsdJxJ2JdwvnR');
  }
}
