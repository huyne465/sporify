import 'package:get_it/get_it.dart';
import 'package:sporify/data/repositories/auth/auth_repository_impl.dart';
import 'package:sporify/data/repositories/song/song_repository_impl.dart';
import 'package:sporify/data/repositories/lyrics/lyrics_repository_impl.dart';
import 'package:sporify/data/repositories/artist/artist_repository_impl.dart';
import 'package:sporify/data/repositories/spotify/spotify_repository_impl.dart';
import 'package:sporify/data/dataSources/artist/artist_firebase_service.dart';
import 'package:sporify/data/dataSources/auth/auth_firebase_service.dart';
import 'package:sporify/data/dataSources/song/song_firebase_service.dart';
import 'package:sporify/data/dataSources/lyrics/lyrics_api_service.dart';
import 'package:sporify/data/dataSources/spotify/spotify_api_service.dart';
import 'package:sporify/data/dataSources/spotify/spotify_player_service.dart';
import 'package:sporify/data/dataSources/user/user_premium_service.dart';
import 'package:sporify/domain/repository/auth/auth.dart';
import 'package:sporify/domain/repository/song/song.dart';
import 'package:sporify/domain/repository/lyrics/lyrics.dart';
import 'package:sporify/domain/repository/artist/artist.dart';
import 'package:sporify/domain/repository/spotify/spotify_repository.dart';
import 'package:sporify/domain/usecases/auth/signin.dart';
import 'package:sporify/domain/usecases/auth/signup.dart';
import 'package:sporify/domain/usecases/song/add_or_remove_song.dart';
import 'package:sporify/domain/usecases/song/get_new_songs.dart';
import 'package:sporify/domain/usecases/song/get_play_list.dart';
import 'package:sporify/domain/usecases/song/is_favorite.dart';
import 'package:sporify/domain/usecases/lyrics/get_lyrics.dart';
import 'package:sporify/domain/usecases/artist/get_artists.dart';
import 'package:sporify/domain/usecases/artist/get_artist.dart';
import 'package:sporify/domain/usecases/song/search_songs.dart';
import 'package:sporify/domain/usecases/spotify/search_spotify_artists.dart';
import 'package:sporify/domain/usecases/spotify/get_artist_top_tracks.dart';
import 'package:sporify/domain/usecases/spotify/get_popular_artists.dart';
import 'package:sporify/domain/usecases/spotify/get_popular_tracks.dart';
import 'package:sporify/domain/usecases/spotify/get_popular_albums.dart';
import 'package:sporify/domain/usecases/user/user_premium.dart';

import 'package:sporify/domain/usecases/song/get_songs_by_artist.dart';
import 'package:sporify/domain/usecases/auth/change_password.dart';
import 'package:sporify/domain/usecases/auth/signin_with_google.dart';
import 'package:sporify/domain/usecases/auth/signin_with_facebook.dart';
import 'package:sporify/domain/usecases/auth/reset_password.dart';
import 'package:sporify/domain/repository/playlist/playlist_repository.dart';
import 'package:sporify/domain/repository/favorite/favorite_songs_repository.dart';

import 'package:sporify/domain/usecases/spotify/get_track_with_preview.dart';
import 'package:sporify/core/services/event_bus_service.dart';
import 'package:sporify/core/services/network_connectivity.dart';
import 'package:sporify/core/services/connection_error_handler.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/presentation/playlist/bloc/playlist_cubit.dart';
import 'package:sporify/presentation/spotify/bloc/spotify_player_cubit.dart';

