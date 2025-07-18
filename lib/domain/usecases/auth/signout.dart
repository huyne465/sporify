import 'package:sporify/core/usecase/usecase.dart';
import 'package:sporify/domain/repository/auth/auth.dart';
import 'package:sporify/di/service_locator.dart';

class SignOutUseCase implements UseCase<void, void> {
  @override
  Future<void> call({void params}) async {
    return await sl<AuthRepository>().signOut();
  }
}
