import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_color_bridge.dart';

/// Riverpod notifier for app theme mode management.
class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _prefKey = 'selected_theme_mode';

  /// Stashed initial theme mode — set by the override factory before Riverpod
  /// has registered the notifier, so we cannot call [state=] during that phase.
  /// Instead we store it here and return from [build].
  ThemeMode _initialMode = ThemeMode.light;

  @override
  ThemeMode build() => _initialMode;

  bool get isDark => state == ThemeMode.dark;
  bool get isLight => state == ThemeMode.light;
  bool get isSystem => state == ThemeMode.system;

  /// Called during app startup to set the initial theme from SharedPreferences.
  void setInitialThemeMode(ThemeMode mode) {
    _initialMode = mode;
    _syncBrowserThemeColor(mode);
  }

  /// Persist and apply a new theme mode. The UI updates instantly.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    _syncBrowserThemeColor(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _toString(mode));
  }

  /// Keep the browser chrome color (theme-color meta) in sync on web.
  /// In system mode the index.html prefers-color-scheme listener owns it.
  void _syncBrowserThemeColor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        applyThemeColor('#0F0F23');
      case ThemeMode.light:
        applyThemeColor('#00039E');
      case ThemeMode.system:
        break; // handled by the page-level JS listener
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
