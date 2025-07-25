import 'package:flutter/material.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/presentation/playlist/widgets/add_to_playlist_dialog.dart';

class AddToPlaylistButton extends StatelessWidget {
  final SongEntity song;
  final double size;

  const AddToPlaylistButton({super.key, required this.song, this.size = 25});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AddToPlaylistDialog(song: song),
        );
      },
      icon: Icon(Icons.playlist_add, size: size, color: AppColors.darkGrey),
      tooltip: 'Add to playlist',
    );
  }
}
