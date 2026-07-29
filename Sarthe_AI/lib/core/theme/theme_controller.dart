import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ===============================================================
/// SARTHEE AI — THEME CONTROLLER
/// ===============================================================
///
/// Production-ready theme preference management.
///
/// Features:
/// - System / Light / Dark theme
/// - Persistent theme preference
/// - Safe async lifecycle handling
/// - Optimistic UI updates
/// - Storage abstraction
/// - Graceful persistence failure handling
/// - Type-safe serialization
/// - Selector providers
/// - Future AMOLED/custom-theme ready architecture
/// ===============================================================

// =================================================================
// THEME PREFERENCE
// =================================================================

enum AppThemePreference { system, light, dark }

// =================================================================
// THEME PREFERENCE EXTENSIONS
// =================================================================

extension AppThemePreferenceX on AppThemePreference {
  ThemeMode get themeMode {
    return switch (this) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };
  }

  String get storageValue {
    return switch (this) {
      AppThemePreference.system => 'system',
      AppThemePreference.light => 'light',
      AppThemePreference.dark => 'dark',
    };
  }

  String get label {
    return switch (this) {
      AppThemePreference.system => 'System default',
      AppThemePreference.light => 'Light',
      AppThemePreference.dark => 'Dark',
    };
  }

  IconData get icon {
    return switch (this) {
      AppThemePreference.system => Icons.brightness_auto_outlined,
      AppThemePreference.light => Icons.light_mode_outlined,
      AppThemePreference.dark => Icons.dark_mode_outlined,
    };
  }
}

// =================================================================
// SAFE PARSER
// =================================================================

AppThemePreference appThemePreferenceFromStorage(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'light' => AppThemePreference.light,
    'dark' => AppThemePreference.dark,
    'system' => AppThemePreference.system,
    _ => AppThemePreference.system,
  };
}

// =================================================================
// STORAGE KEYS
// =================================================================

abstract final class ThemeStorageKeys {
  static const String themePreference = 'appearance.theme.preference';

  ThemeStorageKeys._();
}

// =================================================================
// STORAGE CONTRACT
// =================================================================

abstract interface class ThemePreferenceStorage {
  Future<AppThemePreference> read();

  Future<void> write(AppThemePreference preference);

  Future<void> clear();
}

// =================================================================
// SHARED PREFERENCES IMPLEMENTATION
// =================================================================

final class SharedPreferencesThemeStorage implements ThemePreferenceStorage {
  SharedPreferencesThemeStorage(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<AppThemePreference> read() async {
    try {
      final value = _preferences.getString(ThemeStorageKeys.themePreference);

      return appThemePreferenceFromStorage(value);
    } catch (_) {
      return AppThemePreference.system;
    }
  }

  @override
  Future<void> write(AppThemePreference preference) async {
    final success = await _preferences.setString(
      ThemeStorageKeys.themePreference,
      preference.storageValue,
    );

    if (!success) {
      throw StateError('Unable to persist theme preference.');
    }
  }

  @override
  Future<void> clear() async {
    final success = await _preferences.remove(ThemeStorageKeys.themePreference);

    if (!success &&
        _preferences.containsKey(ThemeStorageKeys.themePreference)) {
      throw StateError('Unable to clear theme preference.');
    }
  }
}

// =================================================================
// SHARED PREFERENCES PROVIDER
// =================================================================

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'sharedPreferencesProvider was not initialized. '
    'Override it inside main.dart before starting SartheeApp.',
  );
});

// =================================================================
// STORAGE PROVIDER
// =================================================================

final themePreferenceStorageProvider = Provider<ThemePreferenceStorage>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);

  return SharedPreferencesThemeStorage(preferences);
});

// =================================================================
// THEME STATE
// =================================================================

