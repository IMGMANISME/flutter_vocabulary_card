import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;

class AuthService extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthService() {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        _user = FirebaseAuth.instance.currentUser;
        notifyListeners();
      }

      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {}
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final google.GoogleSignIn googleSignIn = google.GoogleSignIn();

      // Trigger the authentication flow
      final google.GoogleSignInAccount? googleUser = await googleSignIn
          .signIn();

      if (googleUser != null) {
        // Obtain the auth details from the request
        final google.GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithCredential(credential);

        // Listener in constructor will update _user
      } else {
        // User canceled the sign-in
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      ScaffoldMessengerHelper.showError('Login failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await google.GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      // Listener will update state
    } catch (e) {}
  }
}

class ScaffoldMessengerHelper {
  static void showError(String message) {
    // TODO: Implement a better way to show errors, maybe via a stream or a key
  }
}
