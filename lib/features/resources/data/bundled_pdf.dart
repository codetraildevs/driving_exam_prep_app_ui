import 'dart:typed_data';

import 'package:pdfrx/pdfrx.dart';

/// Bundled documents are already in memory. Keep PDFium reads in native memory
/// instead of routing every read through asynchronous Dart callbacks.
Future<PdfDocument> openBundledPdf(ByteData data, String sourceName) async {
  await pdfrxFlutterInitialize();
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  return PdfDocument.openCustom(
    read: (buffer, position, size) {
      final end = (position + size).clamp(0, bytes.length);
      if (position >= end) return 0;
      buffer.setRange(0, end - position, bytes, position);
      return end - position;
    },
    fileSize: bytes.length,
    maxSizeToCacheOnMemory: bytes.length,
    sourceName: sourceName,
  );
}
