import 'package:flutter/foundation.dart';

/// Represents the lifecycle phase of the Sarthee AI splash/bootstrap process.
///
/// The splash feature is responsible only for determining whether the
/// application is ready to continue.
///
/// Actual navigation decisions remain the responsibility of GoRouter and
/// RouteGuards.
enum SplashStatus {
  /// Splash/bootstrap process has not started yet.
  initial,

  /// Required application services are being initialized.
  initializing,

  /// Application initialization completed successfully.
  ready,

  /// Initialization failed.
  failure;

  bool get isInitial => this == SplashStatus.initial;

  bool get isInitializing => this == SplashStatus.initializing;

  bool get isReady => this == SplashStatus.ready;

  bool get isFailure => this == SplashStatus.failure;

  bool get isBusy => isInitializing;

  bool get isTerminal => isReady || isFailure;
}

/// Immutable state used by the splash/bootstrap feature.
///
/// Responsibilities:
///
/// • initialization lifecycle
/// • startup progress
/// • human-readable startup message
/// • recoverable startup errors
/// • retry tracking
///
/// This state intentionally contains no navigation logic.
///
/// Navigation belongs to:
///
/// SplashController
///       ↓
/// RouteGuard state
///       ↓
/// GoRouter redirect
@immutable
class SplashState {
  const SplashState({
    this.status = SplashStatus.initial,
    this.progress = 0.0,
    this.message,
    this.errorMessage,
    this.retryCount = 0,
  }) : assert(
         progress >= 0.0 && progress <= 1.0,
         'Splash progress must be between 0.0 and 1.0.',
       ),
       assert(retryCount >= 0, 'Splash retryCount cannot be negative.');

  /// Initial/default splash state.
  const SplashState.initial()
    : status = SplashStatus.initial,
      progress = 0.0,
      message = null,
      errorMessage = null,
      retryCount = 0;

  /// Current splash lifecycle status.
  final SplashStatus status;

  /// Initialization progress.
  ///
  /// Range:
  ///
  /// 0.0 → not started
  /// 1.0 → complete
  final double progress;

  /// Optional startup message.
  ///
  /// Examples:
  ///
  /// "Preparing Sarthee AI"
  /// "Loading preferences"
  /// "Checking session"
  final String? message;

  /// Recoverable error description.
  ///
  /// Keep technical exceptions/logging outside presentation state.
  final String? errorMessage;

  /// Number of initialization retries performed.
  final int retryCount;

  // ===========================================================================
  // DERIVED STATE
  // ===========================================================================

  bool get isInitial => status.isInitial;

  bool get isInitializing => status.isInitializing;

  bool get isReady => status.isReady;

  bool get hasError => status.isFailure;

  bool get isBusy => status.isBusy;

  bool get canRetry => hasError;

  bool get hasMessage => message?.trim().isNotEmpty ?? false;

  bool get hasErrorMessage => errorMessage?.trim().isNotEmpty ?? false;

  /// Sanitized progress value for defensive UI usage.
  double get safeProgress => progress.clamp(0.0, 1.0);

  /// Progress represented as a whole percentage.
  int get progressPercentage => (safeProgress * 100).round();

  // ===========================================================================
  // STATE FACTORIES
  // ===========================================================================

  SplashState start({String? message}) {
    return SplashState(
      status: SplashStatus.initializing,
      progress: 0.0,
      message: message,
      retryCount: retryCount,
    );
  }

  SplashState updateProgress(double progress, {String? message}) {
    return SplashState(
      status: SplashStatus.initializing,
      progress: progress.clamp(0.0, 1.0),
      message: message ?? this.message,
      retryCount: retryCount,
    );
  }

  SplashState complete({String? message}) {
    return SplashState(
      status: SplashStatus.ready,
      progress: 1.0,
      message: message,
      retryCount: retryCount,
    );
  }

  SplashState fail({required String errorMessage}) {
    return SplashState(
      status: SplashStatus.failure,
      progress: progress,
      message: message,
      errorMessage: errorMessage,
      retryCount: retryCount,
    );
  }

  SplashState prepareRetry({String? message}) {
    return SplashState(
      status: SplashStatus.initial,
      progress: 0.0,
      message: message,
      retryCount: retryCount + 1,
    );
  }

  // ===========================================================================
  // COPY
  // ===========================================================================

  SplashState copyWith({
    SplashStatus? status,
    double? progress,
    String? message,
    String? errorMessage,
    int? retryCount,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return SplashState(
      status: status ?? this.status,
      progress: (progress ?? this.progress).clamp(0.0, 1.0),
      message: clearMessage ? null : message ?? this.message,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  // ===========================================================================
  // VALUE SEMANTICS
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is SplashState &&
        other.status == status &&
        other.progress == progress &&
        other.message == message &&
        other.errorMessage == errorMessage &&
        other.retryCount == retryCount;
  }

  @override
  int get hashCode =>
      Object.hash(status, progress, message, errorMessage, retryCount);

  @override
  String toString() {
    return 'SplashState('
        'status: $status, '
        'progress: $progress, '
        'message: $message, '
        'hasError: $hasError, '
        'retryCount: $retryCount'
        ')';
  }
}
