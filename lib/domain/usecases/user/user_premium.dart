import 'package:dartz/dartz.dart';
import 'package:sporify/domain/usecases/usecase.dart';
import 'package:sporify/data/dataSources/user/user_premium_service.dart';
import 'package:sporify/core/di/service_locator.dart';

class UpdateUserToPremiumUseCase
    implements UseCase<Either<String, bool>, String> {
  @override
  Future<Either<String, bool>> call({String? params}) {
    return sl<UserPremiumService>().updateUserToPremium(params!);
  }
}

class CheckUserPremiumStatusUseCase
    implements UseCase<Either<String, bool>, void> {
  @override
  Future<Either<String, bool>> call({void params}) {
    return sl<UserPremiumService>().checkUserPremiumStatus();
  }
}

class GetUserPremiumInfoUseCase
    implements UseCase<Either<String, Map<String, dynamic>?>, void> {
  @override
  Future<Either<String, Map<String, dynamic>?>> call({void params}) {
    return sl<UserPremiumService>().getUserPremiumInfo();
  }
}
