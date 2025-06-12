import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sporify/core/configs/assets/app_vectors.dart';
import 'package:sporify/presentation/intro/pages/get_started.dart';
import 'package:sporify/presentation/root/pages/main_navigation.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: SvgPicture.asset(AppVectors.logo)));
  }

  Future<void> redirect() async {
    // Wait for Firebase Auth to initialize
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is currently signed in
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (currentUser != null) {
      // User is signed in, navigate to main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const MainNavigationPage(),
        ),
      );
    } else {
      // User is not signed in, navigate to get started page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const GetStartedPage(),
        ),
      );
    }
  }
}
