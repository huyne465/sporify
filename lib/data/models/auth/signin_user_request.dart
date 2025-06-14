class SigninUserRequest {
  final String email;
  final String password;
  final bool isGoogleSignIn;
  final String? googleIdToken;

  SigninUserRequest({
    required this.email,
    required this.password,
    this.isGoogleSignIn = false,
    this.googleIdToken,
  });
}
