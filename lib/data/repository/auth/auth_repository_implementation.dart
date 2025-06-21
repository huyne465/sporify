import 'package:dartz/dartz.dart';
import 'package:sporify/data/models/auth/create_user_request.dart';
import 'package:sporify/data/models/auth/signin_user_request.dart';
import 'package:sporify/data/models/auth/change_password_request.dart';
import 'package:sporify/data/sources/auth/auth_firebase_service.dart';
import 'package:sporify/domain/repository/auth/auth.dart';
import 'package:sporify/service_locator.dart';

class AuthRepositoryImplementation extends AuthRepository {
  @override
  Future<Either> signIn(SigninUserRequest signInUserReq) async {
    return await sl<AuthFirebaseService>().signIn(signInUserReq);
  }

  @override
  Future<void> signOut() async {
    return await sl<AuthFirebaseService>().signOut();
  }

  @override
  Future<Either> signUp(CreateUserRequest createUserReq) async {
    return await sl<AuthFirebaseService>().signUp(createUserReq);
  }

  @override
  Future<Either> changePassword(ChangePasswordRequest changePasswordReq) async {
    return await sl<AuthFirebaseService>().changePassword(changePasswordReq);
  }

  @override
  Future<Either> signInWithGoogle() async {
    return await sl<AuthFirebaseService>().signInWithGoogle();
  }

  @override
  Future<Either> signInWithFacebook() async {
    return await sl<AuthFirebaseService>().signInWithFacebook();
  }

  @override
  Future<Either> linkGoogleAccount() async {
    return await sl<AuthFirebaseService>().linkGoogleAccount();
  }

  @override
  Future<Either> linkFacebookAccount() async {
    return await sl<AuthFirebaseService>().linkFacebookAccount();
  }

  @override
  Future<Either> resetPassword(String email) async {
    return await sl<AuthFirebaseService>().resetPassword(email);
  }
}
