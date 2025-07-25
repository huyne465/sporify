import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/base_widgets/app_bar/app_bar.dart';
import 'package:sporify/common/base_widgets/favorite_button/favorite_button.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/core/constants/app_urls.dart';
import 'package:sporify/domain/repository/favorite/favorite_songs_repository.dart';
import 'package:sporify/domain/repository/playlist/playlist_repository.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/core/configs/cache/cache_config.dart';
import 'package:sporify/presentation/favorite/bloc/favorite_songs_cubit.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/presentation/music_player/widgets/mini_player.dart';
import 'package:sporify/presentation/playlist/bloc/playlist_cubit.dart';
import 'package:sporify/presentation/playlist/pages/playlist_detail.dart';
import 'package:sporify/presentation/playlist/widgets/create_playlist_dialog.dart';
import 'package:sporify/presentation/playlist/widgets/playlist_options_dialog.dart';
import 'package:sporify/presentation/song_player/pages/song_player.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              FavoriteSongsCubit(FavoriteSongsRepository())
                ..listenToFavoriteSongs(),
        ),
        BlocProvider(
          create: (context) =>
              PlaylistCubit(PlaylistRepository())..listenToPlaylists(),
        ),
      ],
      child: Scaffold(
        appBar: BasicAppBar(
          hideback: true,
          title: Text(
            'Your Library',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: context.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                  tabs: const [
                    Tab(text: 'Liked Songs'),
                    Tab(text: 'Playlists'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildFavoriteSongsTab(), _buildPlaylistsTab()],
                ),
              ),
              const SizedBox(height: 80), // Space for mini player
            ],
          ),
        ),
        bottomNavigationBar: const MiniPlayer(),
      ),
    );
  }

  Widget _buildFavoriteSongsTab() {
    return BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
      builder: (context, state) {
        if (state is FavoriteSongsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FavoriteSongsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: context.isDarkMode ? Colors.white54 : Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  'Error loading songs',
                  style: TextStyle(
                    fontSize: 20,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.isDarkMode ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is FavoriteSongsLoaded) {
          if (state.songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 80,
                    color: context.isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Favorite Songs',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your liked songs will appear here',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.songs.length,
            itemBuilder: (context, index) {
              final song = state.songs[index];
              return _buildSongTile(context, song);
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildPlaylistsTab() {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        if (state is PlaylistLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PlaylistError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: context.isDarkMode ? Colors.white54 : Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  'Error loading playlists',
                  style: TextStyle(
                    fontSize: 20,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is PlaylistLoaded) {
          return Column(
            children: [
              // Create playlist button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => _showCreatePlaylistDialog(context),
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Create Playlist',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              if (state.playlists.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.queue_music,
                          size: 80,
                          color: context.isDarkMode
                              ? Colors.white54
                              : Colors.grey,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No Playlists Yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Create your first playlist',
                          style: TextStyle(
                            fontSize: 16,
                            color: context.isDarkMode
                                ? Colors.white70
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = state.playlists[index];
                      return _buildPlaylistTile(context, playlist);
                    },
                  ),
                ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSongTile(BuildContext context, SongEntity song) {
    final imageUrl = AppUrls.getImageUrl(song.artist, song.title, song.image);

    return BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
      builder: (context, state) {
        // Get songs list from state
        List<SongEntity> songsList = [];
        if (state is FavoriteSongsLoaded) {
          songsList = state.songs;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.music_note, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            title: Text(
              song.title,
              style: TextStyle(
                color: context.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artist,
              style: TextStyle(
                color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FavoriteButton(songEntity: song, showPlaylistButton: true),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.play_arrow,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    context.read<GlobalMusicPlayerCubit>().loadSong(
                      song,
                      songList: songsList,
                      playlistName: "Liked Songs",
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongPlayerPage(songEntity: song),
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Playing from Liked Songs',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              context.read<GlobalMusicPlayerCubit>().loadSong(
                song,
                songList: songsList,
                playlistName: "Liked Songs",
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongPlayerPage(songEntity: song),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaylistTile(BuildContext context, playlist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: playlist.coverImageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: playlist.coverImageUrl,
                    cacheManager: ImageCacheConfig.imageCacheManager,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.primary.withOpacity(0.2),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.queue_music,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: AppColors.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.queue_music,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
        ),
        title: Text(
          playlist.name,
          style: TextStyle(
            color: context.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${playlist.songCount} songs',
              style: TextStyle(
                color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (playlist.description.isNotEmpty)
              Text(
                playlist.description,
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white60 : Colors.grey[500],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'options') {
              _showPlaylistOptions(context, playlist);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'options',
              child: Row(
                children: [
                  Icon(Icons.more_horiz, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Options'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistDetailPage(playlist: playlist),
            ),
          );
        },
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CreatePlaylistDialog(
        onCreatePlaylist: (name, description, {String? coverImageUrl}) async {
          final cubit = context.read<PlaylistCubit>();
          await cubit.createPlaylist(
            name: name,
            description: description,
            coverImageUrl: coverImageUrl ?? '',
          );
        },
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, playlist) {
    showDialog(
      context: context,
      builder: (context) => PlaylistOptionsDialog(
        playlist: playlist,
        onUpdate: () {
          // Refresh playlists
          context.read<PlaylistCubit>().listenToPlaylists();
        },
        onDelete: () => _deletePlaylist(context, playlist.id, playlist.name),
      ),
    );
  }

  void _deletePlaylist(
    BuildContext context,
    String playlistId,
    String playlistName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "$playlistName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<PlaylistCubit>().deletePlaylist(playlistId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Playlist deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete playlist'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
