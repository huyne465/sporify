import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sporify/core/routes/app_routes.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/entities/artist/artist.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/data/models/playlist/playlist.dart';

class AppNavigator {
  // Basic navigation
  static void back() => Get.back();
  static void backUntil(String routeName) =>
      Get.until((route) => route.settings.name == routeName);
  static void offAll(String routeName) => Get.offAllNamed(routeName);

  // Authentication routes
  static void toGetStarted() => Get.toNamed(AppRoutes.getStarted);
  static void toChooseMode() => Get.toNamed(AppRoutes.chooseMode);
  static void toSignupOrSignin() => Get.toNamed(AppRoutes.signupOrSignin);
  static void toSignup() => Get.toNamed(AppRoutes.signup);
  static void toSignin() => Get.toNamed(AppRoutes.signin);
  static void toResetPassword() => Get.toNamed(AppRoutes.resetPassword);
  static void toChangePassword() => Get.toNamed(AppRoutes.changePassword);

  // Main app routes
  static void toMainNavigation() => Get.offAllNamed(AppRoutes.mainNavigation);
  static void toHome() => Get.toNamed(AppRoutes.home);
  static void toSearch() => Get.toNamed(AppRoutes.search);
  static void toFavorite() => Get.toNamed(AppRoutes.favorite);

  // Music player routes
  static void toSongPlayer(SongEntity song) {
    Get.toNamed(AppRoutes.songPlayer, arguments: song);
  }

  // Artist routes
  static void toArtistDetail(ArtistEntity artist) {
    Get.toNamed(AppRoutes.artistDetail, arguments: artist);
  }

  static void toSpotifyArtistDetail(SpotifyArtistEntity artist) {
    Get.toNamed(AppRoutes.spotifyArtistDetail, arguments: artist);
  }

  // Playlist routes
  static void toPlaylistDetail(PlaylistModel playlist) {
    Get.toNamed(AppRoutes.playlistDetail, arguments: playlist);
  }

  // Admin routes
  static void toAdminUpload() => Get.toNamed(AppRoutes.adminUpload);
  static void toAdminSongList() => Get.toNamed(AppRoutes.adminSongList);

  // Dialog and Bottom Sheet helpers
  static void showSnackbar({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError
          ? Get.theme.colorScheme.error
          : Get.theme.primaryColor,
      colorText: Get.theme.colorScheme.onPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  static void showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature will be available soon',
      icon: const Icon(Icons.info_outline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  // Utility methods
  static void showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onCancel ?? Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  static void showLoadingDialog() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  static void hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
