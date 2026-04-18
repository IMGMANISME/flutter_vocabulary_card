import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.displayName,
    required super.email,
    required super.photoUrl,
  });

  factory AppUserModel.fromFirebaseUser(User user) {
    return AppUserModel(
      id: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }
}
