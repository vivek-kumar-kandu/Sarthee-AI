import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static final SecureStorage instance = SecureStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = "firebase_token";

  Future<void> saveToken(String token) async {
    await instance._storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await instance._storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await instance._storage.delete(key: _tokenKey);
  }

  Future<void> clearAll() async {
    await instance._storage.deleteAll();
  }
}
