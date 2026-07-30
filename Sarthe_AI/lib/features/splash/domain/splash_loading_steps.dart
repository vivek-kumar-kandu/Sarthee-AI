import 'package:sarthee_ai/features/auth/state/auth_startup_state.dart';

/// Centralized domain constants for splash loading steps.
///
/// Maps real [AuthStartupPhase] to human-readable loading messages.
abstract class SplashLoadingSteps {
  static const String connecting = "Connecting securely...";
  static const String loadingPreferences = "Loading preferences...";
  static const String restoringSession = "Restoring your session...";
  static const String preparingAIServices = "Preparing AI services...";
  static const String almostReady = "Almost ready...";

  /// Resolves user-facing step text based on real auth startup execution phase.
  static String getStepMessage(AuthStartupPhase phase, {String? customError}) {
    return switch (phase) {
      AuthStartupPhase.initializing => connecting,
      AuthStartupPhase.checkingFirebaseSession => loadingPreferences,
      AuthStartupPhase.restoringToken => restoringSession,
      AuthStartupPhase.validatingBackendSession => preparingAIServices,
      AuthStartupPhase.checkingProfileCompletion ||
      AuthStartupPhase.authenticated ||
      AuthStartupPhase.unauthenticated => almostReady,
      AuthStartupPhase.error => customError ?? "Connection issue. Retrying...",
    };
  }
}
