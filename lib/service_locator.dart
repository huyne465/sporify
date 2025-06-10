import 'package:get_it/get_it.dart';
import 'package:sporify/data/repository/auth/auth_repository_implementation.dart';
import 'package:sporify/data/repository/song/song_repository_implentation.dart';
import 'package:sporify/data/repository/lyrics/lyrics_repository_implementation.dart';
import 'package:sporify/data/sources/auth/auth_firebase_service.dart';
import 'package:sporify/data/sources/song/song_firebase_service.dart';
import 'package:sporify/data/sources/lyrics/lyrics_api_service.dart';
import 'package:sporify/domain/repository/auth/auth.dart';
import 'package:sporify/domain/repository/song/song.dart';
import 'package:sporify/domain/repository/lyrics/lyrics.dart';
import 'package:sporify/domain/usecases/auth/signin.dart';
import 'package:sporify/domain/usecases/auth/signup.dart';
import 'package:sporify/domain/usecases/song/add_or_remove_song.dart';
import 'package:sporify/domain/usecases/song/get_new_songs.dart';
import 'package:sporify/domain/usecases/song/get_play_list.dart';
import 'package:sporify/domain/usecases/song/is_favorite.dart';
import 'package:sporify/domain/usecases/lyrics/get_lyrics.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';

final sl = GetIt.instance;
Future<void> initializeDependencies() async {
  //auth
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImplementation());
  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<SignInUseCase>(SignInUseCase());

  //songs
  sl.registerSingleton<SongFirebaseService>(SongFirebaseServiceImpl());
  sl.registerSingleton<SongRepository>(SongRepositoryImplementation());
  sl.registerSingleton<GetNewSongsUseCase>(GetNewSongsUseCase());
  sl.registerSingleton<GetPlayListUseCase>(GetPlayListUseCase());
  //add to add or remove favorite, is favorite
  sl.registerSingleton<AddOrRemoveSongUseCase>(AddOrRemoveSongUseCase());
  sl.registerSingleton<IsFavoriteUseCase>(IsFavoriteUseCase());

  //lyrics
  sl.registerSingleton<LyricsApiService>(LyricsApiServiceImpl());
  sl.registerSingleton<LyricsRepository>(LyricsRepositoryImplementation());
  sl.registerSingleton<GetLyricsUseCase>(GetLyricsUseCase());

  //music player
  sl.registerSingleton<GlobalMusicPlayerCubit>(GlobalMusicPlayerCubit());
}
