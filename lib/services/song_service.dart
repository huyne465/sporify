import 'package:cloud_firestore/cloud_firestore.dart';

class SongService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'Songs';

  // Load all songs from the collection
  Future<List<Map<String, dynamic>>> getAllSongs() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error loading all songs: $e');
      return [];
    }
  }

  // Query songs by exact title match
  Future<List<Map<String, dynamic>>> getSongsByTitle(String title) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('title', isEqualTo: title)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error querying songs by title: $e');
      return [];
    }
  }

  // Query songs by partial title match (case insensitive)
  Future<List<Map<String, dynamic>>> searchSongsByTitle(
    String searchTerm,
  ) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('title')
          .startAt([searchTerm.toLowerCase()])
          .endAt([searchTerm.toLowerCase() + '\uf8ff'])
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error searching songs: $e');
      return [];
    }
  }

  // Query songs by artist name
  Future<List<Map<String, dynamic>>> getSongsByArtist(String artist) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('artist', isEqualTo: artist)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error querying songs by artist: $e');
      return [];
    }
  }
}
