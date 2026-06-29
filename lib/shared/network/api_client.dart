import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code;

  ApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => statusCode == null ? message : '($statusCode) $message';
}

class ApiClient {
  late final Dio _dio;

  ApiClient({Dio? dioClient}) {
    _dio = dioClient ?? Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    _debugRequest('GET', path, queryParameters: queryParameters);
    try {
      final res = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      _debugResponse('GET', path, res);
      return _decode(res);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    _debugRequest('POST', path, body: body);
    try {
      final res = await _dio.post(
        path,
        data: body == null ? null : jsonEncode(body),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            ...?headers,
          },
        ),
      );
      _debugResponse('POST', path, res);
      return _decode(res);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    _debugRequest('PUT', path, body: body);
    try {
      final res = await _dio.put(
        path,
        data: body == null ? null : jsonEncode(body),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            ...?headers,
          },
        ),
      );
      _debugResponse('PUT', path, res);
      return _decode(res);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    _debugRequest('DELETE', path, body: body);
    try {
      final res = await _dio.delete(
        path,
        data: body == null ? null : jsonEncode(body),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            ...?headers,
          },
        ),
      );
      _debugResponse('DELETE', path, res);
      return _decode(res);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException('NETWORK_ERROR');
      case DioExceptionType.connectionError:
        return ApiException('NETWORK_ERROR');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _extractMessage(e.response?.data) ??
            'Request failed (HTTP $statusCode)';
        final code = _extractCode(e.response?.data);
        if (kDebugMode) {
          debugPrint(
            '[API][ERROR] status=$statusCode message=$message '
            'payload=${_compact(e.response?.data)}',
          );
        }
        return ApiException(message, statusCode: statusCode, code: code);
      default:
        if (kDebugMode) {
          debugPrint('[API][ERROR] ${e.type}: ${e.message}');
        }
        return ApiException('An unexpected error occurred');
    }
  }

  dynamic _decode(Response res) {
    final data = res.data;

    if (res.statusCode! < 200 || res.statusCode! >= 300) {
      final message = _extractMessage(data) ?? 'Request failed';
      if (kDebugMode) {
        debugPrint('[API][ERROR] status=${res.statusCode} message=$message payload=${_compact(data)}');
      }
      throw ApiException(message, statusCode: res.statusCode);
    }

    if (data is Map<String, dynamic>) {
      // Common PHP API envelope: { success: true|false, data: ..., message: ... }
      final success = data['success'];
      if (success == false) {
        throw ApiException(
          (data['message']?.toString().trim().isNotEmpty ?? false)
              ? data['message'].toString()
              : 'Request failed',
          statusCode: res.statusCode,
          code: _extractCode(data),
        );
      }
      if (data.containsKey('data')) return data['data'];
    }

    return data;
  }

  String? _extractMessage(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final msg = payload['message'] ?? payload['error'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
    if (payload is Map) {
      final msg = payload['message'] ?? payload['error'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString().trim();
      }
    }
    if (payload is String && payload.trim().isNotEmpty) return payload.trim();
    return null;
  }

  String? _extractCode(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final code = payload['error_code'] ?? payload['errorCode'];
      if (code is String && code.trim().isNotEmpty) return code.trim();
    }
    if (payload is Map) {
      final code = payload['error_code'] ?? payload['errorCode'];
      if (code != null && code.toString().trim().isNotEmpty) {
        return code.toString().trim();
      }
    }
    return null;
  }

  void _debugRequest(String method, String path, {Object? body, Map<String, dynamic>? queryParameters}) {
    if (!kDebugMode) return;
    final queryStr = queryParameters != null ? '?$queryParameters' : '';
    debugPrint('[API][REQ] $method $path$queryStr body=${_compact(body)}');
  }

  void _debugResponse(String method, String path, Response res) {
    if (!kDebugMode) return;
    debugPrint('[API][RES] $method $path status=${res.statusCode} body=${_compact(res.data)}');
  }

  String _compact(Object? value) {
    final text = value?.toString() ?? 'null';
    if (text.length <= 400) return text;
    return '${text.substring(0, 400)}...';
  }
}
