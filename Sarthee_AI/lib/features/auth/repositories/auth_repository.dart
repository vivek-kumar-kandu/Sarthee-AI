import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? get currentUser;

  Stream<User?> get authStateChanges;

  Future<void> initialize();

  Future<UserCredential> signup({
    required String email,
    required String password,
    String? name,
  });

  Future<UserCredential> login({
    required String email,
    required String password,
  });

  Future<UserCredential> googleLogin();

  Future<String?> getFirebaseToken({bool forceRefresh = false});

  Future<void> logout();
}
