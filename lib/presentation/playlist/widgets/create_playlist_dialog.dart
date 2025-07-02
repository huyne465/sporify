import 'package:flutter/material.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';

class CreatePlaylistDialog extends StatefulWidget {
  final Function(String name, String description, {String? coverImageUrl})
  onCreatePlaylist;

  const CreatePlaylistDialog({super.key, required this.onCreatePlaylist});

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _previewImageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.add, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('Create Playlist'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cover image preview section
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: _previewImageUrl != null && _previewImageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _previewImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Invalid URL',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Preview',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),

              // Image URL input
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Cover Image URL (Optional)',
                  hintText: 'Paste image URL here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.link),
                  suffixIcon: _imageUrlController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.preview, color: AppColors.primary),
                          onPressed: _previewImage,
                          tooltip: 'Preview Image',
                        )
                      : null,
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      _previewImageUrl = null;
                    });
                  }
                },
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!_isValidUrl(value)) {
                      return 'Please enter a valid URL';
                    }
                    if (!_isImageUrl(value)) {
                      return 'URL must be an image (jpg, png, gif, webp)';
                    }
                  }
                  return null;
                },
              ),

              // Helper text
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tip: Use image hosting services like Imgur, Google Drive, or direct image URLs',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),

              const SizedBox(height: 20),

              // Playlist name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Playlist Name',
                  hintText: 'Enter playlist name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.playlist_play),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a playlist name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Describe your playlist',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createPlaylist,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text('Create', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _previewImage() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty && _isValidUrl(url) && _isImageUrl(url)) {
      setState(() {
        _previewImageUrl = url;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid image URL'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  bool _isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final lowerUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowerUrl.contains(ext)) ||
        lowerUrl.contains('imgur.com') ||
        lowerUrl.contains('drive.google.com') ||
        lowerUrl.contains('firebasestorage.googleapis.com');
  }

  Future<void> _createPlaylist() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final coverImageUrl = _imageUrlController.text.trim();

      // Call the callback with playlist data
      await widget.onCreatePlaylist(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
        coverImageUrl: coverImageUrl.isNotEmpty ? coverImageUrl : null,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Playlist created successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('Failed to create playlist: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
