import 'package:sporify/domain/usecases/usecase.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/domain/repository/spotify/spotify_repository.dart';
import 'package:sporify/core/di/service_locator.dart';

class SearchSpotifyArtistsUseCase
    implements UseCase<List<SpotifyArtistEntity>, String> {
  @override
  Future<List<SpotifyArtistEntity>> call({String? params}) async {
    return sl<SpotifyRepository>().searchArtists(params!);
  }
}
