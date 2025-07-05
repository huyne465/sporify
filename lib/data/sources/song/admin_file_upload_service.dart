import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sporify/data/sources/storage/firebase_storage_service.dart';

class AdminFileUploadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  /// Add a new song with audio file and optional image
  Future<Either<String, String>> addSongWithFiles({
    required String title,
    required String artist,
    required File audioFile,
    File? imageFile,
    double? duration,
    String? album,
    String? genre,
  }) async {
    try {
      // Validate input
      if (title.trim().isEmpty) {
        return left('Title cannot be empty');
      }
      if (artist.trim().isEmpty) {
        return left('Artist cannot be empty');
      }
      if (!_storageService.isSupportedAudioFormat(audioFile.path)) {
        return left(
          'Unsupported audio format. Please use MP3, WAV, AAC, M4A, OGG, or FLAC',
        );
      }

      // Upload audio file
      final String? audioUrl = await _storageService.uploadAudioFile(
        audioFile,
        '${title}_${artist}.${audioFile.path.split('.').last}',
      );

      if (audioUrl == null) {
        return left('Failed to upload audio file');
      }

      // Upload image file if provided
      String? imageUrl;
      if (imageFile != null) {
        if (!_storageService.isSupportedImageFormat(imageFile.path)) {
          return left(
            'Unsupported image format. Please use JPG, PNG, GIF, or WebP',
          );
        }

        imageUrl = await _storageService.uploadImageFile(
          imageFile,
          '${title}_${artist}_cover.${imageFile.path.split('.').last}',
        );

        if (imageUrl == null) {
          // If image upload fails, delete the audio file
          await _storageService.deleteFile(audioUrl);
          return left('Failed to upload image file');
        }
      }

      // Add song data to Firestore
      final docRef = await _firestore.collection('Songs').add({
        'title': title.trim(),
        'artist': artist.trim(),
        'album': album?.trim() ?? '',
        'genre': genre?.trim() ?? '',
        'duration': duration ?? 0.0,
        'releaseDate': Timestamp.now(),
        'image': imageUrl ?? '',
        'songUrl': audioUrl,
        'addedBy': 'admin',
        'addedAt': Timestamp.now(),
        'platform': 'local_upload',
        'fileSize': await audioFile.length(),
      });

      return right('Song added successfully with ID: ${docRef.id}');
    } catch (e) {
      return left('Error adding song: $e');
    }
  }

  /// Update existing song
  Future<Either<String, String>> updateSong({
    required String songId,
    String? title,
    String? artist,
    String? album,
    String? genre,
    double? duration,
    File? newAudioFile,
    File? newImageFile,
  }) async {
    try {
      final songDoc = await _firestore.collection('Songs').doc(songId).get();
      if (!songDoc.exists) {
        return left('Song not found');
      }

      final songData = songDoc.data()!;
      final updateData = <String, dynamic>{};

      // Update text fields
      if (title != null && title.trim().isNotEmpty) {
        updateData['title'] = title.trim();
      }
      if (artist != null && artist.trim().isNotEmpty) {
        updateData['artist'] = artist.trim();
      }
      if (album != null) updateData['album'] = album.trim();
      if (genre != null) updateData['genre'] = genre.trim();
      if (duration != null) updateData['duration'] = duration;

      // Update audio file if provided
      if (newAudioFile != null) {
        if (!_storageService.isSupportedAudioFormat(newAudioFile.path)) {
          return left('Unsupported audio format');
        }

        final newAudioUrl = await _storageService.uploadAudioFile(
          newAudioFile,
          '${title ?? songData['title']}_${artist ?? songData['artist']}.${newAudioFile.path.split('.').last}',
        );

        if (newAudioUrl == null) {
          return left('Failed to upload new audio file');
        }

        // Delete old audio file
        if (songData['songUrl'] != null) {
          await _storageService.deleteFile(songData['songUrl']);
        }

        updateData['songUrl'] = newAudioUrl;
        updateData['fileSize'] = await newAudioFile.length();
      }

      // Update image file if provided
      if (newImageFile != null) {
        if (!_storageService.isSupportedImageFormat(newImageFile.path)) {
          return left('Unsupported image format');
        }

        final newImageUrl = await _storageService.uploadImageFile(
          newImageFile,
          '${title ?? songData['title']}_${artist ?? songData['artist']}_cover.${newImageFile.path.split('.').last}',
        );

        if (newImageUrl == null) {
          return left('Failed to upload new image file');
        }

        // Delete old image file if exists
        if (songData['image'] != null && songData['image'].isNotEmpty) {
          await _storageService.deleteFile(songData['image']);
        }

        updateData['image'] = newImageUrl;
      }

      updateData['updatedAt'] = Timestamp.now();

      await _firestore.collection('Songs').doc(songId).update(updateData);

      return right('Song updated successfully');
    } catch (e) {
      return left('Error updating song: $e');
    }
  }

  /// Delete song and associated files
  Future<Either<String, String>> deleteSong(String songId) async {
    try {
      final songDoc = await _firestore.collection('Songs').doc(songId).get();
      if (!songDoc.exists) {
        return left('Song not found');
      }

      final songData = songDoc.data()!;

      // Delete audio file
      if (songData['songUrl'] != null) {
        await _storageService.deleteFile(songData['songUrl']);
      }

      // Delete image file
      if (songData['image'] != null && songData['image'].isNotEmpty) {
        await _storageService.deleteFile(songData['image']);
      }

      // Delete song document
      await _firestore.collection('Songs').doc(songId).delete();

      return right('Song deleted successfully');
    } catch (e) {
      return left('Error deleting song: $e');
    }
  }

  /// Get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final songsSnapshot = await _firestore.collection('Songs').get();

      int totalSongs = songsSnapshot.docs.length;
      int totalFileSize = 0;

      for (var doc in songsSnapshot.docs) {
        final data = doc.data();
        if (data['fileSize'] != null) {
          totalFileSize += (data['fileSize'] as num).toInt();
        }
      }

      return {
        'totalSongs': totalSongs,
        'totalFileSize': totalFileSize,
        'totalFileSizeFormatted': _storageService.getFileSize(totalFileSize),
      };
    } catch (e) {
      return {
        'totalSongs': 0,
        'totalFileSize': 0,
        'totalFileSizeFormatted': '0 B',
      };
    }
  }
}
