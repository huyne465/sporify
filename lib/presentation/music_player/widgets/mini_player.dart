import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/core/constants/app_urls.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_state.dart';
import 'package:sporify/presentation/song_player/pages/song_player.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalMusicPlayerCubit, GlobalMusicPlayerState>(
      builder: (context, state) {
        if (state.currentSong == null) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<GlobalMusicPlayerCubit>();
        final imageUrl = AppUrls.getImageUrl(
          state.currentSong!.artist,
          state.currentSong!.title,
          state.currentSong!.image,
        );

        return Container(
          height: 70,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Song artwork
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SongPlayerPage(songEntity: state.currentSong!),
                    ),
                  );
                },
                child: Container(
                  width: 54,
                  height: 54,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    ),
                  ),
                  child: state.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                ),
              ),

              // Song info
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SongPlayerPage(songEntity: state.currentSong!),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.currentSong!.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        state.currentSong!.artist,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Control buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Previous button
                  IconButton(
                    onPressed:
                        cubit.playlist.isNotEmpty && cubit.currentSongIndex > 0
                        ? () => cubit.playPrevious()
                        : null,
                    icon: Icon(
                      Icons.skip_previous,
                      color:
                          cubit.playlist.isNotEmpty &&
                              cubit.currentSongIndex > 0
                          ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                          : Colors.grey,
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 36,
                      height: 36,
                    ),
                  ),

                  // Play/Pause button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => cubit.playOrPause(),
                      icon: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),

                  // Next button
                  IconButton(
                    onPressed:
                        cubit.playlist.isNotEmpty &&
                            cubit.currentSongIndex < cubit.playlist.length - 1
                        ? () => cubit.playNext()
                        : null,
                    icon: Icon(
                      Icons.skip_next,
                      color:
                          cubit.playlist.isNotEmpty &&
                              cubit.currentSongIndex < cubit.playlist.length - 1
                          ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                          : Colors.grey,
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 36,
                      height: 36,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }
}
