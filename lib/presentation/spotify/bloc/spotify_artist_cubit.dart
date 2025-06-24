import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/usecases/spotify/get_popular_artists.dart';
import 'package:sporify/domain/usecases/spotify/get_popular_tracks.dart';
import 'package:sporify/presentation/spotify/bloc/spotify_artist_state.dart';
import 'package:sporify/service_locator.dart';

class SpotifyArtistCubit extends Cubit<SpotifyArtistState> {
  SpotifyArtistCubit() : super(SpotifyArtistInitial());

  Future<void> getArtistTopTracks(String artistId) async {
    emit(SpotifyArtistLoading());

    try {
      final tracks = await sl<GetArtistTopTracksUseCase>().call(
        params: artistId,
      );

      emit(SpotifyArtistTopTracksLoaded(tracks: tracks));
    } catch (e) {
      emit(SpotifyArtistError(message: e.toString()));
    }
  }

  Future<void> getPopularArtists() async {
    emit(SpotifyArtistLoading());

    try {
      final artists = await sl<GetPopularArtistsUseCase>().call();

      emit(SpotifyPopularArtistsLoaded(artists: artists));
    } catch (e) {
      emit(SpotifyArtistError(message: e.toString()));
    }
  }
}
