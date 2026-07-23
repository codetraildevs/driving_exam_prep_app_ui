import 'package:flutter/foundation.dart';

import '../../../../shared/network/api_client.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_endpoints.dart';
import '../../../../shared/device/device_id.dart';
import '../../../../shared/session/auth_session.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _api = ApiClient();
  final AuthSession _session = AuthSession();
  final DeviceId _deviceId = DeviceId();

  Future<UserModel?> signUp({
    required String fullName,
    required String phoneNumber,
    String preferredLanguage = 'en',
  }) async {
    try {
      final deviceId = await _deviceId.getOrCreate();
      if (kDebugMode) {
        debugPrint('[AUTH][SIGNUP] start phone=$phoneNumber device=${deviceId.substring(deviceId.length > 8 ? deviceId.length - 8 : 0)}');
      }

      final registerData = await _api.post(
        ApiEndpoints.authRegister,
        body: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'deviceId': deviceId,
          'preferredLanguage': preferredLanguage,
        },
      );
      if (kDebugMode) {
        debugPrint('[AUTH][SIGNUP] register response type=${registerData.runtimeType}');
      }

      // Newer backend may return token directly on register.
      final registerExtracted = _extractAuthPayload(registerData);
      if (registerExtracted.user != null &&
          registerExtracted.token != null &&
          registerExtracted.token!.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('[AUTH][SIGNUP] register returned token; completing auth without extra login');
        }
        await _session.setToken(registerExtracted.token);
        if (registerExtracted.refreshToken != null) {
          await _session.setRefreshToken(registerExtracted.refreshToken);
        }
        await _session.setUser(registerExtracted.user);
        return registerExtracted.user;
      }

      // Backend register doesn't return a token, so log in immediately.
      final loginData = await _api.post(
        ApiEndpoints.authLogin,
        body: {
          'phoneNumber': phoneNumber,
          'deviceId': deviceId,
        },
      );
      if (kDebugMode) {
        debugPrint('[AUTH][SIGNUP] fallback login response type=${loginData.runtimeType}');
      }

      final extracted = _extractAuthPayload(loginData);
      if (extracted.user == null) return null;
      await _session.setToken(extracted.token);
      if (extracted.refreshToken != null) {
        await _session.setRefreshToken(extracted.refreshToken);
      }
      await _session.setUser(extracted.user);
      return extracted.user;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AUTH][SIGNUP][ERROR] $e');
      }
      rethrow;
    }
  }

  Future<UserModel?> signIn({
    required String phoneNumber,
  }) async {
    try {
      final deviceId = await _deviceId.getOrCreate();
      if (kDebugMode) {
        debugPrint('[AUTH][LOGIN] start phone=$phoneNumber device=${deviceId.substring(deviceId.length > 8 ? deviceId.length - 8 : 0)}');
      }
      final data = await _api.post(
        ApiEndpoints.authLogin,
        body: {
          'phoneNumber': phoneNumber,
          'deviceId': deviceId,
        },
      );
      if (kDebugMode) {
        debugPrint('[AUTH][LOGIN] response type=${data.runtimeType}');
      }

      final extracted = _extractAuthPayload(data);
      if (extracted.user == null) return null;
      await _session.setToken(extracted.token);
      if (extracted.refreshToken != null) {
        await _session.setRefreshToken(extracted.refreshToken);
      }
      await _session.setUser(extracted.user);
      return extracted.user;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AUTH][LOGIN][ERROR] $e');
      }
      rethrow;
    }
  }

  Future<void> rebindDevice({
    required String fullName,
    required String phoneNumber,
  }) async {
    final deviceId = await _deviceId.getOrCreate();
    await _api.post(
      ApiEndpoints.authRebindDevice,
      body: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'deviceId': deviceId,
      },
    );
  }

  Future<void> signOut() async {
    try {
      final refreshToken = await _session.getRefreshToken();
      // Clear local session FIRST so UI updates immediately.
      await _session.clear();

      // Fire-and-forget server logout — endpoint is now public (no JWT needed).
      // The refresh_token alone is sufficient for server-side revocation.
      if (refreshToken != null && refreshToken.isNotEmpty) {
        _api.post(
          ApiEndpoints.authLogout,
          body: {'refresh_token': refreshToken},
        ).catchError((_) {});
      }
    } catch (e) {
      // Ensure session is cleared even if getRefreshToken() throws.
      await _session.clear();
      rethrow;
    }
  }

  Future<void> deleteAccount(String userId) async {
    try {
      final token = await _session.getToken();
      await _api.delete(
        ApiEndpoints.user(userId),
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      );
      await _session.clear();
    } catch (e) {
      // Ensure session is cleared even if the server call fails.
      await _session.clear();
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() => _session.getUser();

  Future<UserModel?> fetchUserProfile(String userId) async {
    try {
      final token = await _session.getToken();
      final data = await _api.get(
        ApiEndpoints.user(userId),
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      );
      if (data is Map<String, dynamic>) {
        final user = UserModel.fromJson(data);
        await _session.setUser(user);
        return user;
      }
      return await _session.getUser();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AUTH][fetchUserProfile][OFFLINE_FALLBACK] $e');
      }
      // On network failure, fall back to the locally cached user session.
      // This allows returning users to reach the dashboard without internet.
      return await _session.getUser();
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String name,
    String? avatarUrl,
  }) async {
    try {
      final token = await _session.getToken();
      final body = <String, dynamic>{
        'fullName': name,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      final data = await _api.put(
        ApiEndpoints.user(userId),
        body: body,
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      );

      if (data is Map<String, dynamic>) {
        await _session.setUser(UserModel.fromJson(data));
        return;
      }

      final current = await _session.getUser();
      if (current != null) {
        await _session.setUser(current.copyWith(name: name, avatarUrl: avatarUrl));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _session.getToken();
    if (token != null && token.isNotEmpty) return true;

    final refreshToken = await _session.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      final refreshed = await ApiHelper().tryRefreshToken();
      if (refreshed) {
        final newToken = await _session.getToken();
        if (newToken != null && newToken.isNotEmpty) return true;
      }
      // Refresh failed — keep user logged in with cached session until logout.
      return await _session.hasPersistedSession();
    }

    return await _session.hasPersistedSession();
  }

  Future<bool> tryRefreshSession() => ApiHelper().tryRefreshToken();

  Future<String?> getCurrentUserId() async => (await _session.getUser())?.id;

  _AuthPayload _extractAuthPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      final userMap = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : data;

      final token =
          (data['token'] ?? data['access_token'] ?? userMap['token'])?.toString();
      final refreshToken =
          (data['refresh_token'] ?? data['refreshToken'])?.toString();
      final id = (userMap['id'] ?? data['userId'])?.toString();
      final phone = (userMap['phoneNumber'] ?? userMap['phone_number'])?.toString();
      final name = (userMap['fullName'] ?? userMap['name'])?.toString();
      final role = (userMap['role'] ?? 'USER').toString();

      if (id != null && (name?.isNotEmpty ?? false) && (phone?.isNotEmpty ?? false)) {
        return _AuthPayload(
          token: token,
          refreshToken: refreshToken,
          user: UserModel(
            id: id,
            name: name!,
            phoneNumber: phone!,
            role: role,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
    return const _AuthPayload();
  }
}

class _AuthPayload {
  final String? token;
  final String? refreshToken;
  final UserModel? user;

  const _AuthPayload({this.token, this.refreshToken, this.user});
}
