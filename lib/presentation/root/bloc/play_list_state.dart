import 'package:sporify/domain/entities/songs/song.dart';

abstract class PlayListState {}

class PlayListLoading extends PlayListState {}

class PlayListLoaded extends PlayListState {
  final List<SongEntity> songs;

  PlayListLoaded(this.songs);
}

class PlayListLoadFailure extends PlayListState {
  final String message;

  PlayListLoadFailure(this.message);
}
