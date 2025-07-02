import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/data/models/playlist/playlist.dart';
import 'package:sporify/data/repositories/playlist_repository.dart';

class PlaylistOptionsDialog extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const PlaylistOptionsDialog({
    super.key,
    required this.playlist,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.more_horiz, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Playlist Options',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Edit playlist
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.primary),
              title: Text('Edit Playlist'),
              subtitle: Text('Change name and description'),
              onTap: () {
                Navigator.pop(context);
                _showEditPlaylistDialog(context);
              },
            ),

            // Change cover - Updated with faster loading
            ListTile(
              leading: Icon(Icons.image, color: Colors.blue),
              title: Text('Change Cover'),
              subtitle: Text('Upload or paste image URL'),
              onTap: () {
                Navigator.pop(context);
                _showImageOptionsDialog(context);
              },
            ),

            // Share playlist - Enhanced with social media
            ListTile(
              leading: Icon(Icons.share, color: Colors.green),
              title: Text('Share Playlist'),
              subtitle: Text('Share via social media or link'),
              onTap: () {
                Navigator.pop(context);
                _showShareOptionsDialog(context);
              },
            ),

            Divider(),

            // Delete playlist
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Playlist',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: Text('This action cannot be undone'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPlaylistDialog(BuildContext context) {
    final nameController = TextEditingController(text: playlist.name);
    final descriptionController = TextEditingController(
      text: playlist.description,
    );
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Edit Playlist'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Playlist Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.playlist_play),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a playlist name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setState(() => isLoading = true);

                      try {
                        await PlaylistRepository().updatePlaylist(
                          playlistId: playlist.id,
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                        );

                        Navigator.pop(context);
                        onUpdate();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Playlist updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update playlist: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Change Cover Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.link, color: AppColors.primary),
              title: Text('Paste Image URL'),
              subtitle: Text('Quick and instant'),
              onTap: () {
                Navigator.pop(context);
                _showImageUrlDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text('Take Photo'),
              subtitle: Text('Use camera'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showImageUrlDialog(BuildContext context) {
    final urlController = TextEditingController();
    String? previewUrl;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Paste Image URL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // URL Input
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.preview, color: AppColors.primary),
                    onPressed: () {
                      final url = urlController.text.trim();
                      if (url.isNotEmpty && _isValidImageUrl(url)) {
                        setState(() => previewUrl = url);
                      }
                    },
                  ),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() => previewUrl = null);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Preview
              if (previewUrl != null) ...[
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      previewUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.red.shade100,
                        child: Icon(Icons.broken_image, color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Preview', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = urlController.text.trim();
                if (url.isNotEmpty && _isValidImageUrl(url)) {
                  Navigator.pop(context);
                  await _updateImageUrl(context, url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid image URL'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) return false;

    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final lowerUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowerUrl.contains(ext)) ||
        lowerUrl.contains('imgur.com') ||
        lowerUrl.contains('drive.google.com') ||
        lowerUrl.contains('firebasestorage.googleapis.com') ||
        lowerUrl.contains('unsplash.com') ||
        lowerUrl.contains('pixabay.com');
  }

  Future<void> _updateImageUrl(BuildContext context, String imageUrl) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(width: 16),
              Text('Updating cover...'),
            ],
          ),
        ),
      );

      final repository = PlaylistRepository();
      await repository.updatePlaylist(
        playlistId: playlist.id,
        coverImageUrl: imageUrl,
      );

      Navigator.pop(context); // Close loading dialog
      onUpdate();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Cover updated instantly!'),
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update cover: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showShareOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.share, color: AppColors.primary),
            const SizedBox(width: 12),
            Text('Share Playlist'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick Share
            ListTile(
              leading: Icon(Icons.copy, color: Colors.blue),
              title: Text('Copy Link'),
              subtitle: Text('Generate and copy link'),
              onTap: () {
                Navigator.pop(context);
                _generateAndCopyLink(context);
              },
            ),

            // Social Media Shares
            ListTile(
              leading: Icon(Icons.facebook, color: Colors.blue),
              title: Text('Facebook'),
              subtitle: Text('Share to Facebook'),
              onTap: () {
                Navigator.pop(context);
                _shareToFacebook(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.telegram, color: Colors.cyan),
              title: Text('Telegram'),
              subtitle: Text('Share to Telegram'),
              onTap: () {
                Navigator.pop(context);
                _shareToTelegram(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.message, color: Colors.green),
              title: Text('WhatsApp'),
              subtitle: Text('Share to WhatsApp'),
              onTap: () {
                Navigator.pop(context);
                _shareToWhatsApp(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.alternate_email, color: Colors.blue[800]),
              title: Text('Twitter/X'),
              subtitle: Text('Share to Twitter'),
              onTap: () {
                Navigator.pop(context);
                _shareToTwitter(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.purple),
              title: Text('Instagram'),
              subtitle: Text('Share to Instagram'),
              onTap: () {
                Navigator.pop(context);
                _shareToInstagram(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.more_horiz, color: Colors.grey),
              title: Text('More Options'),
              subtitle: Text('System share sheet'),
              onTap: () {
                Navigator.pop(context);
                _shareGeneric(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndCopyLink(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(width: 16),
              Text('Generating link...'),
            ],
          ),
        ),
      );

      final repository = PlaylistRepository();
      final shareLink = await repository.generateShareableLink(playlist.id);

      Navigator.pop(context); // Close loading

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: shareLink));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.copy, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Link copied to clipboard!'),
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareToFacebook(BuildContext context) async {
    try {
      final repository = PlaylistRepository();
      final shareLink = await repository.generateShareableLink(playlist.id);

      final content =
          'Check out my awesome playlist "${playlist.name}" on Sporify! 🎵\n\n$shareLink';

      await SocialSharingPlus.shareToSocialMedia(
        SocialPlatform.facebook,
        content,
        isOpenBrowser: true,
        onAppNotInstalled: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Facebook is not installed.'),
                backgroundColor: Colors.orange,
              ),
            );
          _shareGeneric(context);
        },
      );

      _showShareSuccessMessage(context, 'Facebook');
    } catch (e) {
      print('Facebook share error: $e');
      await _shareGeneric(context);
    }
  }

  Future<void> _shareToWhatsApp(BuildContext context) async {
    try {
      final repository = PlaylistRepository();
      final shareLink = await repository.generateShareableLink(playlist.id);

      final content =
          '🎵 Check out my playlist "${playlist.name}" on Sporify!\n\n$shareLink';

      await SocialSharingPlus.shareToSocialMedia(
        SocialPlatform.whatsapp,
        content,
        isOpenBrowser: false,
        onAppNotInstalled: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('WhatsApp is not installed.'),
                backgroundColor: Colors.orange,
              ),
            );
          _shareGeneric(context);
        },
      );

      _showShareSuccessMessage(context, 'WhatsApp');
    } catch (e) {
      print('WhatsApp share error: $e');
      await _shareGeneric(context);
    }
  }

  Future<void> _shareToTelegram(BuildContext context) async {
    try {
      final repository = PlaylistRepository();
      final shareLink = await repository.generateShareableLink(playlist.id);

      final content =
          '🎵 Check out my playlist "${playlist.name}" on Sporify!\n\n$shareLink';

      await SocialSharingPlus.shareToSocialMedia(
        SocialPlatform.telegram,
        content,
        isOpenBrowser: false,
        onAppNotInstalled: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Telegram is not installed.'),
                backgroundColor: Colors.orange,
              ),
            );
          _shareGeneric(context);
        },
      );

      _showShareSuccessMessage(context, 'Telegram');
    } catch (e) {
      print('Telegram share error: $e');
      await _shareGeneric(context);
    }
  }

  Future<void> _shareToTwitter(BuildContext context) async {
    try {
      final repository = PlaylistRepository();
      final shareLink = await repository.generateShareableLink(playlist.id);

      final content =
          '🎵 Check out my playlist "${playlist.name}" on Sporify! $shareLink #music #playlist';

      await SocialSharingPlus.shareToSocialMedia(
        SocialPlatform.twitter,
        content,
        isOpenBrowser: true,
        onAppNotInstalled: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Twitter/X is not installed.'),
                backgroundColor: Colors.orange,
              ),
            );
          _shareGeneric(context);
        },
      );

      _showShareSuccessMessage(context, 'Twitter');
    } catch (e) {
      print('Twitter share error: $e');
      await _shareGeneric(context);
    }
  }

  Future<void> _shareToInstagram(BuildContext context) async {
    try {
      final repository = PlaylistRepository();
      final shareLink = await repository.generateShareableLink(playlist.id);

      final content =
          '🎵 My playlist "${playlist.name}" on Sporify! Check it out: $shareLink';

      await SocialSharingPlus.shareToSocialMedia(
        SocialPlatform.linkedin,
        content,
        isOpenBrowser: false,
        onAppNotInstalled: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Instagram is not installed.'),
                backgroundColor: Colors.orange,
              ),
            );
          _shareGeneric(context);
        },
      );

      _showShareSuccessMessage(context, 'Instagram');
    } catch (e) {
      print('Instagram share error: $e');
      await _shareGeneric(context);
    }
  }

  Future<void> _shareGeneric(BuildContext context) async {
    try {
      final repository = PlaylistRepository();
      final shareLink = await repository.generateShareableLink(playlist.id);

      await Share.share(
        '🎵 Check out my playlist "${playlist.name}" on Sporify!\n\n$shareLink',
        subject: 'Check out my playlist: ${playlist.name}',
      );

      _showShareSuccessMessage(context, 'shared');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showShareSuccessMessage(BuildContext context, String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('Successfully shared to $platform!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete "${playlist.name}"?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
