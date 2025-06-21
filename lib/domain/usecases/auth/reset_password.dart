import 'package:dartz/dartz.dart';
import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/repository/auth/auth.dart';
import 'package:sporify/service_locator.dart';

class ResetPasswordUseCase implements UseCase<Either, String> {
  @override
  Future<Either> call({String? params}) {
    return sl<AuthRepository>().resetPassword(params!);
  }
}
