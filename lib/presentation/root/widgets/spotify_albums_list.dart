import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/domain/usecases/spotify/get_popular_albums.dart';
import 'package:sporify/service_locator.dart';

class SpotifyAlbumsList extends StatefulWidget {
  const SpotifyAlbumsList({super.key});

  @override
  State<SpotifyAlbumsList> createState() => _SpotifyAlbumsListState();
}

class _SpotifyAlbumsListState extends State<SpotifyAlbumsList> {
  List<SpotifyAlbumEntity> albums = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('🎵 Loading albums...');

      // Kiểm tra xem UseCase đã được đăng ký chưa
      if (!sl.isRegistered<GetPopularAlbumsUseCase>()) {
        throw Exception(
          'GetPopularAlbumsUseCase chưa được đăng ký trong service locator',
        );
      }

      final loadedAlbums = await sl<GetPopularAlbumsUseCase>().call();
      print('✅ Loaded ${loadedAlbums.length} albums');

      setState(() {
        albums = loadedAlbums;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading albums: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (error != null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load albums',
              style: TextStyle(
                color: context.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadAlbums,
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

    if (albums.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No albums found',
          style: TextStyle(
            color: context.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return _buildAlbumCard(context, albums[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemCount: albums.length,
      ),
    );
  }

  Widget _buildAlbumCard(BuildContext context, SpotifyAlbumEntity album) {
    return GestureDetector(
      onTap: () => _launchSpotifyUrl(album.spotifyUrl),
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Giảm height của image container
            Container(
              height: 140, // Giảm từ 160 xuống 140
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      album.imageUrl.isNotEmpty
                          ? album.imageUrl
                          : 'https://via.placeholder.com/160',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.album, size: 60, color: Colors.grey),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.play_circle_fill,
                            color: AppColors.primary,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8), // Giảm từ 10 xuống 8
            // Wrap text trong Expanded để tránh overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13, // Giảm font size từ 14 xuống 13
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2), // Giảm từ 4 xuống 2
                  // Hiển thị artist name nếu có
                  if (album.artists.isNotEmpty)
                    Text(
                      album.artists.first,
                      style: TextStyle(
                        fontSize: 11, // Giảm từ 12 xuống 11
                        color: context.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 1), // Giảm từ 2 xuống 1
                  Text(
                    '${album.totalTracks} tracks',
                    style: TextStyle(
                      fontSize: 10, // Giảm từ 11 xuống 10
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
