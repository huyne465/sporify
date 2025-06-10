import 'package:sporify/domain/entities/artist/artist.dart';

abstract class ArtistState {}

class ArtistLoading extends ArtistState {}

class ArtistLoaded extends ArtistState {
  final List<ArtistEntity> artists;

  ArtistLoaded(this.artists);
}

class ArtistFailure extends ArtistState {
  final String message;

  ArtistFailure(this.message);
}
