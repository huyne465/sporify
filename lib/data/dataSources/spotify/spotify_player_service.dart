import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sporify/data/dataSources/spotify/spotify_api_service.dart';

abstract class SpotifyPlayerService {
  Future<bool> playTrack(String trackUri, {String? deviceId});
  Future<bool> playAlbum(String albumUri, {String? deviceId});
  Future<bool> pausePlayback({String? deviceId});
  Future<bool> resumePlayback({String? deviceId});
  Future<Map<String, dynamic>?> getCurrentPlayback();
  Future<List<Map<String, dynamic>>> getAvailableDevices();
}

class SpotifyPlayerServiceImpl extends SpotifyPlayerService {
  final SpotifyApiServiceImpl _apiService = SpotifyApiServiceImpl();
  final String baseUrl = 'https://api.spotify.com/v1/me/player';

  @override
  Future<bool> playTrack(String trackUri, {String? deviceId}) async {
    try {
      final token = await _apiService.getAccessToken();
      if (token == null) return false;

      final body = {
        'uris': [trackUri],
        if (deviceId != null) 'device_id': deviceId,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/play'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error playing track: $e');
      return false;
    }
  }

  @override
  Future<bool> playAlbum(String albumUri, {String? deviceId}) async {
    try {
      final token = await _apiService.getAccessToken();
      if (token == null) return false;

      final body = {
        'context_uri': albumUri,
        if (deviceId != null) 'device_id': deviceId,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/play'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error playing album: $e');
      return false;
    }
  }

  @override
  Future<bool> pausePlayback({String? deviceId}) async {
    try {
      final token = await _apiService.getAccessToken();
      if (token == null) return false;

      String url = '$baseUrl/pause';
      if (deviceId != null) {
        url += '?device_id=$deviceId';
      }

      final response = await http.put(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error pausing playback: $e');
      return false;
    }
  }

  @override
  Future<bool> resumePlayback({String? deviceId}) async {
    try {
      final token = await _apiService.getAccessToken();
      if (token == null) return false;

      String url = '$baseUrl/play';
      if (deviceId != null) {
        url += '?device_id=$deviceId';
      }

      final response = await http.put(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error resuming playback: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentPlayback() async {
    try {
      final token = await _apiService.getAccessToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting current playback: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableDevices() async {
    try {
      final token = await _apiService.getAccessToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/devices'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['devices'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting devices: $e');
      return [];
    }
  }
}
