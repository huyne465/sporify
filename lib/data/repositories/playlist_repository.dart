import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sporify/data/models/playlist/playlist.dart';

class PlaylistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<PlaylistModel>> getUserPlaylists() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final querySnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Playlists')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return PlaylistModel(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          coverImageUrl: data['coverImageUrl'] ?? '',
          songIds: List<String>.from(data['songIds'] ?? []),
          userId: data['userId'] ?? '',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load playlists: $e');
    }
  }

  Stream<List<PlaylistModel>> getUserPlaylistsStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Playlists')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((doc) {
            final data = doc.data();
            return PlaylistModel(
              id: doc.id,
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              coverImageUrl: data['coverImageUrl'] ?? '',
              songIds: List<String>.from(data['songIds'] ?? []),
              userId: data['userId'] ?? '',
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
        });
  }

  Future<void> createPlaylist({
    required String name,
    required String description,
    String coverImageUrl = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final now = DateTime.now();
      final playlistData = {
        'name': name.trim(),
        'description': description.trim(),
        'coverImageUrl': coverImageUrl,
        'songIds': <String>[],
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'userId': user.uid,
      };

      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Playlists')
          .add(playlistData);
    } catch (e) {
      throw Exception('Failed to create playlist: $e');
    }
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final playlistRef = _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Playlists')
          .doc(playlistId);

      await _firestore.runTransaction((transaction) async {
        final playlistDoc = await transaction.get(playlistRef);
        if (!playlistDoc.exists) {
          throw Exception('Playlist not found');
        }

        final data = playlistDoc.data()!;
        final songIds = List<String>.from(data['songIds'] ?? []);

        if (!songIds.contains(songId)) {
          songIds.add(songId);
          transaction.update(playlistRef, {
            'songIds': songIds,
            'updatedAt': Timestamp.now(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to add song to playlist: $e');
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final playlistRef = _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Playlists')
          .doc(playlistId);

      await _firestore.runTransaction((transaction) async {
        final playlistDoc = await transaction.get(playlistRef);
        if (!playlistDoc.exists) {
          throw Exception('Playlist not found');
        }

        final data = playlistDoc.data()!;
        final songIds = List<String>.from(data['songIds'] ?? []);

        songIds.remove(songId);
        transaction.update(playlistRef, {
          'songIds': songIds,
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      throw Exception('Failed to remove song from playlist: $e');
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Playlists')
          .doc(playlistId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete playlist: $e');
    }
  }
}
