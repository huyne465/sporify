import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/common/widgets/favorite_button/favorite_button.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/core/constants/app_urls.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:sporify/presentation/song_player/bloc/song_player_state.dart';

class SongPlayerPage extends StatefulWidget {
  final SongEntity songEntity;
  const SongPlayerPage({super.key, required this.songEntity});

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SongPlayerCubit();
        // Load the song URL from Firestore
        // Load the song URL from Firestore and seek to saved position if same song
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cubit.LoadSong(widget.songEntity.songUrl);
        });
        cubit.LoadSong(widget.songEntity.songUrl);
        return cubit;
      },
      child: Scaffold(
        appBar: BasicAppBar(
          title: Text('Now Playing', style: TextStyle(fontSize: 18)),
          action: IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert_rounded),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [_songDetail(context), _buildPlayerControls()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _songDetail(BuildContext context) {
    final imageUrl = AppUrls.getImageUrl(
      widget.songEntity.artist,
      widget.songEntity.title,
      widget.songEntity.image,
    );

    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.width - 10,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(imageUrl),
              onError: (exception, stackTrace) =>
                  const AssetImage('assets/images/default_cover.png'),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.songEntity.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            FavoriteButton(songEntity: widget.songEntity),
          ],
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.songEntity.artist,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls() {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        final cubit = context.read<SongPlayerCubit>();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              // Progress bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.grey[300],
                  trackHeight: 4.0,
                  thumbColor: AppColors.primary,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8.0,
                  ),
                  overlayColor: AppColors.primary.withAlpha(32),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16.0,
                  ),
                ),
                child: Slider(
                  value: cubit.songPosition.inSeconds.toDouble(),
                  max: cubit.songDuration.inSeconds.toDouble() == 0
                      ? widget.songEntity.duration.toDouble()
                      : cubit.songDuration.inSeconds.toDouble(),
                  onChanged: (value) {
                    cubit.audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),

              // Duration display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(cubit.songPosition),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      _formatDuration(
                        cubit.songDuration.inSeconds > 0
                            ? cubit.songDuration
                            : Duration(
                                seconds: widget.songEntity.duration.toInt(),
                              ),
                      ),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Playback controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous, size: 36),
                    onPressed: () {
                      // Previous song functionality
                    },
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        cubit.audioPlayer.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        cubit.PlayOrPauseSong();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next, size: 36),
                    onPressed: () {
                      // Next song functionality
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Additional controls (shuffle, repeat, etc.)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.shuffle, color: Colors.grey[600]),
                    onPressed: () {
                      // Shuffle functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.repeat, color: Colors.grey[600]),
                    onPressed: () {
                      // Repeat functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.playlist_add, color: Colors.grey[600]),
                    onPressed: () {
                      // Add to playlist functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.grey[600]),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
