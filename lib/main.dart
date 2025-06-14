import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sporify/core/configs/themes/app_theme.dart';
import 'package:sporify/firebase_options.dart';
import 'package:sporify/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/presentation/splash/pages/splash.dart';
import 'package:sporify/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Correct way to initialize HydratedStorage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => GlobalMusicPlayerCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp(
          title: 'Flutter Demo',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          home: const AppWithMiniPlayer(),
        ),
      ),
    );
  }
}

class AppWithMiniPlayer extends StatelessWidget {
  const AppWithMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashPage(); // Remove the scaffold wrapper, let splash handle navigation
  }
}
