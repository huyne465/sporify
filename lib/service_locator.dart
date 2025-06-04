import 'package:get_it/get_it.dart';
import 'package:sporify/data/repository/auth/auth_repository_implementation.dart';
import 'package:sporify/data/sources/auth/auth_firebase_service.dart';
import 'package:sporify/domain/repository/auth/auth.dart';
import 'package:sporify/domain/usecases/auth/signin.dart';
import 'package:sporify/domain/usecases/auth/signup.dart';

final sl = GetIt.instance;
Future<void> initializeDependencies() async {
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImplementation());
  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<SignInUseCase>(SignInUseCase());
}
