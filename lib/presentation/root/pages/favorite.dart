import 'package:flutter/material.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/presentation/music_player/widgets/mini_player.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Center(
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
                        color: context.isDarkMode
                            ? Colors.white70
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80), // Space for mini player
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
