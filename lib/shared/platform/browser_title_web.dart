import 'dart:js_interop';

/// Sets `document.title` on web builds so the browser tab reflects the
/// current route (e.g. "Practice — Rwanda Traffic Rule").
@JS('document.title')
external set _documentTitle(String value);

void setBrowserTitle(String title) => _documentTitle = title;
