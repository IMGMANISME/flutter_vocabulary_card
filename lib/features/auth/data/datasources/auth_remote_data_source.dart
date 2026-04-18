import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<AppUserModel?> authStateChanges();

  Future<void> signInWithGoogle();

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({required this.auth, required this.googleSignIn});

  @override
  Stream<AppUserModel?> authStateChanges() {
    return auth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }

      return AppUserModel.fromFirebaseUser(user);
    });
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw ServerException('Google sign-in was canceled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await auth.signOut();
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}
