import 'package:sporify/domain/entities/artist/artist.dart';

abstract class ArtistDetailState {}

class ArtistDetailLoading extends ArtistDetailState {}

class ArtistDetailLoaded extends ArtistDetailState {
  final ArtistEntity artist;

  ArtistDetailLoaded({required this.artist});
}

class ArtistDetailFailure extends ArtistDetailState {
  final String errorMessage;

  ArtistDetailFailure({required this.errorMessage});
}
