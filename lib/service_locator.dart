import 'package:get_it/get_it.dart';
import 'package:sporify/data/repository/auth/auth_repository_implementation.dart';
import 'package:sporify/data/repository/song/song_repository_implentation.dart';
import 'package:sporify/data/repository/lyrics/lyrics_repository_implementation.dart';
import 'package:sporify/data/repository/artist/artist_repository_impl.dart';
import 'package:sporify/data/sources/artist/artist_firebase_service.dart';
import 'package:sporify/data/sources/auth/auth_firebase_service.dart';
import 'package:sporify/data/sources/song/song_firebase_service.dart';
import 'package:sporify/data/sources/lyrics/lyrics_api_service.dart';
import 'package:sporify/domain/repository/auth/auth.dart';
import 'package:sporify/domain/repository/song/song.dart';
import 'package:sporify/domain/repository/lyrics/lyrics.dart';
import 'package:sporify/domain/repository/artist/artist.dart';
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
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/domain/usecases/song/get_songs_by_artist.dart';
import 'package:sporify/domain/usecases/auth/change_password.dart';
import 'package:sporify/domain/usecases/auth/signin_with_google.dart';
import 'package:sporify/domain/usecases/auth/signin_with_facebook.dart';
import 'package:sporify/domain/usecases/auth/reset_password.dart';
import 'package:sporify/data/repositories/playlist_repository.dart';
import 'package:sporify/data/repositories/favorite_songs_repository.dart';
import 'package:sporify/presentation/playlist/bloc/playlist_cubit.dart';
import 'package:sporify/presentation/playlist/bloc/playlist_songs_cubit.dart';

final sl = GetIt.instance;
Future<void> initializeDependencies() async {
  //auth
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImplementation());
  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<SignInUseCase>(SignInUseCase());
  sl.registerSingleton<ChangePasswordUseCase>(ChangePasswordUseCase());
  sl.registerSingleton<ResetPasswordUseCase>(ResetPasswordUseCase());
  // Use Cases
  sl.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase());
  sl.registerSingleton<SignInWithFacebookUseCase>(
    SignInWithFacebookUseCase(),
  ); //repositories
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
  //add to add or remove favorite, is favorite
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
}
