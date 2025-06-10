class ArtistEntity {
  final String id;
  final String name;
  final String imageUrl;
  final int albums;
  final double followers;
  final int songs;

  ArtistEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.albums,
    required this.followers,
    required this.songs,
  });
}
