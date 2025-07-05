class YouTubeMusicSong {
  final String videoId;
  final String title;
  final String artist;
  final String? album;
  final int? duration; // in seconds
  final String? thumbnail;
  final String? thumbnailLarge;
  final bool isExplicit;
  final String? albumId;
  final String? artistId;
  final List<String> artists;

  YouTubeMusicSong({
    required this.videoId,
    required this.title,
    required this.artist,
    this.album,
    this.duration,
    this.thumbnail,
    this.thumbnailLarge,
    this.isExplicit = false,
    this.albumId,
    this.artistId,
    this.artists = const [],
  });

  factory YouTubeMusicSong.fromJson(Map<String, dynamic> json) {
    return YouTubeMusicSong(
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      album: json['album'],
      duration: json['duration'],
      thumbnail: json['thumbnail'],
      thumbnailLarge: json['thumbnailLarge'],
      isExplicit: json['isExplicit'] ?? false,
      albumId: json['albumId'],
      artistId: json['artistId'],
      artists: List<String>.from(json['artists'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'thumbnail': thumbnail,
      'thumbnailLarge': thumbnailLarge,
      'isExplicit': isExplicit,
      'albumId': albumId,
      'artistId': artistId,
      'artists': artists,
    };
  }

  /// Convert to Firebase Song format
  Map<String, dynamic> toFirebaseSong() {
    return {
      'title': title,
      'artist': artist,
      'duration': (duration ?? 0).toDouble(),
      'releaseDate': DateTime.now(),
      'image': thumbnailLarge ?? thumbnail ?? '',
      'songUrl': 'youtube:$videoId', // We'll handle this in the player
      'youtubeVideoId': videoId,
      'album': album,
      'isExplicit': isExplicit,
      'source': 'youtube_music',
      'addedAt': DateTime.now(),
    };
  }

  String get youtubeUrl => 'https://music.youtube.com/watch?v=$videoId';

  String get displayDuration {
    if (duration == null) return 'Unknown';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class YouTubeMusicAlbum {
  final String albumId;
  final String title;
  final String artist;
  final String? thumbnail;
  final int? year;
  final bool isExplicit;

  YouTubeMusicAlbum({
    required this.albumId,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.year,
    this.isExplicit = false,
  });

  factory YouTubeMusicAlbum.fromJson(Map<String, dynamic> json) {
    return YouTubeMusicAlbum(
      albumId: json['albumId'] ?? '',
      title: json['title'] ?? 'Unknown Album',
      artist: json['artist'] ?? 'Unknown Artist',
      thumbnail: json['thumbnail'],
      year: json['year'],
      isExplicit: json['isExplicit'] ?? false,
    );
  }
}

class YouTubeMusicArtist {
  final String artistId;
  final String name;
  final String? thumbnail;
  final int? subscriberCount;

  YouTubeMusicArtist({
    required this.artistId,
    required this.name,
    this.thumbnail,
    this.subscriberCount,
  });

  factory YouTubeMusicArtist.fromJson(Map<String, dynamic> json) {
    return YouTubeMusicArtist(
      artistId: json['artistId'] ?? '',
      name: json['name'] ?? 'Unknown Artist',
      thumbnail: json['thumbnail'],
      subscriberCount: json['subscriberCount'],
    );
  }
}
