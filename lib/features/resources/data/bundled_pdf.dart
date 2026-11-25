import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

Future<PdfDocument> openBundledPdf(ByteData data, String sourceName) async {
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  return openPdfBytes(bytes, sourceName);
}

/// Opens an in-memory PDF (bundled or downloaded) using PDFium.
Future<PdfDocument> openPdfBytes(Uint8List bytes, String sourceName) async {
  await pdfrxFlutterInitialize();
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
