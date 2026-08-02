import 'package:flutter/foundation.dart';

/// Progressive phases during application startup.
enum BootstrapPhase {
  uninitialized,
  initializingFirebase,
  loadingSharedPreferences,
  initializingStorage,
  restoringAuthSession,
  loadingThemeAndLocale,
  completed,
  failed;

  bool get isCompleted => this == BootstrapPhase.completed;
  bool get isFailed => this == BootstrapPhase.failed;
  bool get isInProgress => !isCompleted && !isFailed && this != BootstrapPhase.uninitialized;

  String get stepMessage {
    switch (this) {
      case BootstrapPhase.uninitialized:
      case BootstrapPhase.initializingFirebase:
        return 'Connecting securely...';
      case BootstrapPhase.loadingSharedPreferences:
      case BootstrapPhase.initializingStorage:
        return 'Starting cloud services...';
      case BootstrapPhase.restoringAuthSession:
      case BootstrapPhase.loadingThemeAndLocale:
        return 'Preparing your experience...';
      case BootstrapPhase.completed:
        return 'Almost ready...';
      case BootstrapPhase.failed:
        return 'Initialization issue detected.';
    }
  }
}

/// Immutable state representing current application bootstrap progress.
@immutable
class BootstrapState {
  const BootstrapState({
    this.phase = BootstrapPhase.uninitialized,
    this.errorMessage,
  });

  final BootstrapPhase phase;
  final String? errorMessage;

  BootstrapState copyWith({
    BootstrapPhase? phase,
    String? errorMessage,
  }) {
    return BootstrapState(
      phase: phase ?? this.phase,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BootstrapState &&
        other.phase == phase &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(phase, errorMessage);
}
