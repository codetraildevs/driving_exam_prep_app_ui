import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../session/auth_session.dart';

/// Centralized API helper with debug logging for all HTTP calls.
class ApiHelper {
  static final ApiHelper _instance = ApiHelper._();
  factory ApiHelper() => _instance;
  ApiHelper._();

  /// Performs a GET request with auth token and debug logging.
  Future<ApiResponse> get(String path, {Map<String, String>? queryParams}) async {
    final uri = _buildUri(path, queryParams);
    _logRequest('GET', uri);
    try {
      final token = await AuthSession().getToken();
      final response = await http.get(
        uri,
        headers: _headers(token),
      ).timeout(const Duration(seconds: 20));
      return _processResponse('GET', uri, response);
    } on SocketException catch (e) {
      return _networkError('GET', uri, 'No internet connection: $e');
    } on http.ClientException catch (e) {
      return _networkError('GET', uri, 'Connection failed: $e');
    } catch (e) {
      return _networkError('GET', uri, '$e');
    }
  }

  /// Performs a POST request with auth token and debug logging.
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path);
    _logRequest('POST', uri, body: body);
    try {
      final token = await AuthSession().getToken();
      final response = await http.post(
        uri,
        headers: _headers(token),
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(seconds: 20));
      return _processResponse('POST', uri, response);
    } on SocketException catch (e) {
      return _networkError('POST', uri, 'No internet connection: $e');
    } on http.ClientException catch (e) {
      return _networkError('POST', uri, 'Connection failed: $e');
    } catch (e) {
      return _networkError('POST', uri, '$e');
    }
  }

  /// Performs a PATCH request with auth token and debug logging.
  Future<ApiResponse> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path);
    _logRequest('PATCH', uri, body: body);
    try {
      final token = await AuthSession().getToken();
      final response = await http.patch(
        uri,
        headers: _headers(token),
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(seconds: 20));
      return _processResponse('PATCH', uri, response);
    } on SocketException catch (e) {
      return _networkError('PATCH', uri, 'No internet connection: $e');
    } on http.ClientException catch (e) {
      return _networkError('PATCH', uri, 'Connection failed: $e');
    } catch (e) {
      return _networkError('PATCH', uri, '$e');
    }
  }

  /// Performs a DELETE request with auth token and debug logging.
  Future<ApiResponse> delete(String path) async {
    final uri = _buildUri(path);
    _logRequest('DELETE', uri);
    try {
      final token = await AuthSession().getToken();
      final response = await http.delete(
        uri,
        headers: _headers(token),
      ).timeout(const Duration(seconds: 20));
      return _processResponse('DELETE', uri, response);
    } on SocketException catch (e) {
      return _networkError('DELETE', uri, 'No internet connection: $e');
    } on http.ClientException catch (e) {
      return _networkError('DELETE', uri, 'Connection failed: $e');
    } catch (e) {
      return _networkError('DELETE', uri, '$e');
    }
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final base = Uri.parse(ApiConfig.baseUrl);
    return base.replace(
      path: path,
      queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
    );
  }

  Map<String, String> _headers(String? token) => {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  ApiResponse _processResponse(String method, Uri uri, http.Response response) {
    _logResponse(method, uri, response);
    dynamic data;
    try {
      data = json.decode(response.body);
    } catch (_) {
      data = response.body;
    }

    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    String? errorMessage;
    if (!isSuccess) {
      if (response.statusCode == 401) {
        // Token expired or invalid — clear local session so user is forced to re-login.
        AuthSession().clear();
        errorMessage = 'Session expired. Please log in again.';
      } else if (response.statusCode == 403) {
        errorMessage = 'Insufficient permissions for this operation.';
      } else if (data is Map) {
        errorMessage = (data['message'] ?? data['error'] ?? '').toString();
      }
      if (errorMessage == null || errorMessage.isEmpty) {
        errorMessage = 'HTTP ${response.statusCode}';
      }
    }

    // Unwrap common API envelope: {success: true, data: <payload>}
    if (isSuccess && data is Map && data.containsKey('data')) {
      data = data['data'];
    }

    return ApiResponse(
      statusCode: response.statusCode,
      data: data,
      isSuccess: isSuccess,
      errorMessage: errorMessage,
      debugInfo: '$method $uri → ${response.statusCode}',
    );
  }

  ApiResponse _networkError(String method, Uri uri, String error) {
    if (kDebugMode) debugPrint('❌ API ERROR [$method $uri]: $error');
    return ApiResponse(
      statusCode: 0,
      data: null,
      isSuccess: false,
      errorMessage: error,
      debugInfo: '$method $uri → NETWORK ERROR: $error',
    );
  }

  void _logRequest(String method, Uri uri, {Map<String, dynamic>? body}) {
    if (!kDebugMode) return;
    debugPrint('🌐 API REQUEST: $method $uri');
    if (body != null) {
      debugPrint('   Body: ${json.encode(body)}');
    }
  }

  void _logResponse(String method, Uri uri, http.Response response) {
    if (!kDebugMode) return;
    final status = response.statusCode;
    final icon = (status >= 200 && status < 300) ? '✅' : '⚠️';
    debugPrint('$icon API RESPONSE: $method $uri → $status');
    // Truncate long bodies
    final bodySnippet = response.body.length > 500
        ? '${response.body.substring(0, 500)}...'
        : response.body;
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
