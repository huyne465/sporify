import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/common/widgets/button/basic_button.dart';
import 'package:sporify/core/configs/assets/app_vectors.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/data/models/auth/signin_user_request.dart';
import 'package:sporify/domain/usecases/auth/signin.dart';
import 'package:sporify/presentation/auth/pages/signup.dart';
import 'package:sporify/presentation/root/pages/main_navigation.dart';
import 'package:sporify/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _signInHeadText(),
              const SizedBox(height: 5), // Reduced
              _supportText(context),
              const SizedBox(height: 16),
              _emailField(context),
              const SizedBox(height: 16),
              _passWordField(context),
              const SizedBox(), // Reduced
              _forgotPassword(context),
              const SizedBox(),
              BasicButton(
                onPressed: () async {
                  var result = await sl<SignInUseCase>().call(
                    params: SigninUserRequest(
                      email: _email.text.toString(),
                      password: _password.text.toString(),
                    ),
                  );
                  result.fold(
                    (l) {
                      var snackBar = SnackBar(content: Text(l));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    (r) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const MainNavigationPage(),
                        ),
                        (route) => false,
                      );
                    },
                  );
                },
                title: 'Sign In',
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
      ),
      //bottom navigation
      bottomNavigationBar: _signUpText(context),
    );
  }

  //Sign In
  Widget _signInHeadText() {
    return Text(
      'Sign In',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      textAlign: TextAlign.center,
    );
  }

  //Email
  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: const InputDecoration(
        hintText: 'Enter Email Or Username',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  //Password
  Widget _passWordField(BuildContext context) {
    return TextField(
      controller: _password,
      decoration: const InputDecoration(
        hintText: 'Password',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  //bottom app bar sign in text button
  Widget _signUpText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Not A Member?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SignupPage(),
                ),
              );
            },
            child: Text(
              'Register Now',
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
            onPressed: () async {
              await _launchSupportUrl(context);
            },
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

  Widget _forgotPassword(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Recovery Password',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: context.isDarkMode ? Color(0xffAEAEAE) : Colors.black,
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

  Future<void> _launchSupportUrl(context) async {
    final Uri url = Uri.parse('https://support.spotify.com/us/');

    try {
      // Try different launch modes for better compatibility
      bool launched = false;

      // First try: External application (default browser)
      try {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('External launch failed: $e');
      }

      // Second try: Platform default
      if (!launched) {
        try {
          launched = await launchUrl(url, mode: LaunchMode.platformDefault);
        } catch (e) {
          print('Platform default launch failed: $e');
        }
      }

      // Third try: In-app web view as fallback
      if (!launched) {
        try {
          launched = await launchUrl(url, mode: LaunchMode.inAppWebView);
        } catch (e) {
          print('In-app web view launch failed: $e');
        }
      }

      // If all methods fail, show error
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open support page. Please check if you have a browser installed.',
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Handle any unexpected errors
      print('URL launch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening support page: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
