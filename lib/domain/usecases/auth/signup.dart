import 'package:dartz/dartz.dart';

import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/data/models/auth/create_user_request.dart';
import 'package:sporify/domain/repository/auth/auth.dart';
import 'package:sporify/service_locator.dart';

class SignupUseCase implements UseCase<Either, CreateUserRequest> {
  @override
  Future<Either> call({CreateUserRequest? params}) {
    // TODO: implement call
    return sl<AuthRepository>().signUp(params!);
  }
}
