class SpotifyArtistModel {
  final String id;
  final String name;
  final List<SpotifyImageModel> images;
  final int followers;
  final List<String> genres;
  final String spotifyUrl;

  SpotifyArtistModel({
    required this.id,
    required this.name,
    required this.images,
    required this.followers,
    required this.genres,
    required this.spotifyUrl,
  });

  factory SpotifyArtistModel.fromJson(Map<String, dynamic> json) {
    return SpotifyArtistModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((img) => SpotifyImageModel.fromJson(img))
              .toList() ??
          [],
      followers: json['followers']?['total'] ?? 0,
      genres: List<String>.from(json['genres'] ?? []),
      spotifyUrl: json['external_urls']?['spotify'] ?? '',
    );
  }
}

class SpotifyImageModel {
  final String url;
  final int? height;
  final int? width;

  SpotifyImageModel({required this.url, this.height, this.width});

  factory SpotifyImageModel.fromJson(Map<String, dynamic> json) {
    return SpotifyImageModel(
      url: json['url'] ?? '',
      height: json['height'],
      width: json['width'],
    );
  }
}

class SpotifyTrackModel {
  final String id;
  final String name;
  final List<String> artists;
  final SpotifyAlbumModel album;
  final String? previewUrl;
  final String spotifyUrl;

  SpotifyTrackModel({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    this.previewUrl,
    required this.spotifyUrl,
  });

  factory SpotifyTrackModel.fromJson(Map<String, dynamic> json) {
    return SpotifyTrackModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      artists:
          (json['artists'] as List<dynamic>?)
              ?.map((artist) => artist['name'].toString())
              .toList() ??
          [],
      album: SpotifyAlbumModel.fromJson(json['album'] ?? {}),
      previewUrl: json['preview_url'],
      spotifyUrl: json['external_urls']?['spotify'] ?? '',
    );
  }
}

class SpotifyAlbumModel {
  final String id;
  final String name;
  final List<SpotifyImageModel> images;

  SpotifyAlbumModel({
    required this.id,
    required this.name,
    required this.images,
  });

  factory SpotifyAlbumModel.fromJson(Map<String, dynamic> json) {
    return SpotifyAlbumModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((img) => SpotifyImageModel.fromJson(img))
              .toList() ??
          [],
    );
  }
}
