import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../di/auth_dependencies.dart';
import '../../domain/entities/app_user.dart';

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final useCase = ref.watch(observeAuthStateUseCaseProvider);
  return useCase.call();
});

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    final result = await ref.read(signInWithGoogleUseCaseProvider).call();

    result.match(
      (failure) => state = AsyncError(_mapFailure(failure), StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    final result = await ref.read(signOutUseCaseProvider).call();

    result.match(
      (failure) => state = AsyncError(_mapFailure(failure), StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  Object _mapFailure(Failure failure) {
    return Exception(failure.message);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
