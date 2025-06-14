import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/common/widgets/favorite_button/favorite_button.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/core/constants/app_urls.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/presentation/music_player/widgets/mini_player.dart';
import 'package:sporify/presentation/search/bloc/search_cubit.dart';
import 'package:sporify/presentation/search/bloc/search_state.dart';
import 'package:sporify/presentation/song_player/pages/song_player.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: Scaffold(
        appBar: BasicAppBar(
          hideback: true,
          title: Text(
            'Search',
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
              _buildSearchBar(),
              Expanded(child: _buildSearchResults()),
              const SizedBox(height: 80), // Space for mini player
            ],
          ),
        ),
        bottomNavigationBar: const MiniPlayer(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: context.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: (value) {
              context.read<SearchCubit>().searchSongs(value);
              setState(() {}); // Rebuild to show/hide clear button
            },
            decoration: InputDecoration(
              hintText: 'What do you want to listen to?',
              hintStyle: TextStyle(
                color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              prefixIcon: Icon(
                Icons.search,
                color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: context.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SearchCubit>().clearSearch();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
            style: TextStyle(
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is SearchEmpty) {
          return _buildEmptyState(state.query);
        }

        if (state is SearchFailure) {
          return _buildErrorState(state.message);
        }

        if (state is SearchLoaded) {
          if (state.query.isEmpty) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'All Songs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${state.songs.length} songs',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildResultsList(state.songs)),
              ],
            );
          }
          return _buildResultsList(state.songs);
        }

        return _buildInitialState();
      },
    );
  }

  Widget _buildInitialState() {
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
            'Loading Songs...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Please wait while we load your music',
            style: TextStyle(
              fontSize: 16,
              color: context.isDarkMode ? Colors.white70 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off,
            size: 80,
            color: context.isDarkMode ? Colors.white54 : Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No songs found for "$query"',
            style: TextStyle(
              fontSize: 16,
              color: context.isDarkMode ? Colors.white70 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
          const SizedBox(height: 20),
          Text(
            'Search Failed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: context.isDarkMode ? Colors.white70 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<SongEntity> songs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return _buildSongTile(songs[index]);
      },
    );
  }

  Widget _buildSongTile(SongEntity song) {
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
              onPressed: () => _playSong(song),
            ),
          ],
        ),
        onTap: () => _playSong(song),
      ),
    );
  }

  void _playSong(SongEntity song) {
    // Load song in global music player
    context.read<GlobalMusicPlayerCubit>().loadSong(song);

    // Navigate to song player
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SongPlayerPage(songEntity: song)),
    );

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.music_note, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              'Playing ${song.title}',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
