import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/common/widgets/favorite_button/favorite_button.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/core/constants/app_urls.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/presentation/music_player/widgets/mini_player.dart';
import 'package:sporify/presentation/search/bloc/search_cubit.dart';
import 'package:sporify/presentation/search/bloc/search_state.dart';
import 'package:sporify/presentation/song_player/pages/song_player.dart';
import 'package:sporify/presentation/spotify/pages/spotify_artist_detail_clean.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: Builder(
        builder: (providerContext) => Scaffold(
          appBar: BasicAppBar(
            title: Text('Search', style: TextStyle(fontSize: 18)),
            hideback: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search input
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search songs or artists...',
                      hintStyle: TextStyle(
                        color: context.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                providerContext
                                    .read<SearchCubit>()
                                    .clearSearch();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    style: TextStyle(
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                    onSubmitted: (query) {
                      if (query.isEmpty) return;

                      final cubit = providerContext.read<SearchCubit>();
                      if (_tabController.index == 0) {
                        cubit.searchSongs(query);
                      } else {
                        cubit.searchSpotifyArtists(query);
                      }
                    },
                    onChanged: (query) {
                      setState(() {});
                    },
                  ),
                ),

                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: context.isDarkMode
                        ? Colors.white
                        : Colors.black,
                    unselectedLabelColor: context.isDarkMode
                        ? Colors.white60
                        : Colors.black45,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'Songs'),
                      Tab(text: 'Spotify Artists'),
                    ],
                    onTap: (index) {
                      if (_searchController.text.isNotEmpty) {
                        final query = _searchController.text;
                        if (query.isEmpty) return;

                        final cubit = providerContext.read<SearchCubit>();
                        if (index == 0) {
                          cubit.searchSongs(query);
                        } else {
                          cubit.searchSpotifyArtists(query);
                        }
                      }
                    },
                  ),
                ),

                // Search results
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildSongsTab(), _buildSpotifyArtistsTab()],
                  ),
                ),
                const SizedBox(height: 80), // Space for mini player
              ],
            ),
          ),
          bottomNavigationBar: const MiniPlayer(),
        ),
      ),
    );
  }

  Widget _buildSongsTab() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchInitial) {
          return _buildEmptyState('Search for songs...');
        }

        if (state is SearchLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state is SearchFailure) {
          return _buildErrorState(state.message, () {
            final cubit = context.read<SearchCubit>();
            if (_searchController.text.isNotEmpty) {
              cubit.searchSongs(_searchController.text);
            }
          });
        }

        if (state is SearchLoaded) {
          if (state.songs.isEmpty) {
            return _buildEmptyState('No songs found');
          }
          return _buildSongsList(state.songs);
        }

        return _buildEmptyState('Search for songs...');
      },
    );
  }

  Widget _buildSpotifyArtistsTab() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchInitial) {
          return _buildEmptyState('Search for artists on Spotify...');
        }

        if (state is SearchLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state is SearchFailure) {
          return _buildErrorState(state.message, () {
            final cubit = context.read<SearchCubit>();
            if (_searchController.text.isNotEmpty) {
              cubit.searchSpotifyArtists(_searchController.text);
            }
          });
        }

        if (state is SearchSpotifyArtistsLoaded) {
          if (state.artists.isEmpty) {
            return _buildEmptyState('No artists found');
          }
          return _buildArtistsList(state.artists);
        }

        return _buildEmptyState('Search for artists on Spotify...');
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: context.isDarkMode ? Colors.white54 : Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: context.isDarkMode ? Colors.white70 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
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
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
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

  Widget _buildArtistsList(List<SpotifyArtistEntity> artists) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SpotifyArtistDetailPageClean(artist: artist),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: context.isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: artist.imageUrl.isNotEmpty
                      ? Image.network(
                          artist.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.person, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.person, color: Colors.grey),
                        ),
                ),
              ),
              title: Text(
                artist.name,
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
                    '${_formatFollowers(artist.followers)} followers',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (artist.genres.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      artist.genres.take(2).join(', '),
                      style: TextStyle(
                        color: context.isDarkMode
                            ? Colors.white70
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: context.isDarkMode ? Colors.white54 : Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }

  Widget _buildSongsList(List<SongEntity> songs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final imageUrl = AppUrls.getImageUrl(
          song.artist,
          song.title,
          song.image,
        );

        return GestureDetector(
          onTap: () {
            // Load song in global music player
            context.read<GlobalMusicPlayerCubit>().loadSong(
              song,
              songList: songs,
            );

            // Navigate to song player
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    SongPlayerPage(songEntity: song),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: context.isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.music_note, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              title: Text(
                song.title,
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
                    song.artist,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(song.duration / 60).floor()}:${(song.duration % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: context.isDarkMode
                          ? Colors.white70
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FavoriteButton(songEntity: song),
                  Icon(
                    Icons.play_circle_outline,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
