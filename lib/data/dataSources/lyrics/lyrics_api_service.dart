import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:sporify/data/models/lyrics/lyrics.dart';
import 'package:sporify/domain/entities/lyrics/lyrics.dart';

abstract class LyricsApiService {
  Future<Either<String, LyricsEntity?>> getLyrics(String artist, String track);
}

class LyricsApiServiceImpl extends LyricsApiService {
  final String baseUrl = 'https://lrclib.net/api';

  @override
  Future<Either<String, LyricsEntity?>> getLyrics(
    String artist,
    String track,
  ) async {
    try {
      final encodedArtist = Uri.encodeComponent(artist.trim());
      final encodedTrack = Uri.encodeComponent(track.trim());

      final url =
          '$baseUrl/get?artist_name=$encodedArtist&track_name=$encodedTrack';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'Sporify/1.0.0 (https://github.com/sporify)',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final lyricsModel = LyricsModel.fromJson(jsonData);
        return Right(lyricsModel.toEntity());
      } else if (response.statusCode == 404) {
        return const Right(null);
      } else {
        return Left('Failed to fetch lyrics: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Error fetching lyrics: ${e.toString()}');
    }
  }
}
