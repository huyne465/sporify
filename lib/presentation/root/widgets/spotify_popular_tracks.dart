import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/domain/usecases/spotify/get_popular_tracks.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/service_locator.dart';
import 'package:sporify/presentation/spotify/bloc/spotify_player_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyPopularTracks extends StatefulWidget {
  const SpotifyPopularTracks({super.key});

  @override
  State<SpotifyPopularTracks> createState() => _SpotifyPopularTracksState();
}

class _SpotifyPopularTracksState extends State<SpotifyPopularTracks> {
  List<SpotifyTrackEntity> tracks = [];
  bool isLoading = true;
  String? error;
  late SpotifyPlayerCubit _spotifyPlayerCubit;
  String? _currentPlayingTrackId;

  @override
  void initState() {
    super.initState();
    _spotifyPlayerCubit = sl<SpotifyPlayerCubit>();
    _loadPopularTracks();
  }

  @override
  void dispose() {
    _spotifyPlayerCubit.close();
    super.dispose();
  }

  Future<void> _loadPopularTracks() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final loadedTracks = await sl<GetPopularTracksUseCase>().call();

      setState(() {
        tracks = loadedTracks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load popular tracks',
              style: TextStyle(
                color: context.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadPopularTracks,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (tracks.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No tracks found',
          style: TextStyle(
            color: context.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: _spotifyPlayerCubit,
      child: BlocListener<SpotifyPlayerCubit, SpotifyPlayerState>(
        listener: (context, state) {
          if (state is SpotifyPlayerPlaying) {
            setState(() {
              _currentPlayingTrackId = state.trackId;
            });

            final track = tracks.firstWhere((t) => t.id == state.trackId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.play_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Playing 30s preview: ${track.name}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Color(0xFF1DB954),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is SpotifyPlayerError) {
            setState(() {
              _currentPlayingTrackId = null;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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
          } else if (state is SpotifyPlayerStopped ||
              state is SpotifyPlayerPaused) {
            setState(() {
              _currentPlayingTrackId = null;
            });
          }
        },
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            return _buildTrackTile(context, tracks[index], index + 1);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemCount: tracks.length > 10 ? 10 : tracks.length,
        ),
      ),
    );
  }

  Widget _buildTrackTile(
    BuildContext context,
    SpotifyTrackEntity track,
    int rank,
  ) {
    final isCurrentlyPlaying = _currentPlayingTrackId == track.id;

    return GestureDetector(
      onTap: () => _showTrackOptionsDialog(context, track),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentlyPlaying
              ? AppColors.primary.withOpacity(0.1)
              : context.isDarkMode
              ? Colors.grey[900]?.withOpacity(0.5)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: isCurrentlyPlaying
              ? Border.all(color: AppColors.primary, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                track.albumImageUrl.isNotEmpty
                    ? track.albumImageUrl
                    : 'https://via.placeholder.com/50',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artists.join(', '),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            BlocBuilder<SpotifyPlayerCubit, SpotifyPlayerState>(
              builder: (context, state) {
                final isLoading = state is SpotifyPlayerLoading;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _handlePlayPause(track),
                      child: isLoading && _currentPlayingTrackId == track.id
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isCurrentlyPlaying
                                  ? Icons.pause_circle_filled
                                  : (track.previewUrl != null &&
                                        track.previewUrl!.isNotEmpty)
                                  ? Icons.play_circle_fill
                                  : Icons.play_circle_outline,
                              color:
                                  (track.previewUrl != null &&
                                      track.previewUrl!.isNotEmpty)
                                  ? AppColors.primary
                                  : Colors.orange,
                              size: 28,
                            ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _launchSpotifyUrl(track.spotifyUrl),
                      child: Icon(
                        Icons.open_in_new,
                        color: context.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                        size: 20,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handlePlayPause(SpotifyTrackEntity track) async {
    if (_currentPlayingTrackId == track.id) {
      await _spotifyPlayerCubit.stop();
    } else {
      if (track.previewUrl != null && track.previewUrl!.isNotEmpty) {
        await _spotifyPlayerCubit.playTrack(track.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No preview available for "${track.name}". Open in Spotify to listen.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'Open Spotify',
              textColor: Colors.white,
              onPressed: () => _launchSpotifyUrl(track.spotifyUrl),
            ),
          ),
        );
      }
    }
  }

  void _showTrackOptionsDialog(BuildContext context, SpotifyTrackEntity track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(track.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                track.albumImageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: Icon(Icons.music_note, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('by ${track.artists.join(', ')}'),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                track.previewUrl != null && track.previewUrl!.isNotEmpty
                    ? Icons.play_circle
                    : Icons.info_outline,
                color: track.previewUrl != null && track.previewUrl!.isNotEmpty
                    ? AppColors.primary
                    : Colors.orange,
              ),
              title: Text(
                track.previewUrl != null && track.previewUrl!.isNotEmpty
                    ? 'Play 30s Preview'
                    : 'No Preview Available',
              ),
              subtitle: Text(
                track.previewUrl != null && track.previewUrl!.isNotEmpty
                    ? '30 second preview'
                    : 'Open in Spotify to listen',
              ),
              onTap: () {
                Navigator.pop(context);
                _handlePlayPause(track);
              },
            ),
            ListTile(
              leading: Icon(Icons.open_in_new, color: Colors.green),
              title: Text('Open in Spotify'),
              subtitle: Text('Full track playback'),
              onTap: () {
                Navigator.pop(context);
                _launchSpotifyUrl(track.spotifyUrl);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.blue),
              title: Text('Share Track'),
              subtitle: Text('Share this track'),
              onTap: () {
                Navigator.pop(context);
                _shareTrack(context, track);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchSpotifyUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Could not launch $url: $e');
    }
  }

  Future<void> _shareTrack(
    BuildContext context,
    SpotifyTrackEntity track,
  ) async {
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
              'Share Track',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${track.name} by ${track.artists.join(', ')}',
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
                  onTap: () => _shareTrackToFacebook(context, track),
                ),
                _buildShareOption(
                  context,
                  icon: Icons.message,
                  label: 'WhatsApp',
                  color: Colors.green,
                  onTap: () => _shareTrackToWhatsApp(context, track),
                ),
                _buildShareOption(
                  context,
                  icon: Icons.telegram,
                  label: 'Telegram',
                  color: Colors.cyan,
                  onTap: () => _shareTrackToTelegram(context, track),
                ),
                _buildShareOption(
                  context,
                  icon: Icons.more_horiz,
                  label: 'More',
                  color: Colors.grey,
                  onTap: () => _shareTrackGeneric(context, track),
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

  Future<void> _shareTrackToFacebook(
    BuildContext context,
    SpotifyTrackEntity track,
  ) async {
    try {
      Navigator.pop(context);

      final content =
          '🎵 Check out "${track.name}" by ${track.artists.join(", ")} on Spotify: ${track.spotifyUrl}';

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
          _shareTrackGeneric(context, track);
        },
      );
    } catch (e) {
      await _shareTrackGeneric(context, track);
    }
  }

  Future<void> _shareTrackToWhatsApp(
    BuildContext context,
    SpotifyTrackEntity track,
  ) async {
    try {
      Navigator.pop(context);

      final content =
          '🎵 Check out "${track.name}" by ${track.artists.join(", ")} on Spotify: ${track.spotifyUrl}';

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
          _shareTrackGeneric(context, track);
        },
      );
    } catch (e) {
      await _shareTrackGeneric(context, track);
    }
  }

  Future<void> _shareTrackToTelegram(
    BuildContext context,
    SpotifyTrackEntity track,
  ) async {
    try {
      Navigator.pop(context);

      final content =
          '🎵 Check out "${track.name}" by ${track.artists.join(", ")} on Spotify: ${track.spotifyUrl}';

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
          _shareTrackGeneric(context, track);
        },
      );
    } catch (e) {
      await _shareTrackGeneric(context, track);
    }
  }

  Future<void> _shareTrackGeneric(
    BuildContext context,
    SpotifyTrackEntity track,
  ) async {
    try {
      Navigator.pop(context);

      await Share.share(
        '🎵 Check out "${track.name}" by ${track.artists.join(", ")} on Spotify: ${track.spotifyUrl}',
        subject: 'Great song recommendation',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share track'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
