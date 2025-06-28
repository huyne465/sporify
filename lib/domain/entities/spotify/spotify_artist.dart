class SpotifyArtistEntity {
  final String id;
  final String name;
  final String imageUrl;
  final int followers;
  final List<String> genres;
  final String spotifyUrl;

  SpotifyArtistEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.followers,
    required this.genres,
    required this.spotifyUrl,
  });
}

class SpotifyTrackEntity {
  final String id;
  final String name;
  final List<String> artists;
  final String albumName;
  final String albumImageUrl;
  final String? previewUrl;
  final String spotifyUrl;

  SpotifyTrackEntity({
    required this.id,
    required this.name,
    required this.artists,
    required this.albumName,
    required this.albumImageUrl,
    this.previewUrl,
    required this.spotifyUrl,
  });
}

class SpotifyAlbumEntity {
  final String id;
  final String name;
  final String imageUrl;
  final String albumType;
  final String releaseDate;
  final int totalTracks;
  final String spotifyUrl;
  final List<String> artists;

  SpotifyAlbumEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.albumType,
    required this.releaseDate,
    required this.totalTracks,
    required this.spotifyUrl,
    required this.artists,
  });
}
