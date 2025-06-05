import 'package:dartz/dartz.dart';
import 'package:sporify/domain/entities/songs/song.dart';

abstract class SongRepository {
  Future<Either<String, List<SongEntity>>> getNewsSongs();
  Future<Either<String, List<SongEntity>>> getPlayList();
}
