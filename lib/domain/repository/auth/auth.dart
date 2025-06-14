import 'package:dartz/dartz.dart';
import 'package:sporify/data/models/auth/create_user_request.dart';
import 'package:sporify/data/models/auth/signin_user_request.dart';
import 'package:sporify/data/models/auth/change_password_request.dart';

abstract class AuthRepository {
  Future<Either> signUp(CreateUserRequest createUserReq);
  Future<Either> signIn(SigninUserRequest signInUserReq);
  Future<Either> signInWithGoogle();
  Future<Either> changePassword(ChangePasswordRequest changePasswordReq);
  Future<void> signOut();
}
