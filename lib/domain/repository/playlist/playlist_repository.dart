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

  Future<void> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    String? coverImageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final playlistRef = _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Playlists')
          .doc(playlistId);

      final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

      if (name != null) updateData['name'] = name.trim();
      if (description != null) updateData['description'] = description.trim();
      if (coverImageUrl != null) {
        // Validate URL if provided
        if (coverImageUrl.isNotEmpty && !_isValidImageUrl(coverImageUrl)) {
          throw Exception('Invalid image URL provided');
        }
        updateData['coverImageUrl'] = coverImageUrl;
      }

      await playlistRef.update(updateData);
    } catch (e) {
      throw Exception('Failed to update playlist: $e');
    }
  }

  // Validate image URL
  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme ||
          (!url.startsWith('http://') && !url.startsWith('https://'))) {
        return false;
      }

      final imageExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.bmp',
      ];
      final lowerUrl = url.toLowerCase();
      return imageExtensions.any((ext) => lowerUrl.contains(ext)) ||
          lowerUrl.contains('imgur.com') ||
          lowerUrl.contains('drive.google.com') ||
          lowerUrl.contains('firebasestorage.googleapis.com');
    } catch (e) {
      return false;
    }
  }

  // Optimized share link generation with caching
  Future<String> generateShareableLink(String playlistId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Check if link already exists for this playlist
      final existingLinks = await _firestore
          .collection('SharedPlaylists')
          .where('playlistId', isEqualTo: playlistId)
          .where('userId', isEqualTo: user.uid)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();

      if (existingLinks.docs.isNotEmpty) {
        // Return existing valid link
        final shareId = existingLinks.docs.first.id;
        return 'https://sporify.app/shared/$shareId';
      }

      // Create new link with batch write for better performance
      final batch = _firestore.batch();
      final shareableRef = _firestore.collection('SharedPlaylists').doc();

      batch.set(shareableRef, {
        'playlistId': playlistId,
        'userId': user.uid,
        'createdAt': Timestamp.now(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(days: 30))),
        'accessCount': 0, // Track how many times link is accessed
      });

      await batch.commit();

      return 'https://sporify.app/shared/${shareableRef.id}';
    } catch (e) {
      throw Exception('Failed to generate shareable link: $e');
    }
  }

  Future<PlaylistModel?> getSharedPlaylist(String shareId) async {
    try {
      final shareDoc = await _firestore
          .collection('SharedPlaylists')
          .doc(shareId)
          .get();

      if (!shareDoc.exists) return null;

      final shareData = shareDoc.data()!;
      final expiresAt = (shareData['expiresAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) {
        // Delete expired link
        await shareDoc.reference.delete();
        return null;
      }

      // Get the actual playlist
      final playlistDoc = await _firestore
          .collection('Users')
          .doc(shareData['userId'])
          .collection('Playlists')
          .doc(shareData['playlistId'])
          .get();

      if (!playlistDoc.exists) return null;

      final data = playlistDoc.data()!;
      return PlaylistModel(
        id: playlistDoc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        coverImageUrl: data['coverImageUrl'] ?? '',
        songIds: List<String>.from(data['songIds'] ?? []),
        userId: data['userId'] ?? '',
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get shared playlist: $e');
    }
  }
}

Future<String> generateShareableLink(String playlistId) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  try {
    // Create a public shareable document
    final shareableRef = firestore.collection('SharedPlaylists').doc();

    await shareableRef.set({
      'playlistId': playlistId,
      'userId': user.uid,
      'createdAt': Timestamp.now(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(Duration(days: 30)), // Link expires in 30 days
      ),
    });

    // Return the shareable link
    return 'https://sporify.app/shared/${shareableRef.id}';
  } catch (e) {
    throw Exception('Failed to generate shareable link: $e');
  }
}

Future<PlaylistModel?> getSharedPlaylist(String shareId) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    final shareDoc = await firestore
        .collection('SharedPlaylists')
        .doc(shareId)
        .get();

    if (!shareDoc.exists) return null;

    final shareData = shareDoc.data()!;
    final expiresAt = (shareData['expiresAt'] as Timestamp).toDate();

    if (DateTime.now().isAfter(expiresAt)) {
      // Delete expired link
      await shareDoc.reference.delete();
      return null;
    }

    // Get the actual playlist
    final playlistDoc = await firestore
        .collection('Users')
        .doc(shareData['userId'])
        .collection('Playlists')
        .doc(shareData['playlistId'])
        .get();

    if (!playlistDoc.exists) return null;

    final data = playlistDoc.data()!;
    return PlaylistModel(
      id: playlistDoc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      songIds: List<String>.from(data['songIds'] ?? []),
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  } catch (e) {
    throw Exception('Failed to get shared playlist: $e');
  }
}
