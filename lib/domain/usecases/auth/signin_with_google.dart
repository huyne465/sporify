import 'package:dartz/dartz.dart';
import 'package:sporify/domain/usecases/usecase.dart';
import 'package:sporify/domain/repository/auth/auth.dart';
import 'package:sporify/core/di/service_locator.dart';

class SignInWithGoogleUseCase implements UseCase<Either, void> {
  @override
  Future<Either> call({void params}) {
    return sl<AuthRepository>().signInWithGoogle();
  }
}
