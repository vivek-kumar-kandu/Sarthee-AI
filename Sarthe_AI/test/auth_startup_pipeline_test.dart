import 'package:flutter_test/flutter_test.dart';

import 'package:sarthee_ai/app/router/route_guards.dart';
import 'package:sarthee_ai/app/router/route_paths.dart';
import 'package:sarthee_ai/features/auth/state/auth_startup_state.dart';
import 'package:sarthee_ai/features/profile/domain/entities/profile_entity.dart';
import 'package:sarthee_ai/features/profile/setup/profile_completion.dart';

RouteGuardState _guard({
  AuthenticationStatus auth = AuthenticationStatus.unknown,
  bool initialized = false,
  bool profileComplete = false,
  bool online = true,
}) {
  return RouteGuardState(
    authenticationStatus: auth,
    onboardingCompleted: true,
    isInitialized: initialized,
    isProfileComplete: profileComplete,
    isOnline: online,
  );
}

void main() {
  group('AuthStartupState', () {
    test('step messages match enterprise pipeline labels', () {
      expect(
        const AuthStartupState(
          phase: AuthStartupPhase.checkingFirebaseSession,
        ).stepMessage,
        'Checking Session',
      );
      expect(
        const AuthStartupState(
          phase: AuthStartupPhase.restoringToken,
        ).stepMessage,
        'Restoring User',
      );
      expect(
        const AuthStartupState(
          phase: AuthStartupPhase.validatingBackendSession,
        ).stepMessage,
        'Validating Profile',
      );
      expect(
        const AuthStartupState(
          phase: AuthStartupPhase.initializing,
        ).stepMessage,
        'Preparing Sarthee',
      );
    });

    test('bootstrapping phases are not terminal', () {
      expect(AuthStartupPhase.initializing.isBootstrapping, isTrue);
      expect(AuthStartupPhase.authenticated.isBootstrapping, isFalse);
      expect(AuthStartupPhase.authenticated.isTerminal, isTrue);
    });
  });

  group('Profile completion', () {
    test('requires mandatory profile fields', () {
      final ProfileEntity incomplete = ProfileEntity(
        id: '1',
        firebaseUid: 'u1',
        email: 'a@b.com',
        name: 'User',
        picture: null,
        role: 'user',
        profile: UserProfile(),
        location: UserLocation(),
        preferences: UserPreferences(),
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        lastLoginAt: null,
      );

      expect(isProfileComplete(incomplete), isFalse);

      final ProfileEntity complete = ProfileEntity(
        id: '1',
        firebaseUid: 'u1',
        email: 'a@b.com',
        name: 'User',
        picture: null,
        role: 'user',
        profile: UserProfile(gender: 'Male', dob: '2000-01-01'),
        location: UserLocation(city: 'Delhi'),
        preferences: UserPreferences(language: 'English'),
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        lastLoginAt: null,
      );

      expect(isProfileComplete(complete), isTrue);
    });
  });
  group('RouteGuards — auth startup pipeline', () {
    test('fresh install keeps user on splash until initialized', () {
      final String? redirect = RouteGuards.redirectForPath(
        path: RoutePaths.home,
        guardState: _guard(),
      );

      expect(redirect, RoutePaths.splash);
    });

    test('unauthenticated user redirects to login after bootstrap', () {
      expect(
        RouteGuards.redirectForPath(
          path: RoutePaths.splash,
          guardState: _guard(
            auth: AuthenticationStatus.unauthenticated,
            initialized: true,
          ),
        ),
        RoutePaths.login,
      );

      expect(
        RouteGuards.redirectForPath(
          path: RoutePaths.home,
          guardState: _guard(
            auth: AuthenticationStatus.unauthenticated,
            initialized: true,
          ),
        ),
        isNotNull,
      );
    });

    test('authenticated incomplete profile redirects to profile setup', () {
      final String? redirect = RouteGuards.redirectForPath(
        path: RoutePaths.home,
        guardState: _guard(
          auth: AuthenticationStatus.authenticated,
          initialized: true,
          profileComplete: false,
        ),
      );

      expect(redirect, RoutePaths.profileSetup);
    });

    test('authenticated complete profile allows home', () {
      final String? redirect = RouteGuards.redirectForPath(
        path: RoutePaths.home,
        guardState: _guard(
          auth: AuthenticationStatus.authenticated,
          initialized: true,
          profileComplete: true,
        ),
      );

      expect(redirect, isNull);
    });

    test('auth in progress blocks protected routes to splash', () {
      expect(
        RouteGuards.redirectForPath(
          path: RoutePaths.home,
          guardState: _guard(auth: AuthenticationStatus.unknown),
        ),
        RoutePaths.splash,
      );
    });

    test('auth in progress blocks guest login route to splash', () {
      expect(
        RouteGuards.redirectForPath(
          path: RoutePaths.login,
          guardState: _guard(auth: AuthenticationStatus.unknown),
        ),
        RoutePaths.splash,
      );
    });

    test('expired session routes unauthenticated users to login', () {
      expect(
        RouteGuards.redirectForPath(
          path: RoutePaths.home,
          guardState: _guard(
            auth: AuthenticationStatus.unauthenticated,
            initialized: true,
          ),
        ),
        isNotNull,
      );
    });

    test('offline bootstrap keeps splash accessible for retry UX', () {
      expect(
        RouteGuards.redirectForPath(
          path: RoutePaths.splash,
          guardState: _guard(
            auth: AuthenticationStatus.unknown,
            initialized: true,
            online: false,
          ),
        ),
        isNull,
      );
    });

    test('splash is the only allowed route during bootstrap', () {
      expect(
        RouteGuards.redirectForPath(
          path: RoutePaths.splash,
          guardState: _guard(auth: AuthenticationStatus.unknown),
        ),
        isNull,
      );

      expect(
        RouteGuards.redirectForPath(
          path: RoutePaths.profileSetup,
          guardState: _guard(auth: AuthenticationStatus.unknown),
        ),
        RoutePaths.splash,
      );
    });
  });

  group('Logout session reset', () {
    test('unauthenticated terminal state clears user reference', () {
      const AuthStartupState loggedOut = AuthStartupState(
        phase: AuthStartupPhase.unauthenticated,
        bootstrapComplete: true,
      );

      expect(loggedOut.user, isNull);
      expect(loggedOut.isAuthenticated, isFalse);
      expect(loggedOut.bootstrapComplete, isTrue);
    });

    test('expired session error maps to unauthenticated routing', () {
      const AuthStartupState expired = AuthStartupState(
        phase: AuthStartupPhase.unauthenticated,
        error: 'Your session has expired. Please sign in again.',
        bootstrapComplete: true,
      );

      expect(expired.isUnauthenticated, isTrue);
      expect(expired.isAuthenticated, isFalse);
    });
  });
}
