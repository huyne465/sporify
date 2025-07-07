import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/domain/repository/spotify/spotify_repository.dart';
import 'package:sporify/di/service_locator.dart';

class GetTrackWithPreviewUseCase
    implements UseCase<SpotifyTrackEntity, String> {
  @override
  Future<SpotifyTrackEntity> call({String? params}) async {
    if (params == null || params.isEmpty) {
      throw Exception('Track ID is required');
    }
    return sl<SpotifyRepository>().getTrack(params);
  }
}
