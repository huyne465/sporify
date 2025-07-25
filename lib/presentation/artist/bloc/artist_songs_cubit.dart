import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/usecases/song/get_songs_by_artist.dart';
import 'package:sporify/presentation/artist/bloc/artist_songs_state.dart';

import 'package:sporify/core/di/service_locator.dart';

class ArtistSongsCubit extends Cubit<ArtistSongsState> {
  ArtistSongsCubit() : super(ArtistSongsLoading());

  Future<void> getSongsByArtist(String artist) async {
    emit(ArtistSongsLoading());

    try {
      final result = await sl<GetSongsByArtistUseCase>().call(params: artist);

      result.fold(
        (failure) => emit(ArtistSongsFailure(failure)),
        (songs) => emit(ArtistSongsLoaded(songs)),
      );
    } catch (e) {
      emit(ArtistSongsFailure(e.toString()));
    }
  }
}
