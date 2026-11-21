import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/models/user_model.dart';

class AuthSession {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _userKey = 'auth_user_json';

  static const _legacyTokenKey = _tokenKey;
  static const _legacyRefreshTokenKey = _refreshTokenKey;
  static const _legacyUserKey = _userKey;

  final FlutterSecureStorage _secureStorage;

  AuthSession() : _secureStorage = const FlutterSecureStorage();

  /// Returns the stored access token regardless of expiry.
  /// Returns null only if no token is stored.
  Future<String?> getToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) return token;

    // One-time migration from legacy unencrypted storage.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_legacyTokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _secureStorage.write(key: _tokenKey, value: legacy);
      await prefs.remove(_legacyTokenKey);
      return legacy;
    }
    return null;
  }

  /// Returns true if the stored JWT `exp` claim is in the past.
  /// Returns false if no token or malformed (safe default).
  Future<bool> isAccessTokenExpired() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    return _isTokenExpired(token);
  }

  /// Returns true if the JWT `exp` claim is in the past.
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      // base64url → base64 with padding
      String payload = parts[1];
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final decoded = jsonDecode(utf8.decode(base64Decode(payload)));
      if (decoded is Map && decoded['exp'] is num) {
        final exp = DateTime.fromMillisecondsSinceEpoch(
          (decoded['exp'] as num).toInt() * 1000,
        );
        return DateTime.now().isAfter(exp);
      }
      return false; // No exp claim → assume valid
    } catch (_) {
      return true; // Malformed token → treat as expired
    }
  }

  Future<void> setToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _secureStorage.delete(key: _tokenKey);
      return;
    }
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    final token = await _secureStorage.read(key: _refreshTokenKey);
    if (token != null && token.isNotEmpty) return token;

    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_legacyRefreshTokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _secureStorage.write(key: _refreshTokenKey, value: legacy);
      await prefs.remove(_legacyRefreshTokenKey);
      return legacy;
    }
    return null;
  }

  /// True when the user has a stored session (refresh token or cached user).
  Future<bool> hasPersistedSession() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) return true;
    final user = await getUser();
    return user != null;
  }

  /// Raw access token from storage, even if JWT is expired.
  /// Kept for backward compatibility.
  Future<String?> getStoredAccessToken() => getToken();

  Future<void> setRefreshToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _secureStorage.delete(key: _refreshTokenKey);
      return;
    }
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<UserModel?> getUser() async {
    final raw = await _secureStorage.read(key: _userKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return UserModel.fromJson(decoded);
      } catch (_) {
        // Corrupted JSON — treat as missing session.
      }
    }

    // One-time migration from legacy unencrypted storage.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_legacyUserKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _secureStorage.write(key: _userKey, value: legacy);
      await prefs.remove(_legacyUserKey);
      try {
        final decoded = jsonDecode(legacy);
        if (decoded is Map<String, dynamic>) return UserModel.fromJson(decoded);
      } catch (_) {
        // Corrupted JSON — treat as missing session.
      }
    }
    return null;
  }

  Future<void> setUser(UserModel? user) async {
    if (user == null) {
      await _secureStorage.delete(key: _userKey);
      return;
    }
    await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userKey);

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where(
      (key) => key.startsWith('offline_cache_irembo_'),
    )) {
      await prefs.remove(key);
    }
    await prefs.remove(_legacyTokenKey);
    await prefs.remove(_legacyRefreshTokenKey);
    await prefs.remove(_legacyUserKey);
  }
}