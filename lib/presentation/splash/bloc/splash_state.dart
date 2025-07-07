import 'package:firebase_auth/firebase_auth.dart';

abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashAuthenticated extends SplashState {
  final User user;

  SplashAuthenticated({required this.user});
}

class SplashUnauthenticated extends SplashState {}

class SplashError extends SplashState {
  final String message;

  SplashError({required this.message});
}
