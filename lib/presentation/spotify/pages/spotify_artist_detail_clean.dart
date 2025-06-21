import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/presentation/spotify/bloc/spotify_artist_cubit.dart';
import 'package:sporify/presentation/spotify/bloc/spotify_artist_state.dart';

class SpotifyArtistDetailPageClean extends StatefulWidget {
  final SpotifyArtistEntity artist;

  const SpotifyArtistDetailPageClean({super.key, required this.artist});

  @override
  State<SpotifyArtistDetailPageClean> createState() =>
      _SpotifyArtistDetailPageCleanState();
}

class _SpotifyArtistDetailPageCleanState
    extends State<SpotifyArtistDetailPageClean> {
  Future<void> _playPreview(String url) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would play preview: ${url.split('/').last}'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openInSpotify(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open Spotify'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SpotifyArtistCubit()..getArtistTopTracks(widget.artist.id),
      child: Scaffold(
        backgroundColor: context.isDarkMode ? Colors.black : Colors.grey[50],
        body: CustomScrollView(
          slivers: [
            // Custom app bar with artist image
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.artist.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.artist.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.artist.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppColors.primary,
                                  child: Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                ),
                          )
                        : Container(
                            color: AppColors.primary,
                            child: Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Artist details
            SliverToBoxAdapter(child: _buildArtistDetails()),

            // Top tracks
            SliverToBoxAdapter(child: _buildTopTracks()),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Followers
          Row(
            children: [
              Icon(Icons.people, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_formatNumber(widget.artist.followers)} followers',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Genres
          if (widget.artist.genres.isNotEmpty) ...[
            Text(
              'Genres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.artist.genres
                  .take(6)
                  .map(
                    (genre) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Open in Spotify button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openInSpotify(widget.artist.spotifyUrl),
              icon: Icon(Icons.open_in_new, color: Colors.white),
              label: Text(
                'Open in Spotify',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1DB954), // Spotify green
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTracks() {
    return BlocBuilder<SpotifyArtistCubit, SpotifyArtistState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Tracks',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              if (state is SpotifyArtistLoading)
                _buildLoadingState()
              else if (state is SpotifyArtistError)
                _buildErrorState(state.message)
              else if (state is SpotifyArtistTopTracksLoaded)
                _buildTracksList(state.tracks)
              else
                _buildEmptyState(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Loading top tracks...',
              style: TextStyle(
                color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load tracks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<SpotifyArtistCubit>()
                  .getArtistTopTracks(widget.artist.id),
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Text(
          'No tracks available',
          style: TextStyle(
            fontSize: 16,
            color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTracksList(List<SpotifyTrackEntity> tracks) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return _buildTrackTile(track, index + 1);
      },
    );
  }

  Widget _buildTrackTile(SpotifyTrackEntity track, int trackNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: track.albumImageUrl.isNotEmpty
                    ? Image.network(
                        track.albumImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.music_note, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.music_note, color: Colors.grey),
                      ),
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$trackNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          track.name,
          style: TextStyle(
            color: context.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              track.albumName,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (track.artists.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                track.artists.join(', '),
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (track.previewUrl != null)
              IconButton(
                icon: Icon(
                  Icons.play_circle_fill,
                  color: AppColors.primary,
                  size: 32,
                ),
                onPressed: () => _playPreview(track.previewUrl!),
              ),
            IconButton(
              icon: Icon(Icons.open_in_new, color: Color(0xFF1DB954), size: 24),
              onPressed: () => _openInSpotify(track.spotifyUrl),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
