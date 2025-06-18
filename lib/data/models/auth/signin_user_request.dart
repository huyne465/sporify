class SigninUserRequest {
  final String email;
  final String password;
  final bool isGoogleSignIn;
  final bool isFacebookSignIn;
  final String? googleIdToken;
  final String? facebookAccessToken;

  SigninUserRequest({
    required this.email,
    required this.password,
    this.isGoogleSignIn = false,
    this.isFacebookSignIn = false,
    this.googleIdToken,
    this.facebookAccessToken,
  });
}
