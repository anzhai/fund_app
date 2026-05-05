import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Helper
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static FlutterSecureStorage get instance => _storage;

  // Token management
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<String?> getAccessToken() async {
    return _storage.read(key: 'access_token');
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: 'refresh_token');
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // User data
  static Future<void> saveUserData(String userData) async {
    await _storage.write(key: 'user_data', value: userData);
  }

  static Future<String?> getUserData() async {
    return _storage.read(key: 'user_data');
  }

  static Future<void> clearUserData() async {
    await _storage.delete(key: 'user_data');
  }

  // Clear all
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
