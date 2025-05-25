import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sporify/common/widgets/button/basic_button.dart';
import 'package:sporify/core/configs/assets/app_images.dart';
import 'package:sporify/core/configs/assets/app_vectors.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';

class ChooseModePage extends StatelessWidget {
  const ChooseModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 45),
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(AppImages.chooseModeBG)),
            ),
          ),

          // ignore: deprecated_member_use
          Container(color: Colors.black.withOpacity(0.15)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(AppVectors.logo),
                ),
                Spacer(),
                const Text(
                  'Choose Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Color(0xff30393C).withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                AppVectors.moon,
                                fit: BoxFit.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 40),
                    Column(
                      children: [
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Color(0xff30393C).withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                AppVectors.sun,
                                fit: BoxFit.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Light Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                BasicButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const ChooseModePage(),
                      ),
                    );
                  },
                  title: 'Continue',
                  height: 85,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
