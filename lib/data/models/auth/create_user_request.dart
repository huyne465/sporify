class CreateUserRequest {
  final String fullName;
  final String username;
  final String email;
  final String password;

  CreateUserRequest({
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
  });
}
