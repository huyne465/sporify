import 'package:dartz/dartz.dart';
import 'package:sporify/data/sources/song/song_firebase_service.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/repository/song/song.dart';
import 'package:sporify/di/service_locator.dart';

class SongRepositoryImplementation extends SongRepository {
  @override
  Future<Either<String, List<SongEntity>>> getNewsSongs() async {
    return await sl<SongFirebaseService>().getNewsSongs();
  }

  @override
  Future<Either<String, List<SongEntity>>> getPlayList() async {
    return await sl<SongFirebaseService>().getPlayList();
  }

  @override
  Future<Either> addOrRemoveFavoriteSong(String songId) async {
    return await sl<SongFirebaseService>().addOrRemoveFavoriteSong(songId);
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    return await sl<SongFirebaseService>().isFavoriteSong(songId);
  }

  @override
  Future<Either<String, List<SongEntity>>> getSongsByArtist(
    String artist,
  ) async {
    return await sl<SongFirebaseService>().getSongsByArtist(artist);
  }

  @override
  Future<Either<String, List<SongEntity>>> searchSongs(String query) async {
    return await sl<SongFirebaseService>().searchSongs(query);
  }
}
