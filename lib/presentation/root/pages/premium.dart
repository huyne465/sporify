import 'package:flutter/material.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/presentation/music_player/widgets/mini_player.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        hideback: true,
        title: Text(
          'Premium',
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Go Premium',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: context.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Enjoy unlimited music with no ads',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.isDarkMode
                            ? Colors.white70
                            : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Get Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
