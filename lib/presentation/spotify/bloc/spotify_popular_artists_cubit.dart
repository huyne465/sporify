import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporify/domain/entities/spotify/spotify_artist.dart';
import 'package:sporify/domain/usecases/spotify/search_spotify_artists.dart';
import 'package:sporify/presentation/spotify/bloc/spotify_popular_artists_state.dart';
import 'package:sporify/core/di/service_locator.dart';

class SpotifyPopularArtistsCubit extends Cubit<SpotifyPopularArtistsState> {
  SpotifyPopularArtistsCubit() : super(SpotifyPopularArtistsInitial());

  // List of popular artists to search for (using diverse artist names)
  final List<String> _popularArtistNames = [
    'Taylor Swift',
    'Drake',
    'Bad Bunny',
    'The Weeknd',
    'Ariana Grande',
    'Ed Sheeran',
    'Billie Eilish',
    'Post Malone',
    'Dua Lipa',
    'Bruno Mars',
  ];

  Future<void> getPopularArtists() async {
    try {
      emit(SpotifyPopularArtistsLoading());

      final List<SpotifyArtistEntity> popularArtists = [];

      // Search for each popular artist and take the first result
      for (String artistName in _popularArtistNames) {
        try {
          final searchResults = await sl<SearchSpotifyArtistsUseCase>().call(
            params: artistName,
          );
          if (searchResults.isNotEmpty) {
            // Take the first (most relevant) result
            final firstResult = searchResults.first;
            // Only add if it has a reasonable follower count (indicates it's a real popular artist)
            if (firstResult.followers > 100000) {
              popularArtists.add(firstResult);
            }
          }

          // Add small delay to avoid rate limiting
          await Future.delayed(Duration(milliseconds: 200));

          // Break if we have enough artists
          if (popularArtists.length >= 8) break;
        } catch (e) {
          // Continue with other artists if one fails
          print('Failed to search for $artistName: $e');
        }
      }

      if (popularArtists.isNotEmpty) {
        // Sort by follower count (descending)
        popularArtists.sort((a, b) => b.followers.compareTo(a.followers));
        emit(SpotifyPopularArtistsLoaded(popularArtists));
      } else {
        emit(
          SpotifyPopularArtistsError(
            'No popular artists found. Please check your internet connection.',
          ),
        );
      }
    } catch (e) {
      emit(
        SpotifyPopularArtistsError(
          'Failed to load popular artists: ${e.toString()}',
        ),
      );
    }
  }
}
