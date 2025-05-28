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
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _registerText(),
            const SizedBox(height: 15),
            _supportText(context),
            const SizedBox(height: 26),
            _fullNameField(context),
            const SizedBox(height: 16),
            _emailField(context),
            const SizedBox(height: 16),
            _passWordField(context),
            const SizedBox(height: 33),
            BasicButton(onPressed: () {}, title: 'Create Account', height: 80),
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
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
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
      padding: EdgeInsets.symmetric(vertical: 30),
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
      padding: EdgeInsets.symmetric(vertical: 30),
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
}
