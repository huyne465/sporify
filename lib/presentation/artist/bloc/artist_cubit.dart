import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/usecases/artist/get_artists.dart';
import 'package:sporify/presentation/artist/bloc/artist_state.dart';
import 'package:sporify/core/di/service_locator.dart';

class ArtistCubit extends Cubit<ArtistState> {
  ArtistCubit() : super(ArtistLoading());

  Future<void> getArtists() async {
    emit(ArtistLoading());

    var result = await sl<GetArtistsUseCase>().call();

    result.fold(
      (error) => emit(ArtistFailure(error)),
      (artists) => emit(ArtistLoaded(artists)),
    );
  }
}
