import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/domain/repository/spotify/spotify_repository.dart';
import 'package:sporify/di/service_locator.dart';

class GetSpotifyArtistTopTracksUseCase
    implements UseCase<List<SpotifyTrackEntity>, String> {
  @override
  Future<List<SpotifyTrackEntity>> call({String? params}) async {
    return sl<SpotifyRepository>().getArtistTopTracks(params!);
  }
}
