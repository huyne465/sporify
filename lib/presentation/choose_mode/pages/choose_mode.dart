import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sporify/common/base_widgets/button/basic_button.dart';
import 'package:sporify/core/configs/assets/app_images.dart';
import 'package:sporify/core/configs/assets/app_vectors.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/presentation/auth/pages/signup_or_signin.dart';
import 'package:sporify/presentation/choose_mode/bloc/theme_cubit.dart';

class ChooseModePage extends StatelessWidget {
  const ChooseModePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.08; // 8% of screen width
    final verticalPadding = screenSize.height * 0.06; // 6% of screen height
    final modeButtonSize = screenSize.width < 400
        ? 60.0
        : 80.0; // Smaller button on small screens

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.chooseModeBG),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(color: Colors.black.withOpacity(0.15)),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: verticalPadding,
                horizontal: horizontalPadding,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SvgPicture.asset(
                      AppVectors.logo,
                      width: screenSize.width * 0.4, // 40% of screen width
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Choose Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: screenSize.height * 0.04,
                  ), // 4% of screen height
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeOption(
                        context: context,
                        title: 'Dark Mode',
                        icon: AppVectors.moon,
                        onTap: () => context.read<ThemeCubit>().updateTheme(
                          ThemeMode.dark,
                        ),
                        size: modeButtonSize,
                      ),
                      SizedBox(width: 55),
                      _buildModeOption(
                        context: context,
                        title: 'Light Mode',
                        icon: AppVectors.sun,
                        onTap: () => context.read<ThemeCubit>().updateTheme(
                          ThemeMode.light,
                        ),
                        size: modeButtonSize,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenSize.height * 0.05,
                  ), // 5% of screen height
                  BasicButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const SignupOrSigninPage(),
                        ),
                      );
                    },
                    title: 'Continue',
                    height: screenSize.height * 0.075, // 7.5% of screen height
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required BuildContext context,
    required String title,
    required String icon,
    required VoidCallback onTap,
    required double size,
  }) {
    final fontSize = size < 70 ? 14.0 : 17.0;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  color: const Color(0xff30393C).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(icon, fit: BoxFit.none),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: fontSize,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
