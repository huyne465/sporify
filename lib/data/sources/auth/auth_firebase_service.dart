import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sporify/data/models/auth/create_user_request.dart';
import 'package:sporify/data/models/auth/signin_user_request.dart';
import 'package:sporify/data/models/auth/change_password_request.dart';

abstract class AuthFirebaseService {
  Future<Either> signIn(SigninUserRequest signInReq);
  Future<Either> signUp(CreateUserRequest createUserReq);
  Future<Either> signInWithGoogle();
  Future<Either> changePassword(ChangePasswordRequest changePasswordReq);
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
  Future<void> signOut() async {
    try {
      // Sign out from Google if user signed in with Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
      // Still sign out from Firebase even if Google sign-out fails
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Future<Either> signUp(CreateUserRequest createUserReq) async {
    try {
      var data = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password,
      );
      FirebaseFirestore.instance.collection('Users').doc(data.user?.uid).set({
        'name': createUserReq.fullName,
        'email': data.user?.email,
      });

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

  @override
  Future<Either> changePassword(ChangePasswordRequest changePasswordReq) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('User not logged in');
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: changePasswordReq.currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(changePasswordReq.newPassword);

      return const Right('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      String message = '';

      switch (e.code) {
        case 'wrong-password':
          message = 'Current password is incorrect';
          break;
        case 'weak-password':
          message = 'The new password is too weak';
          break;
        case 'requires-recent-login':
          message = 'Please log in again to change your password';
          break;
        default:
          message = 'An error occurred while changing password';
      }
      return Left(message);
    } catch (e) {
      return Left('An error occurred: ${e.toString()}');
    }
  }

  @override
  Future<Either> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return const Left('Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // Save user data to Firestore if it's a new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user?.uid)
            .set({
              'name': userCredential.user?.displayName ?? 'Google User',
              'email': userCredential.user?.email,
              'photoURL': userCredential.user?.photoURL,
              'signInMethod': 'google',
              'createdAt': Timestamp.now(),
            });
      }

      return const Right('Google sign-in was successful');
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message =
              'An account already exists with the same email address but different sign-in credentials';
          break;
        case 'invalid-credential':
          message = 'The credential received is malformed or has expired';
          break;
        default:
          message = 'Google sign-in failed: ${e.message}';
      }
      return Left(message);
    } catch (e) {
      return Left('An error occurred during Google sign-in: ${e.toString()}');
    }
  }
}
