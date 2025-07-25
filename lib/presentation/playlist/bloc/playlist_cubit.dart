import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/repository/playlist/playlist_repository.dart';
import 'package:sporify/data/models/playlist/playlist.dart';

abstract class PlaylistState {}

class PlaylistLoading extends PlaylistState {}

class PlaylistLoaded extends PlaylistState {
  final List<PlaylistModel> playlists;
  PlaylistLoaded(this.playlists);
}

class PlaylistError extends PlaylistState {
  final String message;
  PlaylistError(this.message);
}

class PlaylistCubit extends Cubit<PlaylistState> {
  final PlaylistRepository _repository;

  PlaylistCubit(this._repository) : super(PlaylistLoading());

  void loadPlaylists() async {
    try {
      emit(PlaylistLoading());
      final playlists = await _repository.getUserPlaylists();
      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  void listenToPlaylists() {
    _repository.getUserPlaylistsStream().listen(
      (playlists) => emit(PlaylistLoaded(playlists)),
      onError: (error) => emit(PlaylistError(error.toString())),
    );
  }

  Future<void> createPlaylist({
    required String name,
    required String description,
    String coverImageUrl = '',
  }) async {
    try {
      await _repository.createPlaylist(
        name: name,
        description: description,
        coverImageUrl: coverImageUrl,
      );
      // Stream will automatically update the UI
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      await _repository.addSongToPlaylist(playlistId, songId);
      // Stream will automatically update the UI
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      await _repository.removeSongFromPlaylist(playlistId, songId);
      // Stream will automatically update the UI
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _repository.deletePlaylist(playlistId);
      // Stream will automatically update the UI
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    String? coverImageUrl,
  }) async {
    try {
      await _repository.updatePlaylist(
        playlistId: playlistId,
        name: name,
        description: description,
        coverImageUrl: coverImageUrl,
      );
      // Stream will automatically update the UI
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<String> generateShareLink(String playlistId) async {
    try {
      return await _repository.generateShareableLink(playlistId);
    } catch (e) {
      emit(PlaylistError(e.toString()));
      rethrow;
    }
  }
}
