import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/usecases/song/get_new_songs.dart';
import 'package:sporify/presentation/search/bloc/search_state.dart';
import 'package:sporify/service_locator.dart';

class SearchCubit extends Cubit<SearchState> {
  Timer? _debounceTimer;
  List<SongEntity> _allSongs = [];

  SearchCubit() : super(SearchInitial()) {
    loadAllSongs();
  }

  Future<void> loadAllSongs() async {
    emit(SearchLoading());

    try {
      final result = await sl<GetNewSongsUseCase>().call();

      result.fold((failure) => emit(SearchFailure(message: failure)), (songs) {
        _allSongs = songs;
        emit(SearchLoaded(songs: songs, query: ''));
      });
    } catch (e) {
      emit(SearchFailure(message: e.toString()));
    }
  }

  void searchSongs(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      emit(SearchLoaded(songs: _allSongs, query: ''));
      return;
    }

    // Debounce search for 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performLocalSearch(query.trim());
    });
  }

  void _performLocalSearch(String query) {
    final searchQuery = query.toLowerCase();

    final filteredSongs = _allSongs.where((song) {
      final title = song.title.toLowerCase();
      final artist = song.artist.toLowerCase();
      return title.contains(searchQuery) || artist.contains(searchQuery);
    }).toList();

    if (filteredSongs.isEmpty) {
      emit(SearchEmpty(query: query));
    } else {
      emit(SearchLoaded(songs: filteredSongs, query: query));
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    emit(SearchLoaded(songs: _allSongs, query: ''));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
