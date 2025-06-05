import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sporify/data/models/song/song.dart';
import 'package:sporify/domain/entities/songs/song.dart';

abstract class SongFirebaseService {
  Future<Either<String, List<SongEntity>>> getNewsSongs();
  Future<Either<String, List<SongEntity>>> getPlayList();
}

class SongFirebaseServiceImpl extends SongFirebaseService {
  @override
  Future<Either<String, List<SongEntity>>> getNewsSongs() async {
    try {
      List<SongEntity> songs = [];
      var data = await FirebaseFirestore.instance
          .collection('Songs')
          .orderBy('releaseDate', descending: true)
          .limit(10) // Increased limit for more songs
          .get();

      for (var element in data.docs) {
        var songModel = SongModel.fromJson(element.data());
        songs.add(songModel.toEntity());
      }

      return right(songs);
    } catch (e) {
      print('Firebase error: $e'); // Add this for debugging
      return left('An error occurred, Please try again');
    }
  }

  @override
  Future<Either<String, List<SongEntity>>> getPlayList() async {
    try {
      List<SongEntity> songs = [];
      var data = await FirebaseFirestore.instance
          .collection('Songs')
          .orderBy('releaseDate', descending: true)
          .limit(2) // Increased limit for more songs
          .get();

      for (var element in data.docs) {
        var songModel = SongModel.fromJson(element.data());
        songs.add(songModel.toEntity());
      }

      return right(songs);
    } catch (e) {
      print('Firebase error: $e'); // Add this for debugging
      return left('An error occurred, Please try again');
    }
  }
}
