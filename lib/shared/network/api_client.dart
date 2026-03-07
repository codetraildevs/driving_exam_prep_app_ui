import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => statusCode == null ? message : '($statusCode) $message';
}

class ApiClient {
  final http.Client _http;

  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath').replace(queryParameters: queryParameters);
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path, queryParameters);
    final res = await _http.get(uri, headers: headers);
    _debugResponse('GET', uri, res);
    return _decode(res);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    _debugRequest('POST', uri, body);
    final res = await _http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body == null ? null : jsonEncode(body),
    );
    _debugResponse('POST', uri, res);
    return _decode(res);
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    _debugRequest('PUT', uri, body);
    final res = await _http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body == null ? null : jsonEncode(body),
    );
    _debugResponse('PUT', uri, res);
    return _decode(res);
  }

  Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    _debugRequest('DELETE', uri, body);
    final res = await _http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body == null ? null : jsonEncode(body),
    );
    _debugResponse('DELETE', uri, res);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    final bodyText = res.body;
    dynamic payload;
    if (bodyText.isNotEmpty) {
      try {
        payload = jsonDecode(bodyText);
      } catch (_) {
        payload = bodyText;
      }
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final message = _extractMessage(payload) ?? 'Request failed';
      if (kDebugMode) {
        debugPrint('[API][ERROR] status=${res.statusCode} message=$message payload=${_compact(payload)}');
      }
      throw ApiException(message, statusCode: res.statusCode);
    }

    if (payload is Map<String, dynamic>) {
      // Common PHP API envelope: { success: true|false, data: ..., message: ... }
      final success = payload['success'];
      if (success == false) {
        throw ApiException(
          (payload['message']?.toString().trim().isNotEmpty ?? false)
              ? payload['message'].toString()
              : 'Request failed',
          statusCode: res.statusCode,
        );
      }
      if (payload.containsKey('data')) return payload['data'];
    }

    return payload;
  }

  String? _extractMessage(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final msg = payload['message'] ?? payload['error'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
    if (payload is String && payload.trim().isNotEmpty) return payload.trim();
    return null;
  }

  void _debugRequest(String method, Uri uri, Object? body) {
    if (!kDebugMode) return;
    debugPrint('[API][REQ] $method $uri body=${_compact(body)}');
  }

  void _debugResponse(String method, Uri uri, http.Response res) {
    if (!kDebugMode) return;
    debugPrint('[API][RES] $method $uri status=${res.statusCode} body=${_compact(res.body)}');
  }

  String _compact(Object? value) {
    final text = value?.toString() ?? 'null';
    if (text.length <= 400) return text;
    return '${text.substring(0, 400)}...';
  }
}

