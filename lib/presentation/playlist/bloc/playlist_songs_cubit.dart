import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/usecases/song/get_new_songs.dart';
import 'package:sporify/di/service_locator.dart';
import 'package:sporify/presentation/playlist/bloc/playlist_songs_state.dart';

class PlaylistSongsCubit extends Cubit<PlaylistSongsState> {
  PlaylistSongsCubit() : super(PlaylistSongsLoading());

  Future<void> loadPlaylistSongs(List<String> songIds) async {
    try {
      emit(PlaylistSongsLoading());

      if (songIds.isEmpty) {
        emit(PlaylistSongsLoaded([]));
        return;
      }

      // Get all songs first
      final result = await sl<GetNewSongsUseCase>().call();

      result.fold((failure) => emit(PlaylistSongsError(failure)), (allSongs) {
        // Filter songs that match the songIds from playlist
        final playlistSongs = allSongs
            .where((song) => songIds.contains(song.songId))
            .toList();

        emit(PlaylistSongsLoaded(playlistSongs));
      });
    } catch (e) {
      emit(PlaylistSongsError(e.toString()));
    }
  }
}
