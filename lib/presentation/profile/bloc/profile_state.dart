abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileImageUpdated extends ProfileState {
  final String message;
  ProfileImageUpdated(this.message);
}

class ProfileImageRemoved extends ProfileState {
  final String message;
  ProfileImageRemoved(this.message);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
