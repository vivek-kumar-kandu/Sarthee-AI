import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../profile/domain/entities/profile_entity.dart';
import '../../profile/data/models/profile_response_model.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../profile/services/profile_service.dart';
import '../../profile/setup/profile_completion.dart';
import '../../../core/error/auth_exception.dart';
import '../auth_service.dart';

enum AuthBootstrapStatus { authenticated, unauthenticated, error, offline }

class AuthBootstrapResult {
  const AuthBootstrapResult({
    required this.status,
    this.profile,
    this.errorMessage,
    this.isOffline = false,
    this.retryable = false,
  });

  final AuthBootstrapStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;
  final bool isOffline;
  final bool retryable;

  bool get isAuthenticated => status == AuthBootstrapStatus.authenticated;
}

class AuthBootstrapService {
  AuthBootstrapService._({
    AuthService? authService,
    ProfileService? profileService,
    ProfileRepository? profileRepository,
    Connectivity? connectivity,
  }) : _authService = authService ?? AuthService.instance,
       _profileService = profileService ?? ProfileService(),
       _profileRepository = profileRepository ?? ProfileRepository(),
       _connectivity = connectivity ?? Connectivity();

  static final AuthBootstrapService instance = AuthBootstrapService._();

  final AuthService _authService;
  final ProfileService _profileService;
  final ProfileRepository _profileRepository;
  final Connectivity _connectivity;

  bool _sessionValidated = false;

  bool get isSessionValidated => _sessionValidated;

  void resetSessionValidation() {
    _sessionValidated = false;
  }

  Future<bool> _hasNetworkConnection() async {
    try {
      final List<ConnectivityResult> results = await _connectivity
          .checkConnectivity();
      return results.any(
        (ConnectivityResult result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet ||
            result == ConnectivityResult.vpn,
      );
    } catch (_) {
      return true;
    }
  }

  /// Validates Firebase token and backend profile in one pipeline.
  Future<AuthBootstrapResult> validateSession({
    bool forceRefresh = true,
  }) async {
    debugPrint("========== VALIDATE_SESSION_CALLED ==========");
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      debugPrint('[AuthBootstrap] validateSession() no Firebase user');
      return const AuthBootstrapResult(
        status: AuthBootstrapStatus.unauthenticated,
      );
    }

    final bool online = await _hasNetworkConnection();
    if (!online) {
      debugPrint('[AuthBootstrap] validateSession() offline');
      return const AuthBootstrapResult(
        status: AuthBootstrapStatus.offline,
        errorMessage: 'No internet connection. Please check your network.',
        isOffline: true,
        retryable: true,
      );
    }

    debugPrint('[AuthBootstrap] validateSession() uid=${currentUser.uid}');

    try {
      debugPrint('[AuthBootstrap] Refreshing Firebase token');
      await _authService.getFirebaseToken(forceRefresh: forceRefresh);

      debugPrint('[AuthBootstrap] Validating backend profile');
      final ProfileResponseModel response = await _profileService.getProfile();

      final ProfileEntity profile = response.toEntity();

      if (profile.firebaseUid.isNotEmpty &&
          profile.firebaseUid != currentUser.uid) {
        debugPrint('[AuthBootstrap] Profile uid mismatch');
        await _safeLogout();
        return const AuthBootstrapResult(
          status: AuthBootstrapStatus.unauthenticated,
          errorMessage: 'Session validation failed.',
        );
      }

      await _profileRepository.getProfile(forceRefresh: true);

      _sessionValidated = true;
      debugPrint('[AuthBootstrap] Backend validation succeeded');

      return AuthBootstrapResult(
        status: AuthBootstrapStatus.authenticated,
        profile: profile,
      );
    } on AuthException catch (error) {
      debugPrint('[AuthBootstrap] Auth error: $error');

      if (error.type == AuthErrorType.networkFailure) {
        return AuthBootstrapResult(
          status: AuthBootstrapStatus.offline,
          errorMessage: error.message,
          isOffline: true,
          retryable: error.retryable,
        );
      }

      if (error.type == AuthErrorType.expiredSession) {
        await _safeLogout();
        return AuthBootstrapResult(
          status: AuthBootstrapStatus.unauthenticated,
          errorMessage: error.message,
        );
      }

      await _safeLogout();
      return AuthBootstrapResult(
        status: AuthBootstrapStatus.error,
        errorMessage: error.message,
        retryable: error.retryable,
      );
    } on ProfileException catch (error) {
      debugPrint('[AuthBootstrap] Profile error: $error');

      if (error.retryable) {
        return AuthBootstrapResult(
          status: AuthBootstrapStatus.offline,
          errorMessage: error.message,
          isOffline: error.statusCode == null,
          retryable: true,
        );
      }

      if (error.statusCode == 401) {
        await _safeLogout();
        return AuthBootstrapResult(
          status: AuthBootstrapStatus.unauthenticated,
          errorMessage: error.message,
        );
      }

      await _safeLogout();
      return AuthBootstrapResult(
        status: AuthBootstrapStatus.error,
        errorMessage: error.message,
        retryable: error.retryable,
      );
    } catch (error) {
      debugPrint('[AuthBootstrap] Unexpected error: $error');
      await _safeLogout();
      return AuthBootstrapResult(
        status: AuthBootstrapStatus.error,
        errorMessage: error.toString(),
        retryable: true,
      );
    }
  }

  /// Checks whether a loaded profile satisfies completion requirements.
  bool checkProfileCompletion(ProfileEntity? profile) {
    return isProfileComplete(profile);
  }

  Future<void> _safeLogout() async {
    try {
      await _authService.logout();
      debugPrint('[AuthBootstrap] Logged out due to failed validation');
    } catch (_) {}
    _sessionValidated = false;
  }
}
