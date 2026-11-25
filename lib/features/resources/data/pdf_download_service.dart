import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/study_document.dart';
import '../../../shared/network/api_config.dart';

/// Downloads study PDFs on demand, caches them locally, and falls back to the
/// bundled asset when the network is unavailable.
class PdfDownloadService {
  PdfDownloadService({
    Dio? dio,
    Future<Directory> Function()? cacheDirProvider,
    Future<ByteData> Function(String assetPath)? assetLoader,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 1),
                receiveTimeout: const Duration(seconds: 2),
              ),
            ),
        _cacheDirProvider = cacheDirProvider ?? _defaultCacheDir,
        _assetLoader = assetLoader ?? rootBundle.load;

  final Dio _dio;
  final Future<Directory> Function() _cacheDirProvider;
  final Future<ByteData> Function(String assetPath) _assetLoader;

  static Future<Directory> _defaultCacheDir() async {
    try {
      return await getApplicationDocumentsDirectory();
    } on MissingPluginException {
      return Directory.systemTemp;
    }
  }

  Future<File> _cacheFile(StudyDocument document) async {
    final dir = await _cacheDirProvider();
    final resourcesDir = Directory('${dir.path}/resources');
    if (!await resourcesDir.exists()) {
      await resourcesDir.create(recursive: true);
    }
    return File('${resourcesDir.path}/${document.fileName}');
  }

  Future<Uint8List> loadPdf(StudyDocument document) async {
    final file = await _cacheFile(document);

    // 1. Use a previously cached copy when available.
    if (await file.exists()) {
      final cached = await file.readAsBytes();
      if (cached.isNotEmpty) return cached;
    }

    // 2. Try to download the latest copy from the backend.
    try {
      final response = await _dio.get<List<int>>(
        '/api/resources/${document.fileName}',
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const FormatException('Empty PDF response');
      }
      final bytes = Uint8List.fromList(data);
      await file.writeAsBytes(bytes, flush: true);
      return bytes;
    } catch (_) {
      // 3. Fall back to the bundled asset (offline / first run).
      final assetData = await _assetLoader(document.assetPath);
      final bytes = assetData.buffer.asUint8List(
        assetData.offsetInBytes,
        assetData.lengthInBytes,
      );
      try {
        await file.writeAsBytes(bytes, flush: true);
      } catch (_) {
        // Best-effort caching of the fallback copy.
      }
      return bytes;
    }
  }
}
