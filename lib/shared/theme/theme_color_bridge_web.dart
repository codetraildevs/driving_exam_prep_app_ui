// dart:html is the simplest stable web DOM access here; the recommended
// package:web/dart:js_interop would add a dependency for one meta update.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Updates the browser chrome color (`<meta name="theme-color">`) to match the
/// active app theme. Pass a hex string like `#00039E` or `#0F0F23`.
void applyThemeColor(String hexColor) {
  if (hexColor.isEmpty) return;
  final meta = html.document.querySelector('meta[name="theme-color"]');
  if (meta != null) {
    meta.setAttribute('content', hexColor);
  }
}
