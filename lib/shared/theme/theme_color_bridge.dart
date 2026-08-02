/// Bridge for syncing the browser chrome color (`theme-color` meta) with the
/// app's active theme. Web builds get the real implementation; other platforms
/// get a no-op so this import stays safe everywhere.
export 'theme_color_bridge_stub.dart'
    if (dart.library.html) 'theme_color_bridge_web.dart';
