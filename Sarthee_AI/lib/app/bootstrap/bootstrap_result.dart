import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Final result returned after application bootstrap completes.
@immutable
class BootstrapResult {
  const BootstrapResult({
    required this.sharedPreferences,
    required this.isSuccess,
    this.errorMessage,
  });

  final SharedPreferences sharedPreferences;
  final bool isSuccess;
  final String? errorMessage;
}
