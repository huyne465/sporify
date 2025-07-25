import 'package:dartz/dartz.dart';
import 'package:sporify/domain/usecases/usecase.dart';
import 'package:sporify/domain/repository/song/song.dart';
import 'package:sporify/core/di/service_locator.dart';

class AddOrRemoveSongUseCase implements UseCase<Either, String> {
  @override
  Future<Either> call({String? params}) async {
    return await sl<SongRepository>().addOrRemoveFavoriteSong(params!);
  }
}
