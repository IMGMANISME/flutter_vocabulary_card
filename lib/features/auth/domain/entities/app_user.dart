import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [id, displayName, email, photoUrl];
}
