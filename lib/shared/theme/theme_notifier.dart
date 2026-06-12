import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }

  /// Persist and apply a new theme mode. The UI updates instantly.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _toString(mode));
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
