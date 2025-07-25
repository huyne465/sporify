import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import 'package:sporify/common/base_widgets/app_bar/app_bar.dart';
import 'package:sporify/common/base_widgets/favorite_button/favorite_button.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/core/constants/app_urls.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/usecases/user/user_premium.dart';
import 'package:sporify/core/di/service_locator.dart';
import 'package:sporify/presentation/lyrics/bloc/lyrics_cubit.dart';
import 'package:sporify/presentation/lyrics/widgets/lyrics_view.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_state.dart';
import 'package:sporify/presentation/playlist/widgets/add_to_playlist_dialog.dart';

class SongPlayerPage extends StatefulWidget {
  final SongEntity songEntity;
  const SongPlayerPage({super.key, required this.songEntity});

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  bool isFavorite = false;
  bool _showLyrics = false;
  late LyricsCubit _lyricsCubit;
  String? _lastLoadedSongId;

  @override
  void initState() {
    super.initState();
    _lyricsCubit = LyricsCubit();

    // Load song in global player if not already playing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final globalCubit = context.read<GlobalMusicPlayerCubit>();
      if (globalCubit.state.currentSong?.songId != widget.songEntity.songId) {
        globalCubit.loadSong(widget.songEntity);
      }

      // Load initial lyrics
      final currentSong = globalCubit.state.currentSong ?? widget.songEntity;
      _loadLyricsIfNeeded(currentSong);
    });
  }

  @override
  void dispose() {
    _lyricsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: _lyricsCubit)],
      child: BlocListener<GlobalMusicPlayerCubit, GlobalMusicPlayerState>(
        listener: (context, state) {
          // Only update lyrics when song actually changes, not on every state change
          if (state.currentSong != null) {
            _loadLyricsIfNeeded(state.currentSong!);
          }
        },
        child: Scaffold(
          appBar: BasicAppBar(
            title: Text('Now Playing', style: TextStyle(fontSize: 18)),
            action: IconButton(
              onPressed: () {
                _toggleLyrics();
              },
              icon: Icon(_showLyrics ? Icons.music_note : Icons.lyrics),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  _songDetail(context),
                  _buildPlayerControls(),
                  if (_showLyrics) _buildLyricsSection(),
                  const SizedBox(
                    height: 20,
                  ), // Reduced space since no mini player
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loadLyricsIfNeeded(SongEntity song) {
    // Only load lyrics if the song has actually changed
    if (_lastLoadedSongId != song.songId) {
      _lastLoadedSongId = song.songId;
      _lyricsCubit.getLyrics(song.artist, song.title);
    }
  }

  Future<void> _toggleLyrics() async {
    try {
      // Check if user has premium access
      final result = await sl<CheckUserPremiumStatusUseCase>().call();

      result.fold(
        (failure) {
          _showPremiumRequiredDialog();
        },
        (hasPremium) {
          if (hasPremium) {
            setState(() {
              _showLyrics = !_showLyrics;
            });
          } else {
            _showPremiumRequiredDialog();
          }
        },
      );
    } catch (e) {
      _showPremiumRequiredDialog();
    }
  }

  void _showPremiumRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Text(
              'Premium Feature',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lyrics,
              size: 48,
              color: AppColors.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Lyrics are available for Premium subscribers only.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to Premium to enjoy lyrics and many other features!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Maybe Later',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/premium');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  Widget _songDetail(BuildContext context) {
    return BlocBuilder<GlobalMusicPlayerCubit, GlobalMusicPlayerState>(
      builder: (context, state) {
        // Use current song from global state, fallback to widget song
        final currentSong = state.currentSong ?? widget.songEntity;
        final imageUrl = AppUrls.getImageUrl(
          currentSong.artist,
          currentSong.title,
          currentSong.image,
        );

        return Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.width - 10,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(imageUrl),
                  onError: (exception, stackTrace) =>
                      const AssetImage('assets/images/default_cover.png'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      currentSong.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                FavoriteButton(songEntity: currentSong),
              ],
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  currentSong.artist,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Add playlist info
            BlocBuilder<GlobalMusicPlayerCubit, GlobalMusicPlayerState>(
              builder: (context, state) {
                final cubit = context.read<GlobalMusicPlayerCubit>();
                final playlistInfo = cubit.currentPlaylistInfo;

                if (playlistInfo.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cubit.isPlaylistMode
                              ? Icons.playlist_play
                              : Icons.shuffle,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          playlistInfo,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayerControls() {
    return BlocBuilder<GlobalMusicPlayerCubit, GlobalMusicPlayerState>(
      builder: (context, state) {
        final cubit = context.read<GlobalMusicPlayerCubit>();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              // Progress bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.grey[300],
                  trackHeight: 4.0,
                  thumbColor: AppColors.primary,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8.0,
                  ),
                  overlayColor: AppColors.primary.withAlpha(32),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16.0,
                  ),
                ),
                child: Slider(
                  value: state.position.inSeconds.toDouble(),
                  max: state.duration.inSeconds.toDouble() == 0
                      ? widget.songEntity.duration.toDouble()
                      : state.duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    final cubit = context.read<GlobalMusicPlayerCubit>();
                    cubit.seekTo(Duration(seconds: value.toInt()));
                  },
                ),
              ),

              // Duration display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(state.position),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      _formatDuration(
                        state.duration.inSeconds > 0
                            ? state.duration
                            : Duration(
                                seconds: widget.songEntity.duration.toInt(),
                              ),
                      ),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // Playback controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous, size: 36),
                    onPressed: cubit.hasPrevious
                        ? () => cubit.playPrevious()
                        : null,
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        cubit.playOrPause();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next, size: 36),
                    onPressed: cubit.hasNext ? () => cubit.playNext() : null,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Additional controls (shuffle, repeat, etc.)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.shuffle, color: Colors.grey[600]),
                    onPressed: () {
                      // Shuffle functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.repeat, color: Colors.grey[600]),
                    onPressed: () {
                      // Repeat functionality
                    },
                  ),
                  // Add exit playlist button
                  BlocBuilder<GlobalMusicPlayerCubit, GlobalMusicPlayerState>(
                    builder: (context, state) {
                      final cubit = context.read<GlobalMusicPlayerCubit>();

                      if (cubit.isPlaylistMode) {
                        return IconButton(
                          icon: Icon(
                            Icons.playlist_remove,
                            color: Colors.orange,
                          ),
                          onPressed: () => _showExitPlaylistDialog(context),
                          tooltip: 'Exit Playlist Mode',
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.playlist_add, color: Colors.grey[600]),
                    onPressed: () {
                      // Show add to playlist dialog - use current song from global state
                      final currentSong =
                          context
                              .read<GlobalMusicPlayerCubit>()
                              .state
                              .currentSong ??
                          widget.songEntity;
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AddToPlaylistDialog(song: currentSong),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.grey[600]),
                    onPressed: () => _showShareSongDialog(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLyricsSection() {
    return BlocBuilder<GlobalMusicPlayerCubit, GlobalMusicPlayerState>(
      builder: (context, state) {
        final currentSong = state.currentSong ?? widget.songEntity;
        final imageUrl = AppUrls.getImageUrl(
          currentSong.artist,
          currentSong.title,
          currentSong.image,
        );

        return Container(
          height: 400,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: LyricsView(
            currentPosition: state.position,
            coverImageUrl: imageUrl,
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _showShareSongDialog(BuildContext context) {
    final currentSong =
        context.read<GlobalMusicPlayerCubit>().state.currentSong ??
        widget.songEntity;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Song',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${currentSong.title} by ${currentSong.artist}',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Share options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  context,
                  icon: Icons.facebook,
                  label: 'Facebook',
                  color: Colors.blue,
                  onTap: () => _shareSongToFacebook(context, currentSong),
                ),
                _buildShareOption(
                  context,
                  icon: Icons.message,
                  label: 'WhatsApp',
                  color: Colors.green,
                  onTap: () => _shareSongToWhatsApp(context, currentSong),
                ),
                _buildShareOption(
                  context,
                  icon: Icons.telegram,
                  label: 'Telegram',
                  color: Colors.cyan,
                  onTap: () => _shareSongToTelegram(context, currentSong),
                ),
                _buildShareOption(
                  context,
                  icon: Icons.more_horiz,
                  label: 'More',
                  color: Colors.grey,
                  onTap: () => _shareSongGeneric(context, currentSong),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _shareSongToFacebook(
    BuildContext context,
    SongEntity song,
  ) async {
    try {
      Navigator.pop(context);

      final content =
          '🎵 Currently listening to "${song.title}" by ${song.artist} on Sporify!';

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
          _shareSongGeneric(context, song);
        },
      );
    } catch (e) {
      await _shareSongGeneric(context, song);
    }
  }

  Future<void> _shareSongToWhatsApp(
    BuildContext context,
    SongEntity song,
  ) async {
    try {
      Navigator.pop(context);

      final content =
          '🎵 Check out this song: "${song.title}" by ${song.artist} 🎶';

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
          _shareSongGeneric(context, song);
        },
      );
    } catch (e) {
      await _shareSongGeneric(context, song);
    }
  }

  Future<void> _shareSongToTelegram(
    BuildContext context,
    SongEntity song,
  ) async {
    try {
      Navigator.pop(context);

      final content = '🎵 "${song.title}" by ${song.artist} - Great song! 🎶';

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
          _shareSongGeneric(context, song);
        },
      );
    } catch (e) {
      await _shareSongGeneric(context, song);
    }
  }

  Future<void> _shareSongGeneric(BuildContext context, SongEntity song) async {
    try {
      await Share.share(
        '🎵 Check out this song: "${song.title}" by ${song.artist} on Sporify!',
        subject: 'Great song recommendation',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share song'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showExitPlaylistDialog(BuildContext context) {
    final cubit = context.read<GlobalMusicPlayerCubit>();
    final playlistInfo = cubit.currentPlaylistInfo;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.playlist_remove, color: Colors.orange),
            const SizedBox(width: 12),
            Text('Exit Playlist Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Currently playing from: $playlistInfo',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              'Exit playlist mode and switch to random play mode?',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Your current song will continue playing.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
              cubit.exitPlaylistMode();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.shuffle, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text('Switched to random play mode'),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Exit Playlist', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
