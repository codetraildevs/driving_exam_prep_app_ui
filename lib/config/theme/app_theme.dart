import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// Gateway for app themes — all callers use AppTheme.lightTheme / darkTheme
/// so no import changes are needed across the codebase.
class AppTheme {
  static ThemeData get lightTheme => buildLightTheme();
  static ThemeData get darkTheme => buildDarkTheme();
}
