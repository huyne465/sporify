import 'package:dartz/dartz.dart';
import 'package:sporify/data/sources/song/song_firebase_service.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/repository/song/song.dart';
import 'package:sporify/service_locator.dart';

class SongRepositoryImplementation extends SongRepository {
  @override
  Future<Either<String, List<SongEntity>>> getNewsSongs() async {
    return await sl<SongFirebaseService>().getNewsSongs();
  }
}
