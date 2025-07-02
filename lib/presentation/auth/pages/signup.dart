import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/common/widgets/button/basic_button.dart';
import 'package:sporify/core/configs/assets/app_vectors.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/data/models/auth/create_user_request.dart';
import 'package:sporify/domain/usecases/auth/signup.dart';
import 'package:sporify/domain/usecases/auth/signin_with_google.dart';
import 'package:sporify/domain/usecases/auth/signin_with_facebook.dart';
import 'package:sporify/presentation/auth/pages/signin.dart';
import 'package:sporify/presentation/root/pages/main_navigation.dart';
import 'package:sporify/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;

  @override
  void dispose() {
    _fullname.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

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
              _registerText(),
              const SizedBox(height: 5), // Reduced
              _supportText(context),
              const SizedBox(height: 15), // Reduced
              _fullNameField(context),
              const SizedBox(height: 16),
              _usernameField(context),
              const SizedBox(height: 16),
              _emailField(context),
              const SizedBox(height: 16),
              _passWordField(context),
              const SizedBox(height: 16), // Reduced
              BasicButton(
                onPressed: () async {
                  var result = await sl<SignupUseCase>().call(
                    params: CreateUserRequest(
                      fullName: _fullname.text.toString(),
                      username: _username.text.toString(),
                      email: _email.text.toString(),
                      password: _password.text.toString(),
                    ),
                  );
                  result.fold(
                    (l) {
                      var snackBar = SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      );
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
                title: 'Create Account',
                height: 80,
              ), // Reduced height
              const SizedBox(height: 5), // Reduced
              _orLine(context),
              const SizedBox(height: 10), // Reduced
              _gmailOrApple(context),
            ],
          ),
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
      controller: _fullname,
      decoration: const InputDecoration(
        hintText: 'Full Name',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  //username
  Widget _usernameField(BuildContext context) {
    return TextField(
      controller: _username,
      decoration: const InputDecoration(
        hintText: 'Username',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  //Email
  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: const InputDecoration(
        hintText: 'Enter Email',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  //Password
  Widget _passWordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: context.isDarkMode ? Colors.white70 : Colors.black54,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  //bottom app bar sign in text button
  Widget _signInText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Do You Have An Account?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SignInPage(),
                ),
              );
            },
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
            onTap: _isGoogleLoading ? null : _signInWithGoogle,
            context: context,
            isLoading: _isGoogleLoading,
          ),
          const SizedBox(width: 75),
          _buildModeOption(
            icon: AppVectors.fbIcon,
            onTap: _isFacebookLoading ? null : _signInWithFacebook,
            context: context,
            isLoading: _isFacebookLoading,
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      var result = await sl<SignInWithGoogleUseCase>().call();

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      failure,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        (success) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const MainNavigationPage(),
            ),
            (route) => false,
          );
        },
      );
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isFacebookLoading = true;
    });

    try {
      var result = await sl<SignInWithFacebookUseCase>().call();

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      failure,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        (success) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const MainNavigationPage(),
            ),
            (route) => false,
          );
        },
      );
    } finally {
      setState(() {
        _isFacebookLoading = false;
      });
    }
  }

  Widget _buildModeOption({
    required String icon,
    required VoidCallback? onTap,
    required BuildContext context,
    bool isLoading = false,
  }) {
    final size = 80.0;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: context.isDarkMode ? Colors.grey[800] : Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(
                color: context.isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : ClipOval(
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
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Could not open support page. Please check if you have a browser installed.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      // Handle any unexpected errors
      print('URL launch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error opening support page: ${e.toString()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
