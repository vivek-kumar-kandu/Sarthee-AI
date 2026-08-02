import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/auth/token_manager.dart';
import '../../core/error/auth_exception.dart';
import 'repositories/auth_repository.dart';
import 'auth_sync_service.dart';

class AuthService implements AuthRepository {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  bool get isSignedIn => currentUser != null;

  @override
  Future<void> initialize() async {
    await _googleSignIn.initialize();
  }

  @override
  Future<UserCredential> signup({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (name != null && name.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(name.trim());
        await credential.user?.reload();
      }

      await syncUser();
      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthException.fromFirebaseAuthException(error);
    } catch (error) {
      throw AuthException.unknown(error.toString());
    }
  }

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      await syncUser();
      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthException.fromFirebaseAuthException(error);
    } catch (error) {
      throw AuthException.unknown(error.toString());
    }
  }

  @override
  Future<UserCredential> googleLogin() async {
    try {
      await initialize();
      final googleAccount = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuthentication =
          googleAccount.authentication;

      final String? idToken = googleAuthentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw AuthException.unknown('Google sign-in failed.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential firebaseCredential = await _firebaseAuth
          .signInWithCredential(credential);

      await syncUser();
      return firebaseCredential;
    } on FirebaseAuthException catch (error) {
      throw AuthException.fromFirebaseAuthException(error);
    } catch (error) {
      if (error is AuthException) rethrow;
      throw AuthException.unknown(error.toString());
    }
  }

  @override
  Future<String?> getFirebaseToken({bool forceRefresh = false}) async {
    return TokenManager.instance.getToken(forceRefresh: forceRefresh);
  }

  Future<void> syncUser() async {
    await AuthSyncService.instance.syncUser();
  }

  @override
  Future<void> logout() async {
    await TokenManager.instance.clearToken();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
  }
}
