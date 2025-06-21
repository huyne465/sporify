import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/common/bloc/favorite_button/favorite_button_cubit.dart';
import 'package:sporify/common/bloc/favorite_button/favorite_button_state.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/domain/entities/songs/song.dart';
import 'package:sporify/common/widgets/playlist_button/add_to_playlist_button.dart';

class FavoriteButton extends StatelessWidget {
  final SongEntity songEntity;
  final bool showPlaylistButton;
  const FavoriteButton({
    required this.songEntity,
    this.showPlaylistButton = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = FavoriteButtonCubit();
        // Khởi tạo với trạng thái hiện tại
        cubit.init(songEntity.songId);
        return cubit;
      },
      child: BlocBuilder<FavoriteButtonCubit, FavoriteButtonState>(
        builder: (context, state) {
          bool isFavorite = songEntity.isFavorite;

          if (state is FavoriteButtonUpdated) {
            isFavorite = state.isFavorite;
          }

          if (showPlaylistButton) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AddToPlaylistButton(song: songEntity),
                IconButton(
                  onPressed: () {
                    context.read<FavoriteButtonCubit>().favoriteButtonUpdated(
                      songEntity.songId,
                    );

                    // Thêm feedback cho người dùng
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              isFavorite ? Icons.heart_broken : Icons.favorite,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isFavorite
                                  ? 'Removed from favorites'
                                  : 'Added to favorites',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: isFavorite
                            ? Colors.orange
                            : Colors.red,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_outline_outlined,
                    size: 25,
                    color: isFavorite ? Colors.red : AppColors.darkGrey,
                  ),
                ),
              ],
            );
          }

          return IconButton(
            onPressed: () {
              context.read<FavoriteButtonCubit>().favoriteButtonUpdated(
                songEntity.songId,
              );

              // Thêm feedback cho người dùng
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        isFavorite ? Icons.heart_broken : Icons.favorite,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isFavorite
                            ? 'Removed from favorites'
                            : 'Added to favorites',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: isFavorite ? Colors.orange : Colors.red,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_outline_outlined,
              size: 25,
              color: isFavorite ? Colors.red : AppColors.darkGrey,
            ),
          );
        },
      ),
    );
  }
}
