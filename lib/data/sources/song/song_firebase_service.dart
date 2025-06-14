import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sporify/data/models/song/song.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/usecases/song/is_favorite.dart';
import 'package:sporify/service_locator.dart';

abstract class SongFirebaseService {
  Future<Either<String, List<SongEntity>>> getNewsSongs();
  Future<Either<String, List<SongEntity>>> getPlayList();
  Future<Either<String, List<SongEntity>>> getSongsByArtist(String artist);
  Future<Either<String, List<SongEntity>>> searchSongs(String query);
  Future<Either> addOrRemoveFavoriteSong(String songId);
  Future<bool> isFavoriteSong(String songId);
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
        bool isFavorite = await sl<IsFavoriteUseCase>().call(
          params: element.reference.id,
        );
        songModel.isFavorite = isFavorite;
        songModel.songId = element.reference.id;
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
        bool isFavorite = await sl<IsFavoriteUseCase>().call(
          params: element.reference.id,
        );
        songModel.isFavorite = isFavorite;
        songModel.songId = element.reference.id;
        songs.add(songModel.toEntity());
      }

      return right(songs);
    } catch (e) {
      print('Firebase error: $e'); // Add this for debugging
      return left('An error occurred, Please try again');
    }
  }

  @override
  Future<Either<String, List<SongEntity>>> getSongsByArtist(
    String artist,
  ) async {
    try {
      List<SongEntity> songs = [];
      var data = await FirebaseFirestore.instance
          .collection('Songs')
          .where('artist', isEqualTo: artist)
          .limit(10)
          .get();

      for (var element in data.docs) {
        var songModel = SongModel.fromJson(element.data());
        bool isFavorite = await sl<IsFavoriteUseCase>().call(
          params: element.reference.id,
        );
        songModel.isFavorite = isFavorite;
        songModel.songId = element.reference.id;
        songs.add(songModel.toEntity());
      }

      // Sort in memory if needed
      songs.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));

      return right(songs);
    } catch (e) {
      print('Firebase error getting songs by artist: $e');
      return left('An error occurred, Please try again');
    }
  }

  @override
  Future<Either<String, bool>> addOrRemoveFavoriteSong(String songId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      late bool isFavorite;

      var user = firebaseAuth.currentUser;
      if (user == null) {
        return const Left('User not logged in');
      }

      String uId = user.uid;

      // Sửa lỗi: đường dẫn không nhất quán
      // Sử dụng cùng một đường dẫn để check và thêm/xóa
      final favoriteCollectionRef = firebaseFirestore
          .collection('Users')
          .doc(uId)
          .collection('Favorites');

      QuerySnapshot favoriteSongs = await favoriteCollectionRef
          .where('songId', isEqualTo: songId)
          .get();

      if (favoriteSongs.docs.isNotEmpty) {
        // Nếu đã favorite, xóa document
        await favoriteSongs.docs.first.reference.delete();
        isFavorite = false;
      } else {
        // Nếu chưa favorite, thêm document mới
        await favoriteCollectionRef.add({
          'songId': songId,
          'addedDate': Timestamp.now(),
        });
        isFavorite = true;
      }

      return Right(isFavorite);
    } catch (e) {
      print('Error toggling favorite: $e'); // Thêm log để debug
      return Left('An error occurred: ${e.toString()}');
    }
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      var user = firebaseAuth.currentUser;
      if (user == null) return false;

      String uId = user.uid;

      // Sửa lỗi: đường dẫn không nhất quán
      // Cập nhật để sử dụng cùng một đường dẫn như trong addOrRemoveFavoriteSong
      QuerySnapshot favoriteSongs = await firebaseFirestore
          .collection('Users') // Thay vì 'Favorites'
          .doc(uId)
          .collection('Favorites')
          .where('songId', isEqualTo: songId)
          .limit(1) // Thêm limit để tối ưu truy vấn
          .get();

      return favoriteSongs.docs.isNotEmpty;
    } catch (e) {
      print('Error checking favorite: $e'); // Thêm log để debug
      return false;
    }
  }

  @override
  Future<Either<String, List<SongEntity>>> searchSongs(String query) async {
    try {
      if (query.trim().isEmpty) {
        return right([]);
      }

      List<SongEntity> songs = [];
      String queryLower = query.toLowerCase();

      // Search by title
      var titleQuery = await FirebaseFirestore.instance
          .collection('Songs')
          .where('title', isGreaterThanOrEqualTo: queryLower)
          .where('title', isLessThan: queryLower + 'z')
          .limit(20)
          .get();

      // Search by artist
      var artistQuery = await FirebaseFirestore.instance
          .collection('Songs')
          .where('artist', isGreaterThanOrEqualTo: queryLower)
          .where('artist', isLessThan: queryLower + 'z')
          .limit(20)
          .get();

      // Combine results and remove duplicates
      Set<String> addedSongIds = {};

      for (var element in [...titleQuery.docs, ...artistQuery.docs]) {
        if (addedSongIds.contains(element.id)) continue;

        var songModel = SongModel.fromJson(element.data());

        // Filter by query match (case insensitive)
        bool titleMatch =
            songModel.title?.toLowerCase().contains(queryLower) ?? false;
        bool artistMatch =
            songModel.artist?.toLowerCase().contains(queryLower) ?? false;

        if (titleMatch || artistMatch) {
          bool isFavorite = await sl<IsFavoriteUseCase>().call(
            params: element.reference.id,
          );
          songModel.isFavorite = isFavorite;
          songModel.songId = element.reference.id;

          songs.add(songModel.toEntity());
          addedSongIds.add(element.id);
        }
      }

      // Sort by relevance (title matches first, then artist matches)
      songs.sort((a, b) {
        bool aTitle = a.title.toLowerCase().contains(queryLower);
        bool bTitle = b.title.toLowerCase().contains(queryLower);

        if (aTitle && !bTitle) return -1;
        if (!aTitle && bTitle) return 1;

        return a.title.compareTo(b.title);
      });

      return right(songs);
    } catch (e) {
      print('Firebase search error: $e');
      return left('Search failed, please try again');
    }
  }
}
