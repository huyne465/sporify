import 'package:dartz/dartz.dart';
import 'package:sporify/data/dataSources/artist/artist_firebase_service.dart';
import 'package:sporify/domain/entities/artist/artist.dart';
import 'package:sporify/domain/repository/artist/artist.dart';
import 'package:sporify/core/di/service_locator.dart';

class ArtistRepositoryImpl extends ArtistRepository {
  @override
  Future<Either<String, List<ArtistEntity>>> getArtists() async {
    return await sl<ArtistFirebaseService>().getArtistsFromFirebase();
  }

  @override
  Future<Either<String, ArtistEntity?>> getArtistById(String artistId) async {
    return await sl<ArtistFirebaseService>().getArtistByIdFromFirebase(
      artistId,
    );
  }

  @override
  Future<Either<String, List<ArtistEntity>>> getArtist(String query) async {
    return await sl<ArtistFirebaseService>().getArtistsFromFirebase();
  }
}
