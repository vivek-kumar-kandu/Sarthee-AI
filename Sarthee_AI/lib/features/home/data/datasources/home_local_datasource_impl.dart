import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/home_content_model.dart';
import 'home_local_datasource.dart';

/// ============================================================================
/// SARTHEE AI — HOME LOCAL DATA SOURCE IMPLEMENTATION
/// ============================================================================
///
/// SharedPreferences-backed implementation of [HomeLocalDataSource].
///
/// Architecture:
///
/// HomeRepositoryImpl
///        ↓
/// HomeLocalDataSource
///        ↓
/// HomeLocalDataSourceImpl
///        ↓
/// SharedPreferences
///
/// Persisted data:
///
/// • Home content JSON
/// • Cache timestamp
/// • Cache schema version
///
/// The schema version protects the application from attempting to deserialize
/// incompatible cache data after future model migrations.
final class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  HomeLocalDataSourceImpl({required this.preferences});

  // ===========================================================================
  // DEPENDENCIES
  // ===========================================================================

  final SharedPreferences preferences;

  // ===========================================================================
  // STORAGE KEYS
  // ===========================================================================

  static const String _contentKey = 'sarthee.home.cache.content';

  static const String _timestampKey = 'sarthee.home.cache.timestamp';

  static const String _schemaVersionKey = 'sarthee.home.cache.schema_version';

  // ===========================================================================
  // SCHEMA
  // ===========================================================================

  static const int _currentSchemaVersion = 1;

  // ===========================================================================
  // READ CACHE
  // ===========================================================================

  @override
  Future<HomeContentModel?> getCachedHomeContent() async {
    try {
      final int? storedSchemaVersion = preferences.getInt(_schemaVersionKey);

      if (storedSchemaVersion == null) {
        if (preferences.containsKey(_contentKey)) {
          await _clearInternal();
        }

        return null;
      }

      if (storedSchemaVersion != _currentSchemaVersion) {
        await _clearInternal();

        return null;
      }

      final String? encodedContent = preferences.getString(_contentKey);

      if (encodedContent == null || encodedContent.trim().isEmpty) {
        return null;
      }

      final Object? decoded = jsonDecode(encodedContent);

      if (decoded is! Map) {
        await _clearInternal();

        return null;
      }

      final Map<String, dynamic> json = decoded.map<String, dynamic>((
        Object? key,
        Object? value,
      ) {
        return MapEntry<String, dynamic>(key.toString(), value);
      });

      return HomeContentModel.fromJson(json);
    } on FormatException {
      await _clearInternal();

      return null;
    } on TypeError {
      await _clearInternal();

      return null;
    } catch (_) {
      // Cache failure should never prevent the Home feature from attempting
      // to obtain fresh content from the remote source.
      return null;
    }
  }

  // ===========================================================================
  // WRITE CACHE
  // ===========================================================================

  @override
  Future<void> cacheHomeContent(HomeContentModel content) async {
    final Map<String, dynamic> json = content.toJson();

    final String encodedContent = jsonEncode(json);

    final String timestamp = DateTime.now().toUtc().toIso8601String();

    // SharedPreferences has no transaction API.
    //
    // Schema is therefore written last and acts as the final cache-validity
    // marker.

    final bool contentSaved = await preferences.setString(
      _contentKey,
      encodedContent,
    );

    if (!contentSaved) {
      throw const HomeCacheWriteException(
        'Unable to persist Home cache content.',
      );
    }

    final bool timestampSaved = await preferences.setString(
      _timestampKey,
      timestamp,
    );

    if (!timestampSaved) {
      await _clearInternal();

      throw const HomeCacheWriteException(
        'Unable to persist Home cache timestamp.',
      );
    }

    final bool schemaSaved = await preferences.setInt(
      _schemaVersionKey,
      _currentSchemaVersion,
    );

    if (!schemaSaved) {
      await _clearInternal();

      throw const HomeCacheWriteException(
        'Unable to persist Home cache schema version.',
      );
    }
  }

  // ===========================================================================
  // CLEAR CACHE
  // ===========================================================================

  @override
  Future<void> clearHomeContent() async {
    await _clearInternal();
  }

  Future<void> _clearInternal() async {
    await Future.wait<bool>(<Future<bool>>[
      preferences.remove(_contentKey),
      preferences.remove(_timestampKey),
      preferences.remove(_schemaVersionKey),
    ]);
  }

  // ===========================================================================
  // CACHE EXISTENCE
  // ===========================================================================

  @override
  Future<bool> hasCachedHomeContent() async {
    try {
      if (!preferences.containsKey(_contentKey)) {
        return false;
      }

      final String? content = preferences.getString(_contentKey);

      if (content == null || content.trim().isEmpty) {
        return false;
      }

      final int? schema = preferences.getInt(_schemaVersionKey);

      if (schema != _currentSchemaVersion) {
        return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  // ===========================================================================
  // CACHE TIMESTAMP
  // ===========================================================================

  @override
  Future<DateTime?> getCacheTimestamp() async {
    try {
      final String? rawTimestamp = preferences.getString(_timestampKey);

      if (rawTimestamp == null || rawTimestamp.trim().isEmpty) {
        return null;
      }

      final DateTime? parsed = DateTime.tryParse(rawTimestamp);

      if (parsed == null) {
        return null;
      }

      return parsed.toUtc();
    } catch (_) {
      return null;
    }
  }

  // ===========================================================================
  // DIAGNOSTICS
  // ===========================================================================

  int? get storedSchemaVersion {
    try {
      return preferences.getInt(_schemaVersionKey);
    } catch (_) {
      return null;
    }
  }

  static int get currentSchemaVersion => _currentSchemaVersion;
}

/// ============================================================================
/// HOME CACHE WRITE EXCEPTION
/// ============================================================================

final class HomeCacheWriteException implements Exception {
  const HomeCacheWriteException(this.message);

  final String message;

  @override
  String toString() {
    return 'HomeCacheWriteException: $message';
  }
}
