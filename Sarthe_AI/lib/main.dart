import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap/bootstrap_result.dart';
import 'app/bootstrap/bootstrap_service.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  runZonedGuarded<void>(
    () async {
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

      // Delegate startup orchestration to App Bootstrap Layer
      final BootstrapResult bootstrap =
          await BootstrapService.instance.performBootstrap();

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

/// Wraps [SartheeApp] with lifecycle hooks for application state monitoring.
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
    debugPrint("========== APP_RESUMED ==========");
  }

  @override
  Widget build(BuildContext context) {
    return const SartheeApp();
  }
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
