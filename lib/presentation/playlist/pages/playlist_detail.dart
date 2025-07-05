import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/common/widgets/favorite_button/favorite_button.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/core/constants/app_urls.dart';
import 'package:sporify/data/models/playlist/playlist.dart';
import 'package:sporify/data/repositories/playlist_repository.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/presentation/playlist/bloc/playlist_cubit.dart';
import 'package:sporify/presentation/playlist/bloc/playlist_songs_cubit.dart';
import 'package:sporify/presentation/playlist/bloc/playlist_songs_state.dart';
import 'package:sporify/presentation/song_player/pages/song_player.dart';
import 'package:sporify/presentation/playlist/widgets/playlist_options_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sporify/core/configs/cache/cache_config.dart';

class PlaylistDetailPage extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PlaylistCubit(PlaylistRepository())),
        BlocProvider(
          create: (context) =>
              PlaylistSongsCubit()..loadPlaylistSongs(widget.playlist.songIds),
        ),
      ],
      child: Scaffold(
        appBar: BasicAppBar(
          title: Text('Playlist', style: TextStyle(fontSize: 18)),
          action: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'options') {
                _showPlaylistOptions();
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
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildPlaylistHeader(),
              _buildPlayAllButton(),
              Expanded(child: _buildSongsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: widget.playlist.coverImageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: widget.playlist.coverImageUrl,
                      cacheManager: ImageCacheConfig.imageCacheManager,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.primary.withOpacity(0.2),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primary.withOpacity(0.2),
                        child: Icon(
                          Icons.queue_music,
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.primary.withOpacity(0.2),
                    child: Icon(
                      Icons.queue_music,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.playlist.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.playlist.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.playlist.description,
              style: TextStyle(
                fontSize: 16,
                color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          BlocBuilder<PlaylistSongsCubit, PlaylistSongsState>(
            builder: (context, state) {
              int songCount = 0;
              if (state is PlaylistSongsLoaded) {
                songCount = state.songs.length;
              }
              return Text(
                '$songCount songs',
                style: TextStyle(
                  fontSize: 14,
                  color: context.isDarkMode ? Colors.white60 : Colors.grey[500],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayAllButton() {
    return BlocBuilder<PlaylistSongsCubit, PlaylistSongsState>(
      builder: (context, state) {
        if (state is PlaylistSongsLoaded && state.songs.isNotEmpty) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton.icon(
              onPressed: () => _playAllSongs(state.songs),
              icon: Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                'Play All',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildSongsList() {
    return BlocBuilder<PlaylistSongsCubit, PlaylistSongsState>(
      builder: (context, state) {
        if (state is PlaylistSongsLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is PlaylistSongsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading songs',
                  style: TextStyle(
                    fontSize: 18,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.isDarkMode ? Colors.white70 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<PlaylistSongsCubit>()
                      .loadPlaylistSongs(widget.playlist.songIds),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is PlaylistSongsLoaded) {
          if (state.songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_off,
                    size: 64,
                    color: context.isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No songs in this playlist',
                    style: TextStyle(
                      fontSize: 18,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add songs to start listening',
                    style: TextStyle(
                      fontSize: 14,
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
              return _buildSongTile(state.songs[index], state.songs, index);
            },
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget _buildSongTile(SongEntity song, List<SongEntity> allSongs, int index) {
    final imageUrl = AppUrls.getImageUrl(song.artist, song.title, song.image);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            FavoriteButton(songEntity: song),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'remove') {
                  _removeSongFromPlaylist(song);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.remove, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: Icon(
                Icons.more_vert,
                color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
        onTap: () => _playSong(song, allSongs, index),
      ),
    );
  }

  void _playAllSongs(List<SongEntity> songs) {
    if (songs.isNotEmpty) {
      context.read<GlobalMusicPlayerCubit>().loadSong(
        songs[0],
        songList: songs,
        playlistName: widget.playlist.name,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SongPlayerPage(songEntity: songs[0]),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.playlist_play, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                'Playing playlist: ${widget.playlist.name}',
                style: TextStyle(
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
    }
  }

  void _playSong(SongEntity song, List<SongEntity> allSongs, int index) {
    context.read<GlobalMusicPlayerCubit>().loadSong(
      song,
      songList: allSongs,
      playlistName: widget.playlist.name,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SongPlayerPage(songEntity: song)),
    );
  }

  void _removeSongFromPlaylist(SongEntity song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Song'),
        content: Text('Remove "${song.title}" from this playlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<PlaylistCubit>().removeSongFromPlaylist(
                  widget.playlist.id,
                  song.songId,
                );

                // Reload playlist songs
                context.read<PlaylistSongsCubit>().loadPlaylistSongs(
                  widget.playlist.songIds..remove(song.songId),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Song removed from playlist'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to remove song'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeletePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Playlist'),
        content: Text(
          'Are you sure you want to delete "${widget.playlist.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await context.read<PlaylistCubit>().deletePlaylist(
                  widget.playlist.id,
                );
                Navigator.pop(context); // Go back to previous page

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

  void _showPlaylistOptions() {
    showDialog(
      context: context,
      builder: (context) => PlaylistOptionsDialog(
        playlist: widget.playlist,
        onUpdate: () {
          // Refresh current page data if needed
          setState(() {});
        },
        onDelete: () => _showDeletePlaylistDialog(),
      ),
    );
  }
}
