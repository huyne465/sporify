import 'package:dartz/dartz.dart';
import 'package:sporify/domain/usecases/usecase.dart';
import 'package:sporify/data/models/auth/signin_user_request.dart';
import 'package:sporify/domain/repository/auth/auth.dart';
import 'package:sporify/core/di/service_locator.dart';

class SignInUseCase implements UseCase<Either, SigninUserRequest> {
  @override
  Future<Either> call({SigninUserRequest? params}) {
    return sl<AuthRepository>().signIn(params!);
  }
}
