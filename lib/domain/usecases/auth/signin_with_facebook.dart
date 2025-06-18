import 'package:dartz/dartz.dart';
import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/repository/auth/auth.dart';
import 'package:sporify/service_locator.dart';

class SignInWithFacebookUseCase implements UseCase<Either, void> {
  @override
  Future<Either> call({void params}) {
    return sl<AuthRepository>().signInWithFacebook();
  }
}
