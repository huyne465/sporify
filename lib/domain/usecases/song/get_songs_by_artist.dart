import 'package:dartz/dartz.dart';
import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/repository/song/song.dart';
import 'package:sporify/service_locator.dart';

class GetSongsByArtistUseCase
    implements UseCase<Either<String, List<SongEntity>>, String> {
  @override
  Future<Either<String, List<SongEntity>>> call({String? params}) async {
    return await sl<SongRepository>().getSongsByArtist(params!);
  }
}
