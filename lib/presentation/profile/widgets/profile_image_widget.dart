import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileImageWidget extends StatelessWidget {
  final double size;
  final bool showEditIcon;
  final VoidCallback? onTap;

  const ProfileImageWidget({
    super.key,
    this.size = 80,
    this.showEditIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String? photoURL = user?.photoURL;
    final String initial = _getUserInitial(user);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: photoURL == null ? Colors.brown : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _buildImageContent(photoURL, initial),
          ),
          if (showEditIcon) _buildEditIcon(context),
        ],
      ),
    );
  }

  Widget _buildImageContent(String? photoURL, String initial) {
    if (photoURL != null && photoURL.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoURL,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar(initial);
          },
        ),
      );
    }
    return _buildDefaultAvatar(initial);
  }

  Widget _buildDefaultAvatar(String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEditIcon(context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        height: size * 0.3,
        width: size * 0.3,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(Icons.camera_alt, color: Colors.white, size: size * 0.15),
      ),
    );
  }

  String _getUserInitial(User? user) {
    if (user?.displayName?.isNotEmpty == true) {
      return user!.displayName![0].toUpperCase();
    }
    if (user?.email?.isNotEmpty == true) {
      return user!.email![0].toUpperCase();
    }
    return 'U';
  }
}
