import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/presentation/splash/bloc/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkAuthStatus() async {
    try {
      emit(SplashLoading());

      // Wait for Firebase Auth to initialize
      await Future.delayed(const Duration(seconds: 2));

      // Check if user is currently signed in
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // User is signed in
        emit(SplashAuthenticated(user: currentUser));
      } else {
        // User is not signed in
        emit(SplashUnauthenticated());
      }
    } catch (e) {
      emit(SplashError(message: e.toString()));
    }
  }
}
