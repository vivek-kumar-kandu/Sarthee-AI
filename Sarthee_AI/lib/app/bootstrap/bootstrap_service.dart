import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/auth_service.dart';
import '../../firebase_options.dart';
import 'bootstrap_result.dart';
import 'bootstrap_state.dart';

/// Dedicated service responsible for orchestrating application startup.
class BootstrapService {
  BootstrapService._();
  static final BootstrapService instance = BootstrapService._();

  Future<BootstrapResult> performBootstrap({
    void Function(BootstrapState state)? onStateChanged,
  }) async {
    try {
      // 1. Flutter Framework Bindings
      WidgetsFlutterBinding.ensureInitialized();

      // 2. Firebase Initialization
      onStateChanged?.call(
        const BootstrapState(phase: BootstrapPhase.initializingFirebase),
      );
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 3. SharedPreferences Initialization
      onStateChanged?.call(
        const BootstrapState(phase: BootstrapPhase.loadingSharedPreferences),
      );
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      // 4. Secure Storage & Authentication Session Restoration
      onStateChanged?.call(
        const BootstrapState(phase: BootstrapPhase.restoringAuthSession),
      );
      await AuthService.instance.initialize();

      // 5. Theme & Locale Warmup
      onStateChanged?.call(
        const BootstrapState(phase: BootstrapPhase.loadingThemeAndLocale),
      );

      // 6. Bootstrap Complete
      onStateChanged?.call(
        const BootstrapState(phase: BootstrapPhase.completed),
      );

      return BootstrapResult(
        sharedPreferences: sharedPreferences,
        isSuccess: true,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('BOOTSTRAP_ERROR: $error\n$stackTrace');
      }
      onStateChanged?.call(
        BootstrapState(
          phase: BootstrapPhase.failed,
          errorMessage: error.toString(),
        ),
      );
      rethrow;
    }
  }
}
