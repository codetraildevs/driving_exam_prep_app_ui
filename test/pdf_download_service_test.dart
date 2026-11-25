import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/resources/data/pdf_download_service.dart';
import 'package:traffic_rule_in_rwanda/features/resources/domain/study_document.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Dio fakeDio(List<int> payload) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<List<int>>(
              requestOptions: options,
              statusCode: 200,
              data: payload,
            ),
          );
        },
      ),
    );
    return dio;
  }

  Dio failingDio() {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            ),
          );
        },
      ),
    );
    return dio;
  }

  test('downloads and caches PDF when network succeeds', () async {
    final tempDir = await Directory.systemTemp.createTemp('pdfsvc_ok');
    addTearDown(() => tempDir.delete(recursive: true));
    final payload = Uint8List.fromList(List<int>.generate(64, (i) => i));
    final service = PdfDownloadService(
      dio: fakeDio(payload),
      cacheDirProvider: () async => tempDir,
      assetLoader: (path) async => throw StateError('should not use asset'),
    );

    final bytes = await service.loadPdf(StudyDocument.roadSigns);
    expect(bytes, orderedEquals(payload));

    final cacheFile = File('${tempDir.path}/resources/Ibyapa.pdf');
    expect(await cacheFile.exists(), isTrue);
    expect(await cacheFile.readAsBytes(), orderedEquals(payload));
  });

  test('falls back to bundled asset and caches when network fails', () async {
    final tempDir = await Directory.systemTemp.createTemp('pdfsvc_fail');
    addTearDown(() => tempDir.delete(recursive: true));
    final service = PdfDownloadService(
      dio: failingDio(),
      cacheDirProvider: () async => tempDir,
      assetLoader: rootBundle.load,
    );

    final bytes = await service.loadPdf(StudyDocument.roadSigns);
    final bundled = await rootBundle.load(StudyDocument.roadSigns.assetPath);
    final bundledBytes = bundled.buffer.asUint8List(
      bundled.offsetInBytes,
      bundled.lengthInBytes,
    );
    expect(bytes, orderedEquals(bundledBytes));

    final cacheFile = File('${tempDir.path}/resources/Ibyapa.pdf');
    expect(await cacheFile.exists(), isTrue);
  });

  test('uses cached copy without network or asset fallback', () async {
    final tempDir = await Directory.systemTemp.createTemp('pdfsvc_cache');
    addTearDown(() => tempDir.delete(recursive: true));
    final resourcesDir = Directory('${tempDir.path}/resources');
    await resourcesDir.create(recursive: true);
    final cachedBytes = Uint8List.fromList([1, 2, 3, 4]);
    await File('${resourcesDir.path}/Ibyapa.pdf').writeAsBytes(cachedBytes);

    final service = PdfDownloadService(
      dio: failingDio(),
      cacheDirProvider: () async => tempDir,
      assetLoader: (path) async => throw StateError('should not use asset'),
    );

    final bytes = await service.loadPdf(StudyDocument.roadSigns);
    expect(bytes, orderedEquals(cachedBytes));
  });
}
