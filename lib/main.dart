import 'package:flutter/material.dart';
import 'package:sporify/core/configs/themes/app_theme.dart';
import 'package:sporify/presentation/splash/pages/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
