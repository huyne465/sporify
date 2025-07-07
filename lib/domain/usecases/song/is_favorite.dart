import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/repository/song/song.dart';
import 'package:sporify/di/service_locator.dart';

class IsFavoriteUseCase implements UseCase<bool, String> {
  @override
  Future<bool> call({String? params}) async {
    return await sl<SongRepository>().isFavoriteSong(params!);
  }
}
