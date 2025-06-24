import 'package:flutter/material.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/domain/usecases/spotify/get_popular_tracks.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/service_locator.dart';
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

  @override
  void initState() {
    super.initState();
    _loadPopularTracks();
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
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
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

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return _buildTrackTile(context, tracks[index], index + 1);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: tracks.length > 10 ? 10 : tracks.length,
    );
  }

  Widget _buildTrackTile(
    BuildContext context,
    SpotifyTrackEntity track,
    int rank,
  ) {
    return GestureDetector(
      onTap: () => _launchSpotifyUrl(track.spotifyUrl),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? Colors.grey[900]?.withOpacity(0.5)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
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
            if (track.previewUrl != null)
              Icon(
                Icons.play_circle_outline,
                color: AppColors.primary,
                size: 24,
              )
            else
              Icon(
                Icons.open_in_new,
                color: context.isDarkMode ? Colors.white70 : Colors.black54,
                size: 20,
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
}
