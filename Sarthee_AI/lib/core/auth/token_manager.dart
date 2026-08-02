import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../error/auth_exception.dart';
import '../storage/secure_storage.dart';

class TokenManager {
  TokenManager._();

  static final TokenManager instance = TokenManager._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> getToken({bool forceRefresh = false}) async {
    final User? user = _firebaseAuth.currentUser;

    if (user == null) {
      throw AuthException.expiredSession();
    }

    try {
      final String? token = await user.getIdToken(forceRefresh);

      // ================= DEBUG =================
      final IdTokenResult idTokenResult = await user.getIdTokenResult(
        forceRefresh,
      );

      if (kDebugMode) {
        debugPrint("=================================");
        debugPrint("🔥 FIREBASE TOKEN DEBUG");
        debugPrint("UID          : ${user.uid}");
        debugPrint("Email        : ${user.email}");
        debugPrint("Token Length : ${token?.length}");

        if (token != null && token.length >= 25) {
          debugPrint("Token Start  : ${token.substring(0, 25)}...");
        } else {
          debugPrint("Token Start  : NULL");
        }

        debugPrint("Issued At    : ${idTokenResult.issuedAtTime}");
        debugPrint("Expires At   : ${idTokenResult.expirationTime}");
        debugPrint("=================================");
      }
      // =========================================

      if (_isExpiredOrMissing(token)) {
        if (!forceRefresh) {
          return getToken(forceRefresh: true);
        }

        throw AuthException.expiredSession();
      }

      await SecureStorage.instance.saveToken(token!);

      if (kDebugMode) {
        debugPrint("✅ Token saved to SecureStorage");
      }

      return token;
    } on FirebaseAuthException catch (error) {
      if (kDebugMode) {
        debugPrint("❌ FirebaseAuthException");
        debugPrint("Code    : ${error.code}");
        debugPrint("Message : ${error.message}");
      }

      throw AuthException.fromFirebaseAuthException(error);
    } catch (error) {
      if (error is AuthException) {
        rethrow;
      }

      if (kDebugMode) {
        debugPrint("❌ Unknown Token Error");
        debugPrint(error.toString());
      }

      throw AuthException.unknown(error.toString());
    }
  }

  bool _isExpiredOrMissing(String? token) {
    return token == null || token.isEmpty;
  }

  Future<String?> refreshToken() async {
    return getToken(forceRefresh: true);
  }

  Future<bool> hasValidSession() async {
    final User? user = _firebaseAuth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      await getToken(forceRefresh: false);
      return true;
    } on AuthException catch (error) {
      if (error.type == AuthErrorType.expiredSession) {
        return false;
      }

      rethrow;
    }
  }

  Future<void> clearToken() async {
    await SecureStorage.instance.deleteToken();
  }

  Future<void> clearTokenAndSignOut() async {
    await clearToken();

    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      // Ignore sign-out errors.
    }
  }
}
