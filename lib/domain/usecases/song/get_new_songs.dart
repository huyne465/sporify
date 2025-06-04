import 'package:dartz/dartz.dart';
import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/repository/song/song.dart';
import 'package:sporify/service_locator.dart';

class GetNewSongsUseCase
    implements UseCase<Either<String, List<SongEntity>>, void> {
  @override
  Future<Either<String, List<SongEntity>>> call({params}) async {
    return await sl<SongRepository>()
        .getNewsSongs(); // Changed from SongRepositoryImplementation to SongRepository
  }
}
