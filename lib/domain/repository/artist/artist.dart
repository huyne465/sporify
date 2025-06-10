import 'package:dartz/dartz.dart';
import 'package:sporify/domain/entities/artist/artist.dart';

abstract class ArtistRepository {
  Future<Either<String, List<ArtistEntity>>> getArtists();
  Future<Either<String, List<ArtistEntity>>> getArtist(String s);
  Future<Either<String, ArtistEntity?>> getArtistById(String artistId);
}
