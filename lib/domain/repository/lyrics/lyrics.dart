import 'package:dartz/dartz.dart';
import 'package:sporify/domain/entities/lyrics/lyrics.dart';

abstract class LyricsRepository {
  Future<Either<String, LyricsEntity?>> getLyrics(String artist, String track);
}
