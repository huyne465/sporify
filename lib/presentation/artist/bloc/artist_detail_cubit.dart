import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/usecases/artist/get_artist.dart';
import 'package:sporify/presentation/artist/bloc/artist_detail_state.dart';
import 'package:sporify/core/di/service_locator.dart';

class ArtistDetailCubit extends Cubit<ArtistDetailState> {
  ArtistDetailCubit() : super(ArtistDetailLoading());

  Future<void> getArtist(String artistName) async {
    emit(ArtistDetailLoading());

    try {
      var result = await sl<GetArtistUseCase>().call(params: artistName);

      result.fold(
        (error) => emit(ArtistDetailFailure(errorMessage: error)),
        (artist) => emit(ArtistDetailLoaded(artist: artist)),
      );
    } catch (e) {
      emit(ArtistDetailFailure(errorMessage: e.toString()));
    }
  }
}
