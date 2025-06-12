import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/common/widgets/favorite_button/favorite_button.dart';
import 'package:sporify/core/constants/app_urls.dart';
import 'package:sporify/data/repositories/favorite_songs_repository.dart';
import 'package:sporify/presentation/favorite/bloc/favorite_songs_cubit.dart';
import 'package:sporify/presentation/music_player/widgets/mini_player.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/presentation/song_player/pages/song_player.dart';
import 'package:sporify/domain/entities/songs/song.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FavoriteSongsCubit(FavoriteSongsRepository())
            ..listenToFavoriteSongs(),
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
              Expanded(
                child: BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
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
                              color: context.isDarkMode
                                  ? Colors.white54
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Error loading songs',
                              style: TextStyle(
                                fontSize: 20,
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              state.message,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.isDarkMode
                                    ? Colors.white70
                                    : Colors.grey,
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
                                color: context.isDarkMode
                                    ? Colors.white54
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Favorite Songs',
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
                                'Your liked songs will appear here',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: context.isDarkMode
                                      ? Colors.white70
                                      : Colors.grey,
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

  Widget _buildSongTile(BuildContext context, SongEntity song) {
    final imageUrl = AppUrls.getImageUrl(song.artist, song.title, song.image);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[50],
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
            FavoriteButton(songEntity: song),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.play_arrow,
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () {
                // Load song in global music player
                context.read<GlobalMusicPlayerCubit>().loadSong(song);

                // Navigate to song player
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongPlayerPage(songEntity: song),
                  ),
                );

                // Show feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Playing ${song.title}'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () {
          // Load song and navigate on tile tap
          context.read<GlobalMusicPlayerCubit>().loadSong(song);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongPlayerPage(songEntity: song),
            ),
          );
        },
      ),
    );
  }
}
