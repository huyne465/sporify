import 'package:get/get.dart';
import 'package:sporify/core/routes/app_routes.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/entities/artist/artist.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/data/models/playlist/playlist.dart';

// Import all pages
import 'package:sporify/presentation/splash/pages/splash.dart';
import 'package:sporify/presentation/intro/pages/get_started.dart';
import 'package:sporify/presentation/choose_mode/pages/choose_mode.dart';
import 'package:sporify/presentation/auth/pages/signup_or_signin.dart';
import 'package:sporify/presentation/auth/pages/signup.dart';
import 'package:sporify/presentation/auth/pages/signin.dart';
import 'package:sporify/presentation/auth/pages/reset_password.dart';
import 'package:sporify/presentation/auth/pages/change_password.dart';
import 'package:sporify/presentation/root/pages/main_navigation.dart';
import 'package:sporify/presentation/root/pages/home.dart';
import 'package:sporify/presentation/root/pages/search.dart';
import 'package:sporify/presentation/root/pages/favorite.dart';
import 'package:sporify/presentation/song_player/pages/song_player.dart';
import 'package:sporify/presentation/artist/pages/artist_detail.dart';
import 'package:sporify/presentation/spotify/pages/spotify_artist_detail_clean.dart';
import 'package:sporify/presentation/playlist/pages/playlist_detail.dart';
import 'package:sporify/presentation/admin/pages/admin_file_upload_page.dart';
import 'package:sporify/presentation/admin/pages/admin_song_list_page.dart';

class AppPages {
  static final List<GetPage> pages = [
    // Authentication Pages
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.getStarted,
      page: () => const GetStartedPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.chooseMode,
      page: () => const ChooseModePage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.signupOrSignin,
      page: () => const SignupOrSigninPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => SignupPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.signin,
      page: () => SignInPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Main App Pages
    GetPage(
      name: AppRoutes.mainNavigation,
      page: () => const MainNavigationPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchPage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.favorite,
      page: () => const FavoritePage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Music Player Pages
    GetPage(
      name: AppRoutes.songPlayer,
      page: () {
        final SongEntity song = Get.arguments as SongEntity;
        return SongPlayerPage(songEntity: song);
      },
      transition: Transition.upToDown,
      transitionDuration: const Duration(milliseconds: 400),
      fullscreenDialog: true,
    ),

    // Artist Pages
    GetPage(
      name: AppRoutes.artistDetail,
      page: () {
        final ArtistEntity artist = Get.arguments as ArtistEntity;
        return ArtistDetailPage(artist: artist);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.spotifyArtistDetail,
      page: () {
        final SpotifyArtistEntity artist = Get.arguments as SpotifyArtistEntity;
        return SpotifyArtistDetailPageClean(artist: artist);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Playlist Pages
    GetPage(
      name: AppRoutes.playlistDetail,
      page: () {
        final PlaylistModel playlist = Get.arguments as PlaylistModel;
        return PlaylistDetailPage(playlist: playlist);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Admin Pages
    GetPage(
      name: AppRoutes.adminUpload,
      page: () => const AdminFileUploadPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.adminSongList,
      page: () => const AdminSongListPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