@immutable
class ThemeState {
  const ThemeState({
    this.preference = AppThemePreference.system,
    this.isInitialized = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final AppThemePreference preference;

  final bool isInitialized;

  final bool isSaving;

  final String? errorMessage;

  // -----------------------------------------------------------------
  // DERIVED STATE
  // -----------------------------------------------------------------

  ThemeMode get themeMode => preference.themeMode;

  bool get isSystem => preference == AppThemePreference.system;

  bool get isLight => preference == AppThemePreference.light;

  bool get isDark => preference == AppThemePreference.dark;

  bool get hasError => errorMessage != null;

  // -----------------------------------------------------------------
  // COPY
  // -----------------------------------------------------------------

  ThemeState copyWith({
    AppThemePreference? preference,
    bool? isInitialized,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ThemeState(
      preference: preference ?? this.preference,

      isInitialized: isInitialized ?? this.isInitialized,

      isSaving: isSaving ?? this.isSaving,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  // -----------------------------------------------------------------
  // EQUALITY
  // -----------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ThemeState &&
            runtimeType == other.runtimeType &&
            preference == other.preference &&
            isInitialized == other.isInitialized &&
            isSaving == other.isSaving &&
            errorMessage == other.errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(preference, isInitialized, isSaving, errorMessage);
  }

  @override
  String toString() {
    return 'ThemeState('
        'preference: $preference, '
        'isInitialized: $isInitialized, '
        'isSaving: $isSaving, '
        'errorMessage: $errorMessage'
        ')';
  }
}

// =================================================================
// THEME CONTROLLER
// =================================================================

class ThemeController extends Notifier<ThemeState> {
  /// Riverpod 2.x NotifierRef doesn't expose `mounted`.
  ///
  /// Therefore we maintain controller lifecycle explicitly.
  bool _disposed = false;

  // -----------------------------------------------------------------
  // STORAGE
  // -----------------------------------------------------------------

  ThemePreferenceStorage get _storage {
    return ref.read(themePreferenceStorageProvider);
  }

  // -----------------------------------------------------------------
  // LIFECYCLE
  // -----------------------------------------------------------------

  bool get _isActive => !_disposed;

  @override
  ThemeState build() {
    _disposed = false;

    ref.onDispose(() {
      _disposed = true;
    });

    /// Restore saved appearance without blocking app startup.
    unawaited(_restoreTheme());

    return const ThemeState();
  }

  // =================================================================
  // INITIALIZATION
  // =================================================================

  Future<void> _restoreTheme() async {
    try {
      final preference = await _storage.read();

      if (!_isActive) {
        return;
      }

      state = ThemeState(preference: preference, isInitialized: true);
    } catch (_) {
      if (!_isActive) {
        return;
      }

      state = const ThemeState(
        preference: AppThemePreference.system,
        isInitialized: true,
        errorMessage: 'Unable to restore appearance preference.',
      );
    }
  }

  // =================================================================
  // SET PREFERENCE
  // =================================================================

  Future<void> setPreference(AppThemePreference preference) async {
    if (!_isActive) {
      return;
    }

    if (state.preference == preference &&
        state.isInitialized &&
        !state.hasError) {
      return;
    }

    final previousPreference = state.preference;

    /// Optimistic UI update.
    state = state.copyWith(
      preference: preference,
      isInitialized: true,
      isSaving: true,
      clearError: true,
    );

    try {
      await _storage.write(preference);

      if (!_isActive) {
        return;
      }

      state = state.copyWith(isSaving: false, clearError: true);
    } catch (_) {
      if (!_isActive) {
        return;
      }

      /// Persistence failed.
      ///
      /// Restore previous theme so UI and storage
      /// remain consistent.
      state = state.copyWith(
        preference: previousPreference,
        isSaving: false,
        errorMessage: 'Unable to save appearance preference.',
      );
    }
  }

  // =================================================================
  // CONVENIENCE METHODS
  // =================================================================

  Future<void> useSystemTheme() {
    return setPreference(AppThemePreference.system);
  }

  Future<void> useLightTheme() {
    return setPreference(AppThemePreference.light);
  }

  Future<void> useDarkTheme() {
    return setPreference(AppThemePreference.dark);
  }

  // =================================================================
  // TOGGLE
  // =================================================================

  Future<void> toggleTheme({required Brightness platformBrightness}) {
    switch (state.preference) {
      case AppThemePreference.light:
        return useDarkTheme();

      case AppThemePreference.dark:
        return useLightTheme();

      case AppThemePreference.system:
        return platformBrightness == Brightness.dark
            ? useLightTheme()
            : useDarkTheme();
    }
  }

  // =================================================================
  // RESET
  // =================================================================

  Future<void> reset() async {
    if (!_isActive) {
      return;
    }

    final previousPreference = state.preference;

    state = state.copyWith(
      preference: AppThemePreference.system,
      isInitialized: true,
      isSaving: true,
      clearError: true,
    );

    try {
      await _storage.clear();

      if (!_isActive) {
        return;
      }

      state = state.copyWith(
        preference: AppThemePreference.system,
        isInitialized: true,
        isSaving: false,
        clearError: true,
      );
    } catch (_) {
      if (!_isActive) {
        return;
      }

      state = state.copyWith(
        preference: previousPreference,
        isSaving: false,
        errorMessage: 'Unable to reset appearance preference.',
      );
    }
  }

  // =================================================================
  // ERROR MANAGEMENT
  // =================================================================

  void clearError() {
    if (!_isActive || !state.hasError) {
      return;
    }

    state = state.copyWith(clearError: true);
  }
}

// =================================================================
// MAIN PROVIDER
// =================================================================

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);

// =================================================================
// SELECTOR PROVIDERS
// =================================================================

/// MaterialApp should normally watch this provider.
///
/// This avoids rebuilding MaterialApp when only unrelated
/// ThemeState properties change.
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeControllerProvider.select((state) => state.themeMode));
});

/// Current Sarthee AI appearance preference.
final themePreferenceProvider = Provider<AppThemePreference>((ref) {
  return ref.watch(themeControllerProvider.select((state) => state.preference));
});

/// Whether saved appearance has been restored.
final themeInitializedProvider = Provider<bool>((ref) {
  return ref.watch(
    themeControllerProvider.select((state) => state.isInitialized),
  );
});

/// Whether theme preference is being saved.
final themeSavingProvider = Provider<bool>((ref) {
  return ref.watch(themeControllerProvider.select((state) => state.isSaving));
});

/// Theme-related error exposed separately for UI.
///
/// Settings page can listen to this provider and show
/// Snackbar/Toast without rebuilding unrelated widgets.
final themeErrorProvider = Provider<String?>((ref) {
  return ref.watch(
    themeControllerProvider.select((state) => state.errorMessage),
  );
});
