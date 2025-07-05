import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload audio file to Firebase Storage
  Future<String?> uploadAudioFile(File audioFile, String fileName) async {
    try {
      // Validate file exists
      if (!await audioFile.exists()) {
        print('Audio file does not exist: ${audioFile.path}');
        return null;
      }

      // Validate file size (max 50MB)
      final fileSize = await audioFile.length();
      if (fileSize > 50 * 1024 * 1024) {
        print('Audio file too large: ${fileSize / (1024 * 1024)} MB');
        return null;
      }

      print('Uploading audio file: ${audioFile.path}');
      print('File size: ${fileSize / (1024 * 1024)} MB');

      // Create a unique file name
      final String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Reference to the audio files location
      final Reference audioRef = _storage.ref().child('audio/$uniqueFileName');

      // Upload the file
      final UploadTask uploadTask = audioRef.putFile(
        audioFile,
        SettableMetadata(
          contentType: _getAudioContentType(fileName),
          customMetadata: {
            'uploaded_by': 'admin',
            'upload_date': DateTime.now().toIso8601String(),
            'original_name': fileName,
            'file_size': fileSize.toString(),
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Audio upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Audio upload completed: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading audio file: $e');
      return null;
    }
  }

  /// Upload image file to Firebase Storage
  Future<String?> uploadImageFile(File imageFile, String fileName) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        print('Image file does not exist: ${imageFile.path}');
        return null;
      }

      // Validate file size (max 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        print('Image file too large: ${fileSize / (1024 * 1024)} MB');
        return null;
      }

      print('Uploading image file: ${imageFile.path}');
      print('File size: ${fileSize / (1024 * 1024)} MB');

      // Create a unique file name
      final String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Reference to the images location
      final Reference imageRef = _storage.ref().child('images/$uniqueFileName');

      // Upload the file
      final UploadTask uploadTask = imageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: _getImageContentType(fileName),
          customMetadata: {
            'uploaded_by': 'admin',
            'upload_date': DateTime.now().toIso8601String(),
            'original_name': fileName,
            'file_size': fileSize.toString(),
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Image upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image upload completed: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image file: $e');
      return null;
    }
  }

  /// Delete file from Firebase Storage
  Future<bool> deleteFile(String downloadUrl) async {
    try {
      // Get reference from download URL
      final Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Get content type for audio files
  String _getAudioContentType(String fileName) {
    final String extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.aac':
        return 'audio/aac';
      case '.m4a':
        return 'audio/mp4';
      case '.ogg':
        return 'audio/ogg';
      case '.flac':
        return 'audio/flac';
      default:
        return 'audio/mpeg'; // Default to mp3
    }
  }

  /// Get content type for image files
  String _getImageContentType(String fileName) {
    final String extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Default to jpeg
    }
  }

  /// Get file size in a readable format
  String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check if file type is supported audio format
  bool isSupportedAudioFormat(String fileName) {
    final String extension = path.extension(fileName).toLowerCase();
    const supportedFormats = ['.mp3', '.wav', '.aac', '.m4a', '.ogg', '.flac'];
    return supportedFormats.contains(extension);
  }

  /// Check if file type is supported image format
  bool isSupportedImageFormat(String fileName) {
    final String extension = path.extension(fileName).toLowerCase();
    const supportedFormats = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return supportedFormats.contains(extension);
  }
}
