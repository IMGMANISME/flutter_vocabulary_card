import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<Either<Failure, void>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();
}
