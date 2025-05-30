import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/common/widgets/button/basic_button.dart';
import 'package:sporify/core/configs/assets/app_vectors.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar
      appBar: BasicAppBar(
        title: SvgPicture.asset(AppVectors.logo, height: 40, width: 40),
      ),
      //body
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _registerText(),
            const SizedBox(height: 5), // Reduced
            _supportText(context),
            const SizedBox(height: 15), // Reduced
            _fullNameField(context),
            const SizedBox(height: 16),
            _emailField(context),
            const SizedBox(height: 16),
            _passWordField(context),
            const SizedBox(height: 20), // Reduced
            BasicButton(
              onPressed: () {},
              title: 'Create Account',
              height: 80,
            ), // Reduced height
            const SizedBox(height: 15), // Reduced
            _orLine(context),
            const SizedBox(height: 15), // Reduced
            _gmailOrApple(context),
            const SizedBox(height: 10), // Add some bottom padding
          ],
        ),
      ),
      //bottom navigation
      bottomNavigationBar: _signInText(context),
    );
  }

  //Register
  Widget _registerText() {
    return Text(
      'Register',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      textAlign: TextAlign.center,
    );
  }

  //full name
  Widget _fullNameField(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Full Name',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  //Email
  Widget _emailField(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Enter Email',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  //Password
  Widget _passWordField(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Password',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  //bottom app bar sign in text button
  Widget _signInText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Do You Have An Account?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Sign In',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff288CE9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //support text
  Widget _supportText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'If You Need Any Support',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Click here',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orLine(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5B5B5B), Color(0xFF252525)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Text(
            'Or',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5B5B5B), Color(0xFF252525)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gmailOrApple(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildModeOption(
            icon: AppVectors.gmailIcon,
            onTap: () {
              print('object');
            },
            context: context,
          ),
          const SizedBox(width: 75),
          _buildModeOption(
            icon: AppVectors.appleIcon,
            onTap: () {
              print('object');
            },
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required String icon,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final size = 80.0;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: size * 0.5,
                  height: size * 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
