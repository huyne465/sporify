import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/usecases/song/get_play_list.dart';
import 'package:sporify/presentation/root/bloc/play_list_state.dart';
import 'package:sporify/core/di/service_locator.dart';

class PlayListCubit extends Cubit<PlayListState> {
  PlayListCubit() : super(PlayListLoading());

  Future<void> getPlayList() async {
    emit(PlayListLoading());

    try {
      final result = await sl<GetPlayListUseCase>().call();

      result.fold(
        (failure) => emit(PlayListLoadFailure(failure)),
        (songs) => emit(PlayListLoaded(songs)),
      );
    } catch (e) {
      emit(PlayListLoadFailure(e.toString()));
    }
  }
}
