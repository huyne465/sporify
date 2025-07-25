import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sporify/data/models/auth/create_user_request.dart';
import 'package:sporify/data/models/auth/signin_user_request.dart';
import 'package:sporify/data/models/auth/change_password_request.dart';

abstract class AuthFirebaseService {
  Future<Either> signIn(SigninUserRequest signInReq);
  Future<Either> signUp(CreateUserRequest createUserReq);
  Future<Either> signInWithGoogle();
  Future<Either> signInWithFacebook();
  Future<Either> changePassword(ChangePasswordRequest changePasswordReq);
  Future<Either> resetPassword(String email);
  Future<void> signOut();
  Future<Either> linkGoogleAccount();
  Future<Either> linkFacebookAccount();
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  @override
  Future<Either> signIn(SigninUserRequest signInReq) async {
    try {
      String email = signInReq.email;

      // Check if the input is an email or username
      if (!signInReq.email.contains('@')) {
        // It's a username, find the corresponding email
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('username', isEqualTo: signInReq.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          return const Left('Username not found');
        }

        final userData = querySnapshot.docs.first.data();
        email = userData['email'] ?? '';

        if (email.isEmpty) {
          return const Left('Invalid user data');
        }
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: signInReq.password,
      );

      return const Right('Sign in successful');
    } on FirebaseException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'No account found with this email';
      } else if (e.code == 'invalid-credential') {
        message = 'Email/username or password is incorrect';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later';
      } else {
        message = 'Sign in failed: ${e.message}';
      }
      return Left(message);
    } catch (e) {
      return Left('An error occurred during sign in: ${e.toString()}');
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

      // Sign out from Facebook if user signed in with Facebook
      final facebookAccessToken = await FacebookAuth.instance.accessToken;
      if (facebookAccessToken != null) {
        await FacebookAuth.instance.logOut();
      }

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
      // Still sign out from Firebase even if social sign-out fails
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Future<Either> signUp(CreateUserRequest createUserReq) async {
    try {
      // Check if email already exists with different sign-in methods
      final signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(createUserReq.email);

      if (signInMethods.isNotEmpty) {
        if (signInMethods.contains('google.com')) {
          return const Left(
            'This email is already used with Google account. Please sign in with Google.',
          );
        } else if (signInMethods.contains('facebook.com')) {
          return const Left(
            'This email is already used with Facebook account. Please sign in with Facebook.',
          );
        } else if (signInMethods.contains('password')) {
          return const Left(
            'Account with this email already exists. Please sign in.',
          );
        }
      }

      // Check if username already exists
      final usernameQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: createUserReq.username)
          .limit(1)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        return const Left(
          'Username already exists. Please choose a different username.',
        );
      }

      var data = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password,
      );

      FirebaseFirestore.instance.collection('Users').doc(data.user?.uid).set({
        'name': createUserReq.fullName,
        'username': createUserReq.username,
        'email': data.user?.email,
        'signInMethod': 'password',
        'createdAt': Timestamp.now(),
      });

      return const Right('Sign up successful');
    } on FirebaseException catch (e) {
      String message = '';

      if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already used for another account';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      } else {
        message = 'Sign up failed: ${e.message}';
      }
      return Left(message);
    } catch (e) {
      return Left('An error occurred during sign up: ${e.toString()}');
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
          // Get the email from the error to provide specific guidance
          final email = e.email;
          if (email != null) {
            try {
              final signInMethods = await FirebaseAuth.instance
                  .fetchSignInMethodsForEmail(email);

              if (signInMethods.contains('password')) {
                message =
                    'Tài khoản với email này đã được tạo bằng mật khẩu. Vui lòng đăng nhập bằng email và mật khẩu.';
              } else if (signInMethods.contains('facebook.com')) {
                message =
                    'Tài khoản với email này đã được tạo bằng Facebook. Vui lòng đăng nhập bằng Facebook.';
              } else {
                message =
                    'Tài khoản với email này đã tồn tại với phương thức đăng nhập khác.';
              }
            } catch (_) {
              message =
                  'Tài khoản với email này đã tồn tại với phương thức đăng nhập khác.';
            }
          } else {
            message = 'Tài khoản đã tồn tại với phương thức đăng nhập khác.';
          }
          break;
        case 'invalid-credential':
          message = 'Thông tin xác thực Google không hợp lệ hoặc đã hết hạn';
          break;
        case 'operation-not-allowed':
          message =
              'Đăng nhập bằng Google chưa được kích hoạt cho ứng dụng này';
          break;
        case 'user-disabled':
          message = 'Tài khoản này đã bị vô hiệu hóa';
          break;
        default:
          message = 'Đăng nhập Google thất bại: ${e.message}';
      }
      return Left(message);
    } catch (e) {
      return Left(
        'Đã xảy ra lỗi trong quá trình đăng nhập Google: ${e.toString()}',
      );
    }
  }

  @override
  Future<Either> signInWithFacebook() async {
    try {
      // Trigger the Facebook authentication flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Get the access token
        final AccessToken accessToken = result.accessToken!;

        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken.token);

        // Sign in to Firebase with the Facebook credential
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);

        // Get Facebook user data
        final Map<String, dynamic> userData = await FacebookAuth.instance
            .getUserData();

        // Save user data to Firestore if it's a new user
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userCredential.user?.uid)
              .set({
                'name': userData['name'] ?? 'Facebook User',
                'email': userData['email'] ?? userCredential.user?.email,
                'photoURL': userData['picture']?['data']?['url'],
                'signInMethod': 'facebook',
                'facebookId': userData['id'],
                'createdAt': Timestamp.now(),
              });
        }

        return const Right('Facebook sign-in was successful');
      } else if (result.status == LoginStatus.cancelled) {
        return const Left('Đăng nhập Facebook đã bị hủy');
      } else {
        return Left('Đăng nhập Facebook thất bại: ${result.message}');
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      switch (e.code) {
        case 'account-exists-with-different-credential':
          // Get the email from the error to provide specific guidance
          final email = e.email;
          if (email != null) {
            try {
              final signInMethods = await FirebaseAuth.instance
                  .fetchSignInMethodsForEmail(email);

              if (signInMethods.contains('password')) {
                message =
                    'Tài khoản với email này đã được tạo bằng mật khẩu. Vui lòng đăng nhập bằng email và mật khẩu.';
              } else if (signInMethods.contains('google.com')) {
                message =
                    'Tài khoản với email này đã được tạo bằng Google. Vui lòng đăng nhập bằng Google.';
              } else {
                message =
                    'Tài khoản với email này đã tồn tại với phương thức đăng nhập khác.';
              }
            } catch (_) {
              message =
                  'Tài khoản với email này đã tồn tại với phương thức đăng nhập khác.';
            }
          } else {
            message = 'Tài khoản đã tồn tại với phương thức đăng nhập khác.';
          }
          break;
        case 'invalid-credential':
          message = 'Thông tin xác thực Facebook không hợp lệ hoặc đã hết hạn';
          break;
        case 'operation-not-allowed':
          message =
              'Đăng nhập bằng Facebook chưa được kích hoạt cho ứng dụng này';
          break;
        case 'user-disabled':
          message = 'Tài khoản này đã bị vô hiệu hóa';
          break;
        default:
          message = 'Đăng nhập Facebook thất bại: ${e.message}';
      }
      return Left(message);
    } catch (e) {
      return Left(
        'Đã xảy ra lỗi trong quá trình đăng nhập Facebook: ${e.toString()}',
      );
    }
  }

  @override
  Future<Either> linkGoogleAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('User not logged in');
      }

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return const Left('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.linkWithCredential(credential);
      return const Right('Google account linked successfully');
    } catch (e) {
      return Left('Failed to link Google account: ${e.toString()}');
    }
  }

  @override
  Future<Either> linkFacebookAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('User not logged in');
      }

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.token,
        );

        await user.linkWithCredential(credential);
        return const Right('Facebook account linked successfully');
      } else {
        return const Left('Facebook authentication failed');
      }
    } catch (e) {
      return Left('Failed to link Facebook account: ${e.toString()}');
    }
  }

  @override
  Future<Either> resetPassword(String email) async {
    try {
      print('🔥 Firebase resetPassword called with email: $email');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent successfully');
      return const Right('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else {
        message = 'Failed to send password reset email: ${e.message}';
      }
      return Left(message);
    } catch (e) {
      print('❌ General exception: ${e.toString()}');
      return Left(
        'An error occurred while sending password reset email: ${e.toString()}',
      );
    }
  }
}
