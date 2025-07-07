import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sporify/core/routes/app_routes.dart';
import 'package:sporify/presentation/splash/bloc/splash_cubit.dart';
import 'package:sporify/presentation/splash/bloc/splash_state.dart';
import 'package:sporify/presentation/splash/widgets/splash_logo_widget.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit()..checkAuthStatus(),
      child: Scaffold(
        body: BlocListener<SplashCubit, SplashState>(
          listener: (context, state) {
            _handleSplashState(state);
          },
          child: const SplashLogoWidget(),
        ),
      ),
    );
  }

  void _handleSplashState(SplashState state) {
    if (state is SplashAuthenticated) {
      print('✅ User signed in, navigating to main app...');
      // User is signed in, navigate to main app using GetX
      Get.offAllNamed(AppRoutes.mainNavigation);
    } else if (state is SplashUnauthenticated) {
      print('❌ User not signed in, navigating to get started...');
      // User is not signed in, navigate to get started page using GetX
      Get.offAllNamed(AppRoutes.getStarted);
    } else if (state is SplashError) {
      print('❗ Error in splash redirect: ${state.message}');
      // Fallback navigation with GetX
      Get.offAllNamed(AppRoutes.getStarted);
    }
  }
}