final sl = GetIt.instance;
Future<void> initializeDependencies() async {
  //network services
  sl.registerSingleton<EventBusService>(EventBusService());
  sl.registerSingleton<NetworkConnectivity>(NetworkConnectivity());
  sl.registerSingleton<ConnectionErrorHandler>(ConnectionErrorHandler());

  //auth
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImplementation());
  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<SignInUseCase>(SignInUseCase());
  sl.registerSingleton<ChangePasswordUseCase>(ChangePasswordUseCase());
  sl.registerSingleton<ResetPasswordUseCase>(ResetPasswordUseCase());
  sl.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase());
  sl.registerSingleton<SignInWithFacebookUseCase>(SignInWithFacebookUseCase());

  //repositories
  sl.registerSingleton<PlaylistRepository>(PlaylistRepository());
  sl.registerSingleton<FavoriteSongsRepository>(FavoriteSongsRepository());

  //playlist
  sl.registerSingleton<PlaylistCubit>(PlaylistCubit(sl<PlaylistRepository>()));

  //songs
  sl.registerSingleton<SongFirebaseService>(SongFirebaseServiceImpl());
  sl.registerSingleton<SongRepository>(SongRepositoryImplementation());
  sl.registerSingleton<GetNewSongsUseCase>(GetNewSongsUseCase());
  sl.registerSingleton<GetPlayListUseCase>(GetPlayListUseCase());
  sl.registerSingleton<GetSongsByArtistUseCase>(GetSongsByArtistUseCase());
  sl.registerSingleton<SearchSongsUseCase>(SearchSongsUseCase());
  sl.registerSingleton<AddOrRemoveSongUseCase>(AddOrRemoveSongUseCase());
  sl.registerSingleton<IsFavoriteUseCase>(IsFavoriteUseCase());

  //lyrics
  sl.registerSingleton<LyricsApiService>(LyricsApiServiceImpl());
  sl.registerSingleton<LyricsRepository>(LyricsRepositoryImplementation());
  sl.registerSingleton<GetLyricsUseCase>(GetLyricsUseCase());

  //music player
  sl.registerSingleton<GlobalMusicPlayerCubit>(GlobalMusicPlayerCubit());

  //artist
  sl.registerSingleton<ArtistFirebaseService>(ArtistFirebaseServiceImpl());
  sl.registerSingleton<ArtistRepository>(ArtistRepositoryImpl());
  sl.registerSingleton<GetArtistsUseCase>(GetArtistsUseCase());
  sl.registerSingleton<GetArtistUseCase>(GetArtistUseCase());

  // Spotify services
  sl.registerSingleton<SpotifyApiService>(SpotifyApiServiceImpl());
  sl.registerSingleton<SpotifyPlayerService>(SpotifyPlayerServiceImpl());
  sl.registerSingleton<SpotifyRepository>(
    SpotifyRepositoryImpl(spotifyApiService: sl<SpotifyApiService>()),
  );

  // Spotify use cases
  sl.registerSingleton<SearchSpotifyArtistsUseCase>(
    SearchSpotifyArtistsUseCase(),
  );
  sl.registerSingleton<GetSpotifyArtistTopTracksUseCase>(
    GetSpotifyArtistTopTracksUseCase(),
  );
  sl.registerSingleton<GetPopularTracksUseCase>(GetPopularTracksUseCase());
  sl.registerSingleton<GetArtistTopTracksUseCase>(GetArtistTopTracksUseCase());
  sl.registerSingleton<GetPopularArtistsUseCase>(GetPopularArtistsUseCase());
  sl.registerSingleton<GetPopularAlbumsUseCase>(GetPopularAlbumsUseCase());
  sl.registerSingleton<GetTrackWithPreviewUseCase>(
    GetTrackWithPreviewUseCase(),
  );

  // Spotify Player (preview only)
  sl.registerLazySingleton(() => SpotifyPlayerCubit());

  // User Premium services
  sl.registerSingleton<UserPremiumService>(UserPremiumServiceImpl());
  sl.registerSingleton<UpdateUserToPremiumUseCase>(
    UpdateUserToPremiumUseCase(),
  );
  sl.registerSingleton<CheckUserPremiumStatusUseCase>(
    CheckUserPremiumStatusUseCase(),
  );
  sl.registerSingleton<GetUserPremiumInfoUseCase>(GetUserPremiumInfoUseCase());
}
