import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:sporify/core/configs/themes/app_theme.dart';
import 'package:sporify/core/routes/app_pages.dart';
import 'package:sporify/core/routes/app_routes.dart';
import 'package:sporify/firebase_options.dart';
import 'package:sporify/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_cubit.dart';
import 'package:sporify/presentation/music_player/bloc/global_music_player_state.dart';
import 'package:sporify/presentation/music_player/widgets/mini_player.dart';
import 'package:sporify/presentation/splash/pages/splash.dart';
import 'package:sporify/di/service_locator.dart';
import 'package:sporify/core/services/network_connectivity.dart';

Future<void> main() async {
  try {
    print('🚀 App starting...');
    WidgetsFlutterBinding.ensureInitialized();

    print('💾 Initializing HydratedStorage...');
    // Correct way to initialize HydratedStorage
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorage.webStorageDirectory
          : await getApplicationDocumentsDirectory(),
    );

    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('📦 Initializing Dependencies...');
    await initializeDependencies();

    // Initialize network connectivity monitoring
    print('🌐 Initializing Network Connectivity Monitoring...');
    sl<NetworkConnectivity>().initialize();

    print('✅ App initialized successfully');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('❗ Error during app initialization: $e');
    print('📍 Stack trace: $stackTrace');

    // Run app anyway với error handling
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('App initialization failed'),
                SizedBox(height: 8),
                Text('Error: $e', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
        builder: (context, mode) => GetMaterialApp(
          title: 'Sporify',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
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
    return Scaffold(
      body: const SplashPage(),
      bottomNavigationBar:
          BlocBuilder<GlobalMusicPlayerCubit, GlobalMusicPlayerState>(
            builder: (context, state) {
              if (state.currentSong == null) {
                return const SizedBox.shrink();
              }
              return const MiniPlayer();
            },
          ),
    );
  }
}
