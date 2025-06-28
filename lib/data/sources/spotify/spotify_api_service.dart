import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sporify/data/models/spotify/spotify_artist.dart';
import 'package:sporify/core/configs/constants/app_spotify_keys.dart';

class SpotifyApiServiceImpl extends SpotifyApiService {
  final String baseUrl = 'https://api.spotify.com/v1';
  String? _accessToken;
  DateTime? _tokenExpiry;
  Future<String?> getAccessToken() async {
    // Check if token is still valid
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      final credentials = base64Encode(
        utf8.encode(
          '${AppSpotifyKeys.clientId}:${AppSpotifyKeys.clientSecret}',
        ),
      );

      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic $credentials',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(
          Duration(seconds: expiresIn - 60),
        ); // Refresh 1 minute early
        return _accessToken;
      } else {
        print('Spotify API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting Spotify access token: $e');
      return null;
    }
  }

  @override
  Future<List<SpotifyArtistModel>> searchArtists(String query) async {
    try {
      final token = await getAccessToken();
      if (token == null) throw Exception('Failed to get access token');

      final response = await http.get(
        Uri.parse(
          '$baseUrl/search?q=${Uri.encodeComponent(query)}&type=artist&limit=20',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final artists = data['artists']['items'] as List<dynamic>;
        return artists
            .map((artist) => SpotifyArtistModel.fromJson(artist))
            .toList();
      } else {
        throw Exception('Failed to search artists');
      }
    } catch (e) {
      throw Exception('Error searching artists: $e');
    }
  }

  @override
  Future<List<SpotifyTrackModel>> getArtistTopTracks(String artistId) async {
    try {
      final token = await getAccessToken();
      if (token == null) throw Exception('Failed to get access token');

      final response = await http.get(
        Uri.parse('$baseUrl/artists/$artistId/top-tracks?market=US'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks'] as List<dynamic>;
        return tracks
            .map((track) => SpotifyTrackModel.fromJson(track))
            .toList();
      } else {
        throw Exception('Failed to get artist top tracks');
      }
    } catch (e) {
      throw Exception('Error getting artist top tracks: $e');
    }
  }

  @override
  Future<List<SpotifyAlbumModel>> getArtistAlbums(String artistId) async {
    try {
      final token = await getAccessToken();
      if (token == null) throw Exception('Failed to get access token');

      final response = await http.get(
        Uri.parse(
          '$baseUrl/artists/$artistId/albums?market=US&limit=20&include_groups=album',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final albums = data['items'] as List<dynamic>;
        return albums
            .map((album) => SpotifyAlbumModel.fromJson(album))
            .toList();
      } else {
        throw Exception('Failed to get artist albums');
      }
    } catch (e) {
      throw Exception('Error getting artist albums: $e');
    }
  }

  @override
  Future<List<SpotifyAlbumModel>> getSeveralAlbums(
    List<String> albumIds,
  ) async {
    try {
      final token = await getAccessToken();
      if (token == null) throw Exception('Failed to get access token');

      // Join album IDs with comma, max 20 albums per request
      final ids = albumIds.take(20).join(',');

      final response = await http.get(
        Uri.parse('$baseUrl/albums?ids=${Uri.encodeComponent(ids)}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final albums = data['albums'] as List<dynamic>;
        return albums
            .where((album) => album != null) // Filter out null albums
            .map((album) => SpotifyAlbumModel.fromJson(album))
            .toList();
      } else {
        throw Exception('Failed to get several albums: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting several albums: $e');
    }
  }
}

abstract class SpotifyApiService {
  Future<List<SpotifyArtistModel>> searchArtists(String query);
  Future<List<SpotifyTrackModel>> getArtistTopTracks(String artistId);
  Future<List<SpotifyAlbumModel>> getArtistAlbums(String artistId);
  Future<List<SpotifyAlbumModel>> getSeveralAlbums(List<String> albumIds);
}
