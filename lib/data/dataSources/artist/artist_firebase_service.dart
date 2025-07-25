import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sporify/data/models/artist/artist.dart';
import 'package:sporify/domain/entities/artist/artist.dart';

abstract class ArtistFirebaseService {
  Future<Either<String, List<ArtistEntity>>> getArtistsFromFirebase();
  Future<Either<String, ArtistEntity?>> getArtistByIdFromFirebase(
    String artistId,
  );
}

class ArtistFirebaseServiceImpl extends ArtistFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Either<String, List<ArtistEntity>>> getArtistsFromFirebase() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Artists')
          .get();
      List<ArtistEntity> artists = querySnapshot.docs.map((doc) {
        ArtistModel artistModel = ArtistModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return artistModel.toEntity();
      }).toList();
      return Right(artists);
    } catch (e) {
      return Left('Failed to fetch artists from Firebase: $e');
    }
  }

  @override
  Future<Either<String, ArtistEntity?>> getArtistByIdFromFirebase(
    String artistId,
  ) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Artists')
          .doc(artistId)
          .get();
      if (doc.exists) {
        ArtistModel artistModel = ArtistModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return Right(artistModel.toEntity());
      }
      return const Right(null);
    } catch (e) {
      return Left('Failed to fetch artist from Firebase: $e');
    }
  }
}
