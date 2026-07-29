import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/services/auth_bootstrap_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await AuthService.instance.initialize();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        _reportError(
          details.exception,
          details.stack ?? StackTrace.current,
          fatal: true,
        );
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        _reportError(error, stack, fatal: true);
        return true;
      };

      final bootstrap = await _bootstrapApplication();

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(
              bootstrap.sharedPreferences,
            ),
          ],
          child: const SartheeLifecycleApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      _reportError(error, stack, fatal: true);
    },
  );
}

/// Wraps [SartheeApp] with lifecycle hooks for production auth recovery.
class SartheeLifecycleApp extends ConsumerStatefulWidget {
  const SartheeLifecycleApp({super.key});

  @override
  ConsumerState<SartheeLifecycleApp> createState() =>
      _SartheeLifecycleAppState();
}

class _SartheeLifecycleAppState extends ConsumerState<SartheeLifecycleApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    AuthBootstrapService.instance.resetSessionValidation();

    final startup = ref.read(authStartupProvider);
    if (startup.isAuthenticated && startup.bootstrapComplete) {
      unawaited(ref.read(authControllerProvider.notifier).retryBootstrap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SartheeApp();
  }
}

Future<AppBootstrapData> _bootstrapApplication() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return AppBootstrapData(sharedPreferences: sharedPreferences);
}

@immutable
final class AppBootstrapData {
  const AppBootstrapData({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;
}

void _reportError(Object error, StackTrace stack, {required bool fatal}) {
  FlutterError.dumpErrorToConsole(
    FlutterErrorDetails(
      exception: error,
      stack: stack,
      library: 'Sarthee AI',
      context: ErrorDescription(
        fatal ? 'Fatal application error' : 'Application error',
      ),
    ),
  );
}
