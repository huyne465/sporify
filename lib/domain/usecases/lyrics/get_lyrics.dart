import 'package:dartz/dartz.dart';
import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/entities/lyrics/lyrics.dart';
import 'package:sporify/domain/repository/lyrics/lyrics.dart';
import 'package:sporify/di/service_locator.dart';

class GetLyricsUseCase
    implements UseCase<Either<String, LyricsEntity?>, GetLyricsParams> {
  @override
  Future<Either<String, LyricsEntity?>> call({GetLyricsParams? params}) async {
    return await sl<LyricsRepository>().getLyrics(params!.artist, params.track);
  }
}

class GetLyricsParams {
  final String artist;
  final String track;

  GetLyricsParams({required this.artist, required this.track});
}
