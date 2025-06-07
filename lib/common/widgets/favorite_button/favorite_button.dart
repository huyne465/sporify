import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/common/bloc/favorite_button/favorite_button_cubit.dart';
import 'package:sporify/common/bloc/favorite_button/favorite_button_state.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/domain/entities/songs/song.dart';

class FavoriteButton extends StatelessWidget {
  final SongEntity songEntity;
  const FavoriteButton({required this.songEntity, super.key});

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

          return IconButton(
            onPressed: () {
              context.read<FavoriteButtonCubit>().favoriteButtonUpdated(
                songEntity.songId,
              );

              // Thêm feedback cho người dùng
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Removed from favorites'
                        : 'Added to favorites',
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
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
