import 'package:dartz/dartz.dart';
import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/repository/artist/artist.dart';
import 'package:sporify/di/service_locator.dart';

class GetArtistsUseCase implements UseCase<Either, void> {
  @override
  Future<Either> call({void params}) {
    return sl<ArtistRepository>().getArtists();
  }
}
