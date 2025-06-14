import 'package:dartz/dartz.dart';
import 'package:sporify/domain/entities/songs/song.dart';

abstract class SongRepository {
  Future<Either<String, List<SongEntity>>> getNewsSongs();
  Future<Either<String, List<SongEntity>>> getPlayList();
  Future<Either<String, List<SongEntity>>> getSongsByArtist(String artist);
  Future<Either<String, List<SongEntity>>> searchSongs(String query);
  Future<Either> addOrRemoveFavoriteSong(String songId);
  Future<bool> isFavoriteSong(String songId);
}
