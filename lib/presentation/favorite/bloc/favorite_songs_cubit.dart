import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/data/repositories/favorite_songs_repository.dart';
import 'package:sporify/domain/entities/songs/song.dart';

abstract class FavoriteSongsState {}

class FavoriteSongsLoading extends FavoriteSongsState {}

class FavoriteSongsLoaded extends FavoriteSongsState {
  final List<SongEntity> songs;
  FavoriteSongsLoaded(this.songs);
}

class FavoriteSongsError extends FavoriteSongsState {
  final String message;
  FavoriteSongsError(this.message);
}

class FavoriteSongsCubit extends Cubit<FavoriteSongsState> {
  final FavoriteSongsRepository _repository;

  FavoriteSongsCubit(this._repository) : super(FavoriteSongsLoading());

  void loadFavoriteSongs() async {
    try {
      emit(FavoriteSongsLoading());
      final songs = await _repository.getFavoriteSongs();
      emit(FavoriteSongsLoaded(songs));
    } catch (e) {
      emit(FavoriteSongsError(e.toString()));
    }
  }

  void listenToFavoriteSongs() {
    _repository.getFavoriteSongsStream().listen(
      (songs) => emit(FavoriteSongsLoaded(songs)),
      onError: (error) => emit(FavoriteSongsError(error.toString())),
    );
  }

  void removeFavorite(String songId) async {
    try {
      await _repository.toggleFavorite(songId, false);
      // The stream will automatically update the UI
    } catch (e) {
      emit(FavoriteSongsError(e.toString()));
    }
  }
}
