import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sporify/core/navigation/getx_navigator.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Navigation methods
  void navigateToAdminUpload() {
    AppNavigator.back();
    AppNavigator.toAdminUpload();
  }

  void navigateToAdminSongList() {
    AppNavigator.back();
    AppNavigator.toAdminSongList();
  }

  void navigateToProfile() {
    AppNavigator.back();
    AppNavigator.showComingSoon('Profile page');
  }

  void navigateToChangePassword() {
    AppNavigator.back();
    AppNavigator.toChangePassword();
  }

  void navigateToSettings() {
    AppNavigator.back();
    AppNavigator.showComingSoon('Settings page');
  }

  void showComingSoonSnackbar(String feature) {
    AppNavigator.showComingSoon(feature);
  }

  Future<void> launchSupportUrl() async {
    AppNavigator.back();

    final Uri url = Uri.parse('https://support.spotify.com/us/');

    try {
      bool launched = false;

      // First try: External application (default browser)
      try {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('External launch failed: $e');
      }

      // Second try: Platform default
      if (!launched) {
        try {
          launched = await launchUrl(url, mode: LaunchMode.platformDefault);
        } catch (e) {
          print('Platform default launch failed: $e');
        }
      }

      // Third try: In-app web view as fallback
      if (!launched) {
        try {
          launched = await launchUrl(url, mode: LaunchMode.inAppWebView);
        } catch (e) {
          print('In-app web view launch failed: $e');
        }
      }

      // If all methods fail, show error
      if (!launched) {
        AppNavigator.showSnackbar(
          title: 'Error',
          message:
              'Could not open support page. Please check if you have a browser installed.',
          isError: true,
        );
      }
    } catch (e) {
      print('URL launch error: $e');
      AppNavigator.showSnackbar(
        title: 'Error',
        message: 'Error opening support page: ${e.toString()}',
        isError: true,
      );
    }
  }

  // User profile methods
  String getUserInitial() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName?.isNotEmpty == true
        ? user!.displayName![0].toUpperCase()
        : user?.email?.isNotEmpty == true
        ? user!.email![0].toUpperCase()
        : 'U';
  }

  String getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email ?? 'User';
  }

  String getUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? '';
  }

  // Logout method
  Future<void> logout() async {
    try {
      AppNavigator.showConfirmDialog(
        title: 'Logout',
        message: 'Are you sure you want to logout?',
        onConfirm: () async {
          await FirebaseAuth.instance.signOut();
          AppNavigator.offAll('/signup-or-signin');

          AppNavigator.showSnackbar(
            title: 'Success',
            message: 'Logged out successfully',
            isError: false,
          );
        },
      );
    } catch (e) {
      AppNavigator.showSnackbar(
        title: 'Error',
        message: 'Failed to logout: ${e.toString()}',
        isError: true,
      );
    }
  }
}
