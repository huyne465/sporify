import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/data/sources/song/admin_file_upload_service.dart';
import 'package:sporify/presentation/admin/pages/admin_file_upload_page.dart';

class AdminSongListPage extends StatefulWidget {
  const AdminSongListPage({super.key});

  @override
  State<AdminSongListPage> createState() => _AdminSongListPageState();
}

class _AdminSongListPageState extends State<AdminSongListPage> {
  final AdminFileUploadService _uploadService = AdminFileUploadService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Manage Songs'),
        backgroundColor: context.isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: context.isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminFileUploadPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Songs')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final songs = snapshot.data?.docs ?? [];

          if (songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note,
                    size: 80,
                    color: context.isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No songs uploaded yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your first song to get started',
                    style: TextStyle(
                      color: context.isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminFileUploadPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Upload Song',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final data = song.data() as Map<String, dynamic>;

              return _buildSongCard(song.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildSongCard(String songId, Map<String, dynamic> data) {
    final title = data['title'] ?? 'Unknown Title';
    final artist = data['artist'] ?? 'Unknown Artist';
    final album = data['album'] ?? '';
    final genre = data['genre'] ?? '';
    final duration = data['duration'] ?? 0.0;
    final imageUrl = data['image'] ?? '';
    final fileSize = data['fileSize'] ?? 0;
    final addedAt = data['addedAt'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
          child: imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.music_note, color: Colors.grey);
                    },
                  ),
                )
              : const Icon(Icons.music_note, color: Colors.grey),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              artist,
              style: TextStyle(
                color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (album.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Album: $album',
                style: TextStyle(
                  fontSize: 12,
                  color: context.isDarkMode ? Colors.white54 : Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (genre.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Genre: $genre',
                style: TextStyle(
                  fontSize: 12,
                  color: context.isDarkMode ? Colors.white54 : Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: context.isDarkMode ? Colors.white54 : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.storage,
                  size: 12,
                  color: context.isDarkMode ? Colors.white54 : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatFileSize(fileSize),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
            if (addedAt != null) ...[
              const SizedBox(height: 2),
              Text(
                'Added: ${_formatDate(addedAt.toDate())}',
                style: TextStyle(
                  fontSize: 11,
                  color: context.isDarkMode ? Colors.white38 : Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmation(songId, title);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          child: Icon(
            Icons.more_vert,
            color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
        onTap: () {
          _showSongDetails(songId, data);
        },
      ),
    );
  }

  void _showSongDetails(String songId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Song Details',
          style: TextStyle(
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Title', data['title'] ?? 'N/A'),
              _buildDetailRow('Artist', data['artist'] ?? 'N/A'),
              _buildDetailRow('Album', data['album'] ?? 'N/A'),
              _buildDetailRow('Genre', data['genre'] ?? 'N/A'),
              _buildDetailRow(
                'Duration',
                _formatDuration(data['duration'] ?? 0.0),
              ),
              _buildDetailRow(
                'File Size',
                _formatFileSize(data['fileSize'] ?? 0),
              ),
              _buildDetailRow('Platform', data['platform'] ?? 'N/A'),
              _buildDetailRow('Song ID', songId),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String songId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Delete Song',
          style: TextStyle(
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
          style: TextStyle(
            color: context.isDarkMode ? Colors.white70 : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.isDarkMode ? Colors.white70 : Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteSong(songId, title);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSong(String songId, String title) async {
    try {
      final result = await _uploadService.deleteSong(songId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isRight()
                  ? 'Song "$title" deleted successfully'
                  : result.fold((l) => l, (r) => ''),
            ),
            backgroundColor: result.isRight() ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting song: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(double seconds) {
    if (seconds <= 0) return 'Unknown';

    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return 'Unknown';

    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
