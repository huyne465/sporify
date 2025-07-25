import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/data/models/song/song.dart';

class FavoriteSongsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<SongEntity>> getFavoriteSongs() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // Get favorite song IDs from user's favorites collection
      final favoritesSnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Favorites')
          .orderBy('addedDate', descending: true)
          .get();

      if (favoritesSnapshot.docs.isEmpty) return [];

      // Extract song IDs
      final songIds = favoritesSnapshot.docs
          .map((doc) => doc.data()['songId'] as String)
          .where((id) => id.isNotEmpty)
          .toList();

      if (songIds.isEmpty) return [];

      // Fetch actual song data from Songs collection
      List<SongEntity> songs = [];
      for (String songId in songIds) {
        final songDoc = await _firestore.collection('Songs').doc(songId).get();

        if (songDoc.exists) {
          var songModel = SongModel.fromJson(songDoc.data()!);
          songModel.isFavorite = true;
          songModel.songId = songDoc.id;
          songs.add(songModel.toEntity());
        }
      }

      return songs;
    } catch (e) {
      throw Exception('Failed to load favorite songs: $e');
    }
  }

  Stream<List<SongEntity>> getFavoriteSongsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Favorites')
        .orderBy('addedDate', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return <SongEntity>[];

          // Extract song IDs
          final songIds = snapshot.docs
              .map((doc) => doc.data()['songId'] as String)
              .where((id) => id.isNotEmpty)
              .toList();

          if (songIds.isEmpty) return <SongEntity>[];

          // Fetch actual song data
          List<SongEntity> songs = [];
          for (String songId in songIds) {
            try {
              final songDoc = await _firestore
                  .collection('Songs')
                  .doc(songId)
                  .get();

              if (songDoc.exists) {
                var songModel = SongModel.fromJson(songDoc.data()!);
                songModel.isFavorite = true;
                songModel.songId = songDoc.id;
                songs.add(songModel.toEntity());
              }
            } catch (e) {
              print('Error fetching song $songId: $e');
            }
          }

          return songs;
        });
  }

  Future<void> toggleFavorite(String songId, bool isFavorite) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final favoritesRef = _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Favorites');

      if (!isFavorite) {
        // Remove from favorites
        final querySnapshot = await favoritesRef
            .where('songId', isEqualTo: songId)
            .get();

        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      } else {
        // Add to favorites
        await favoritesRef.add({
          'songId': songId,
          'addedDate': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update favorite status: $e');
    }
  }
}
