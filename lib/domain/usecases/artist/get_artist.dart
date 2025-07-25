import 'package:dartz/dartz.dart';
import 'package:sporify/domain/usecases/usecase.dart';
import 'package:sporify/domain/repository/artist/artist.dart';
import 'package:sporify/core/di/service_locator.dart';

class GetArtistUseCase implements UseCase<Either, String> {
  @override
  Future<Either> call({String? params}) {
    return sl<ArtistRepository>().getArtist(params!);
  }
}
