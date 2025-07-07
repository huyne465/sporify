import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sporify/presentation/auth/pages/signup_or_signin.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/core/configs/assets/app_images.dart';
import 'package:sporify/core/configs/assets/app_vectors.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/presentation/music_player/widgets/mini_player.dart';
import 'package:sporify/presentation/root/widgets/new_song.dart';
import 'package:sporify/presentation/root/widgets/play_list.dart';
import 'package:sporify/presentation/root/widgets/artist_list.dart';
import 'package:sporify/presentation/auth/pages/change_password.dart';
import 'package:sporify/presentation/root/widgets/spotify_artist_list.dart';
import 'package:sporify/presentation/root/widgets/spotify_albums_list.dart';
import 'package:sporify/presentation/root/widgets/spotify_popular_tracks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/presentation/admin/pages/admin_file_upload_page.dart';
import 'package:sporify/presentation/admin/pages/admin_song_list_page.dart';
import 'package:sporify/core/navigation/getx_navigator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        hideback: true,
        leading: _buildProfileIcon(),
        title: SvgPicture.asset(AppVectors.logo, height: 40, width: 40),
      ),
      drawer: _buildProfileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _homeTopArtistCard(),

                    // Discover New Music Section
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: Text(
                        "Discover New Music",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: context.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),

                    _tabs(),
                    SizedBox(
                      height: 270,
                      child: TabBarView(
                        physics: const BouncingScrollPhysics(),
                        controller: _tabController,
                        children: [
                          const NewsSongs(),
                          Center(child: _buildComingSoonCard("Video content")),
                          const ArtistList(),
                          Center(
                            child: _buildComingSoonCard("Podcast content"),
                          ),
                        ],
                      ),
                    ),

                    // Spotify Popular Artists section
                    _buildSectionHeader(
                      "Popular Artists on Spotify",
                      onSeeAll: () =>
                          _showComingSoonSnackBar("All artists page"),
                    ),
                    const SpotifyArtistList(),

                    // Top Tracks section
                    _buildSectionHeader(
                      "Top Tracks",
                      onSeeAll: () =>
                          _showComingSoonSnackBar("All tracks page"),
                    ),
                    SizedBox(height: 300, child: const SpotifyPopularTracks()),

                    // Popular Albums section
                    _buildSectionHeader(
                      "Popular Albums",
                      onSeeAll: () =>
                          _showComingSoonSnackBar("All albums page"),
                    ),
                    SizedBox(height: 220, child: const SpotifyAlbumsList()),

                    // Local Artists section
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        top: 20,
                        bottom: 15,
                      ),
                      child: Text(
                        "Local Artists",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: context.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const ArtistList(),

                    // Top Playlists section
                    _buildSectionHeader(
                      'Top Playlists',
                      onSeeAll: () => _showComingSoonSnackBar("More playlists"),
                    ),
                    const PlayList(),

                    const SizedBox(height: 20),

                    // Future content placeholder
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.6),
                            AppColors.darkGrey.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          "More content coming soon",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const SizedBox(height: 80), // Space for mini player
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          BlocBuilder<GlobalMusicPlayerCubit, GlobalMusicPlayerState>(
            builder: (context, state) {
              if (state.currentSong == null) {
                return const SizedBox.shrink();
              }
              return const MiniPlayer();
            },
          ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 15, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: context.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'See All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard(String content) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            "$content coming soon",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Stay tuned for updates!",
            style: TextStyle(
              fontSize: 14,
              color: context.isDarkMode ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    AppNavigator.showComingSoon(feature);
  }

  Widget _homeTopArtistCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      height: 140,
      child: Stack(
        children: [
          // Base container with gradient background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.7), Colors.black54],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),

          // SVG background pattern
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SvgPicture.asset(
              AppVectors.artistCard,
              fit: BoxFit.fill,
              width: double.infinity,
            ),
          ),

          // Artist image positioned on top
          Positioned(
            bottom: 0,
            right: 10,
            top: -15, // Move image up to position it on top of the card
            child: Image.asset(
              AppImages.topArtistCard,
              height: 180, // Increased height to make image more prominent
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: context.isDarkMode ? Colors.white : Colors.black,
      unselectedLabelColor: context.isDarkMode
          ? Colors.white60
          : Colors.black45,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      labelPadding: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      tabAlignment: TabAlignment.start,
      tabs: const [
        Tab(text: 'News', height: 35),
        Tab(text: 'Video', height: 35),
        Tab(text: 'Artists', height: 35),
        Tab(text: 'Podcast', height: 35),
      ],
    );
  }

  Widget _buildProfileIcon() {
    final user = FirebaseAuth.instance.currentUser;
    final String initial = user?.displayName?.isNotEmpty == true
        ? user!.displayName![0].toUpperCase()
        : user?.email?.isNotEmpty == true
        ? user!.email![0].toUpperCase()
        : 'U';

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Scaffold.of(context).openDrawer();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.brown,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDrawer() {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? user?.email ?? 'User';
    final String userEmail = user?.email ?? '';
    final String initial = user?.displayName?.isNotEmpty == true
        ? user!.displayName![0].toUpperCase()
        : user?.email?.isNotEmpty == true
        ? user!.email![0].toUpperCase()
        : 'U';

    return Drawer(
      backgroundColor: context.isDarkMode ? Colors.grey[900] : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: context.isDarkMode
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (userEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.isDarkMode
                            ? Colors.white70
                            : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () => AppNavigator.showComingSoon('Profile page'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () {
                      AppNavigator.back();
                      AppNavigator.toChangePassword();
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () => AppNavigator.showComingSoon('Settings page'),
                  ),

                  const Divider(height: 1),

                  // Admin Section (if needed)
                  _buildDrawerItem(
                    icon: Icons.cloud_upload,
                    title: 'Admin Upload',
                    onTap: () {
                      AppNavigator.back();
                      AppNavigator.toAdminUpload();
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.library_music,
                    title: 'Manage Songs',
                    onTap: () {
                      AppNavigator.back();
                      AppNavigator.toAdminSongList();
                    },
                  ),

                  const Divider(height: 1),

                  _buildDrawerItem(
                    icon: Icons.help,
                    title: 'Support',
                    onTap: () async {
                      AppNavigator.back();
                      await _launchSupportUrl();
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info,
                    title: 'About',
                    onTap: () => AppNavigator.showComingSoon('About page'),
                  ),
                ],
              ),
            ),

            // Logout Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: context.isDarkMode
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () => _showLogoutDialog(),
                textColor: Colors.red,
                iconColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            iconColor ??
            (context.isDarkMode ? Colors.white70 : Colors.grey[700]),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color:
              textColor ?? (context.isDarkMode ? Colors.white : Colors.black),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                color: context.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
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
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close drawer

              try {
                await FirebaseAuth.instance.signOut();

                // Navigate to signup/signin page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupOrSigninPage(),
                  ),
                  (route) => false,
                );

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Text('Logged out successfully'),
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
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text('Logout failed: ${e.toString()}'),
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
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchSupportUrl() async {
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
}
