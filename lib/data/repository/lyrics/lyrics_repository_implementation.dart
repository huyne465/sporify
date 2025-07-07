import 'package:dartz/dartz.dart';
import 'package:sporify/data/sources/lyrics/lyrics_api_service.dart';
import 'package:sporify/domain/entities/lyrics/lyrics.dart';
import 'package:sporify/domain/repository/lyrics/lyrics.dart';
import 'package:sporify/di/service_locator.dart';

class LyricsRepositoryImplementation extends LyricsRepository {
  @override
  Future<Either<String, LyricsEntity?>> getLyrics(
    String artist,
    String track,
  ) async {
    return await sl<LyricsApiService>().getLyrics(artist, track);
  }
}
