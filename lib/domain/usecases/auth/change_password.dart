import 'package:dartz/dartz.dart';
import 'package:sporify/domain/usecases/usecase.dart';
import 'package:sporify/data/models/auth/change_password_request.dart';
import 'package:sporify/domain/repository/auth/auth.dart';

import 'package:sporify/core/di/service_locator.dart';

class ChangePasswordUseCase implements UseCase<Either, ChangePasswordRequest> {
  @override
  Future<Either> call({ChangePasswordRequest? params}) {
    return sl<AuthRepository>().changePassword(params!);
  }
}
