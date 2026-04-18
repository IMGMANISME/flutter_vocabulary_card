import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class ObserveAuthStateUseCase {
  final AuthRepository _repository;

  ObserveAuthStateUseCase(this._repository);

  Stream<AppUser?> call() {
    return _repository.authStateChanges();
  }
}
