import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'api_endpoints.dart';
import 'token_refresh_mutex.dart';
import '../session/auth_session.dart';

/// Centralized API helper with debug logging for all HTTP calls
/// and auto-refresh token interceptor.
class ApiHelper {
  static final ApiHelper _instance = ApiHelper._();
  factory ApiHelper() => _instance;
  ApiHelper._();

  late final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  /// Performs a GET request with auth token and debug logging.
  Future<ApiResponse> get(String path, {Map<String, String>? queryParams}) async {
    _logRequest('GET', path, queryParams: queryParams);
    try {
      await _ensureAccessToken();
      final token = await AuthSession().getToken();
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
        options: Options(headers: _authHeader(token)),
      );
      return _processResponse('GET', path, response);
    } on DioException catch (e) {
      final handled = await _tryHandle401('GET', path, e);
      if (handled != null) return handled;
      return _networkError('GET', path, _dioErrorMessage(e), e.toString());
    } catch (e) {
      return _networkError('GET', path, 'An unexpected error occurred', e.toString());
    }
  }

  /// Performs a POST request with auth token and debug logging.
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    _logRequest('POST', path, body: body);
    try {
      await _ensureAccessToken();
      final token = await AuthSession().getToken();
      final response = await _dio.post(
        path,
        data: body != null ? json.encode(body) : null,
        options: Options(headers: _authHeader(token)),
      );
      return _processResponse('POST', path, response);
    } on DioException catch (e) {
      final handled = await _tryHandle401('POST', path, e);
      if (handled != null) return handled;
      return _networkError('POST', path, _dioErrorMessage(e), e.toString());
    } catch (e) {
      return _networkError('POST', path, 'An unexpected error occurred', e.toString());
    }
  }

  /// Performs a PUT request with auth token and debug logging.
  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) async {
    _logRequest('PUT', path, body: body);
    try {
      await _ensureAccessToken();
      final token = await AuthSession().getToken();
      final response = await _dio.put(
        path,
        data: body != null ? json.encode(body) : null,
        options: Options(headers: _authHeader(token)),
      );
      return _processResponse('PUT', path, response);
    } on DioException catch (e) {
      final handled = await _tryHandle401('PUT', path, e);
      if (handled != null) return handled;
      return _networkError('PUT', path, _dioErrorMessage(e), e.toString());
    } catch (e) {
      return _networkError('PUT', path, 'An unexpected error occurred', e.toString());
    }
  }

  /// Performs a PATCH request with auth token and debug logging.
  Future<ApiResponse> patch(String path, {Map<String, dynamic>? body}) async {
    _logRequest('PATCH', path, body: body);
    try {
      await _ensureAccessToken();
      final token = await AuthSession().getToken();
      final response = await _dio.patch(
        path,
        data: body != null ? json.encode(body) : null,
        options: Options(headers: _authHeader(token)),
      );
      return _processResponse('PATCH', path, response);
    } on DioException catch (e) {
      final handled = await _tryHandle401('PATCH', path, e);
      if (handled != null) return handled;
      return _networkError('PATCH', path, _dioErrorMessage(e), e.toString());
    } catch (e) {
      return _networkError('PATCH', path, 'An unexpected error occurred', e.toString());
    }
  }

  /// Performs a DELETE request with auth token and debug logging.
  Future<ApiResponse> delete(String path) async {
    _logRequest('DELETE', path);
    try {
      await _ensureAccessToken();
      final token = await AuthSession().getToken();
      final response = await _dio.delete(
        path,
        options: Options(headers: _authHeader(token)),
      );
      return _processResponse('DELETE', path, response);
    } on DioException catch (e) {
      final handled = await _tryHandle401('DELETE', path, e);
      if (handled != null) return handled;
      return _networkError('DELETE', path, _dioErrorMessage(e), e.toString());
    } catch (e) {
      return _networkError('DELETE', path, 'An unexpected error occurred', e.toString());
    }
  }

  /// Ensures we have a valid (or refreshed) access token before each request.
  /// If the access token is expired and a refresh token exists, attempts a refresh.
  Future<void> _ensureAccessToken() async {
    final session = AuthSession();
    // getToken() now returns the stored token even if expired.
    // Check expiry explicitly to decide whether a refresh is needed.
    final expired = await session.isAccessTokenExpired();
    if (!expired) return; // Token is still valid (or no token stored)

    final refreshToken = await session.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return; // Can't refresh

    // Try to refresh — keep local session if refresh fails (offline / transient).
    await _doRefresh(refreshToken);
  }

  /// Token refresh guarded by the app-wide [TokenRefreshMutex].
  Future<bool> _doRefresh(String refreshToken) async {
    return TokenRefreshMutex.runRefresh(() async {
      if (kDebugMode) {
        debugPrint('🔄 Attempting token refresh...');
      }
      try {
        final response = await _dio.post(
          ApiEndpoints.authRefresh,
          options: Options(
            headers: {'Authorization': 'Bearer $refreshToken'},
          ),
        );
        if (response.statusCode == 200 && response.data is Map) {
          final outer = response.data as Map;
          final data = outer['data'] is Map ? outer['data'] as Map : outer;
          final newToken = data['token']?.toString();
          final newRefreshToken = data['refresh_token']?.toString();
          if (newToken != null && newToken.isNotEmpty) {
            final session = AuthSession();
            await session.setToken(newToken);
            if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
              await session.setRefreshToken(newRefreshToken);
            }
            if (kDebugMode) {
              debugPrint('✅ Token refreshed successfully');
            }
            return true;
          }
        }
        return false;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Token refresh failed: $e');
        }
        return false;
      }
    });
  }

  /// When a 401 error occurs, attempt to refresh the token and retry the request.
  /// Returns an ApiResponse if the retry succeeded, or null if the error should
  /// be handled by the normal error path.
  Future<ApiResponse?> _tryHandle401(
    String method,
    String path,
    DioException e,
  ) async {
    if (e.type != DioExceptionType.badResponse ||
        e.response?.statusCode != 401) {
      return null;
    }

    // Don't retry if we were already calling the refresh endpoint
    if (path == ApiEndpoints.authRefresh) {
      await AuthSession().clear();
      return _networkError(method, path,
          'Session expired. Please log in again.', e.toString());
    }

    final session = AuthSession();
    final refreshToken = await session.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final refreshed = await _doRefresh(refreshToken);
    if (!refreshed) {
      return _networkError(method, path,
          'Session expired. Please log in again.', e.toString());
    }

    // Retry the original request with the new token
    try {
      final newToken = await session.getToken();
      late final Response retryResponse;
      switch (method) {
        case 'GET':
          retryResponse = await _dio.get(
            path,
            options: Options(headers: _authHeader(newToken)),
          );
          break;
        case 'POST':
          retryResponse = await _dio.post(
            path,
            data: e.requestOptions.data,
            options: Options(headers: _authHeader(newToken)),
          );
          break;
        case 'PUT':
          retryResponse = await _dio.put(
            path,
            data: e.requestOptions.data,
            options: Options(headers: _authHeader(newToken)),
          );
          break;
        case 'PATCH':
          retryResponse = await _dio.patch(
            path,
            data: e.requestOptions.data,
            options: Options(headers: _authHeader(newToken)),
          );
          break;
        case 'DELETE':
          retryResponse = await _dio.delete(
            path,
            options: Options(headers: _authHeader(newToken)),
          );
          break;
        default:
          return null;
      }
      return _processResponse(method, path, retryResponse);
    } catch (retryError) {
      return _networkError(method, path,
          'Session expired. Please log in again.', retryError.toString());
    }
  }

  /// Public: attempt a token refresh. Called by AuthBloc or checkAuthStatus.
  Future<bool> tryRefreshToken() async {
    final refreshToken = await AuthSession().getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    return _doRefresh(refreshToken);
  }

  Map<String, String> _authHeader(String? token) => {
        if (token != null) 'Authorization': 'Bearer $token',
      };

  String _dioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please check your connection.';
      case DioExceptionType.connectionError:
        return 'NETWORK_ERROR';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          // Don't clear here — the 401 handler decided not to refresh
          // or the error fell through. The session may already be cleared.
          return 'Session expired. Please log in again.';
        }
        if (statusCode == 403) return 'Insufficient permissions for this operation.';
        if (e.response?.data is Map) {
          final data = e.response!.data as Map;
          final msg = data['message'] ?? data['error'];
          if (msg != null && msg.toString().isNotEmpty) return msg.toString();
        }
        return 'HTTP $statusCode';
      default:
        return 'An unexpected error occurred';
    }
  }

  ApiResponse _processResponse(String method, String path, Response response) {
    _logResponse(method, path, response);
    final data = response.data;
    final statusCode = response.statusCode ?? 0;

    final isSuccess = statusCode >= 200 && statusCode < 300;
    String? errorMessage;
    if (!isSuccess) {
      if (statusCode == 401) {
        // Already attempted refresh in _tryHandle401 — session may be cleared
        errorMessage = 'Session expired. Please log in again.';
      } else if (statusCode == 403) {
        errorMessage = 'Insufficient permissions for this operation.';
      } else if (data is Map) {
        errorMessage = (data['message'] ?? data['error'] ?? '').toString();
      }
      if (errorMessage == null || errorMessage.isEmpty) {
        errorMessage = 'HTTP $statusCode';
      }
    }

    // Unwrap common API envelope: {success: true, data: <payload>}
    final unwrappedData = (isSuccess && data is Map && data.containsKey('data'))
        ? data['data']
        : data;

    return ApiResponse(
      statusCode: statusCode,
      data: unwrappedData,
      isSuccess: isSuccess,
      errorMessage: errorMessage,
      debugInfo: '$method $path → $statusCode',
    );
  }

  ApiResponse _networkError(String method, String path, String errorMessage, String rawError) {
    if (kDebugMode) debugPrint('❌ API ERROR [$method $path]: $rawError');
    return ApiResponse(
      statusCode: 0,
      data: null,
      isSuccess: false,
      errorMessage: errorMessage,
      debugInfo: '$method $path → NETWORK ERROR: $rawError',
    );
  }

  void _logRequest(String method, String path, {Map<String, dynamic>? body, Map<String, String>? queryParams}) {
    if (!kDebugMode) return;
    final queryStr = queryParams != null ? '?$queryParams' : '';
    debugPrint('🌐 API REQUEST: $method $path$queryStr');
    if (body != null) {
      debugPrint('   Body: ${json.encode(body)}');
    }
  }

  void _logResponse(String method, String path, Response response) {
    if (!kDebugMode) return;
    final status = response.statusCode;
    final icon = (status != null && status >= 200 && status < 300) ? '✅' : '⚠️';
    debugPrint('$icon API RESPONSE: $method $path → $status');
    final bodyStr = response.data?.toString() ?? '';
    final bodySnippet = bodyStr.length > 500
        ? '${bodyStr.substring(0, 500)}...'
        : bodyStr;
    debugPrint('   Body: $bodySnippet');
  }
}

/// Structured response from [ApiHelper].
class ApiResponse {
  final int statusCode;
  final dynamic data;
  final bool isSuccess;
  final String? errorMessage;
  final String debugInfo;

  const ApiResponse({
    required this.statusCode,
    required this.data,
    required this.isSuccess,
    this.errorMessage,
    required this.debugInfo,
  });

  /// Extract a list from common response formats.
  List<dynamic> get dataList {
    if (data is List) return data as List;
    if (data is Map) {
      for (final key in ['users', 'results', 'codes', 'payments', 'data']) {
        final val = data[key];
        if (val is List) return val;
      }
    }
    return [];
  }

  /// User-friendly error with debug details included.
  String get detailedError => '$errorMessage\n($debugInfo)';
}
