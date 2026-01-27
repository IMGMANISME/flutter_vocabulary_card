import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
}

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // No state to initialize mostly, just methods
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await ref.read(firebaseAuthProvider).signInWithCredential(credential);
      }
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await GoogleSignIn().signOut();
      await ref.read(firebaseAuthProvider).signOut();
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
