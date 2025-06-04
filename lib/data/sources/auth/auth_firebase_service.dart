import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sporify/data/models/auth/create_user_request.dart';
import 'package:sporify/data/models/auth/signin_user_request.dart';

abstract class AuthFirebaseService {
  Future<Either> signIn(SigninUserRequest signInReq);
  Future<Either> signUp(CreateUserRequest createUserReq);
  Future<void> signOut();
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  @override
  Future<Either> signIn(SigninUserRequest signInReq) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: signInReq.email,
        password: signInReq.password,
      );

      return const Right('Sign In was successful');
    } on FirebaseException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'Not found user with that email';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user';
      }
      return Left(message);
    }
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<Either> signUp(CreateUserRequest createUserReq) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password,
      );

      return const Right('SignUp was successful');
    } on FirebaseException catch (e) {
      String message = '';

      if (e.code == 'week-password') {
        message = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'An Account already exists with that email';
      }
      return Left(message);
    }
  }
}
