import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/usecases/song/get_new_songs.dart';
import 'package:sporify/presentation/root/bloc/new_song_state.dart';
import 'package:sporify/core/di/service_locator.dart';

class NewsSongsCubit extends Cubit<NewsSongsState> {
  NewsSongsCubit() : super(NewsSongsLoading());
  Future<void> getNewsSongs() async {
    var returnedSongs = await sl<GetNewSongsUseCase>().call();

    returnedSongs.fold(
      (l) {
        emit(NewsSongsLoadFailure());
      },
      (data) {
        emit(NewsSongsLoaded(songs: data));
      },
    );
  }
}
