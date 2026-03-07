import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Convenience extensions on [BuildContext] for theme-aware color access.
///
/// Use `context.cp` (colorScheme.primary) instead of [AppColors.primary] in
/// widgets so that the correct shade is returned in both light and dark mode.
extension ThemeContextExt on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;

  /// The theme's primary colour.
  /// In dark mode this resolves to [AppColors.primaryLight] so that the colour
  /// remains visually distinct on dark backgrounds.
  Color get cp => Theme.of(this).colorScheme.primary;

  /// Theme-appropriate primary gradient.
  LinearGradient get primaryGradient =>
      AppColors.primaryGradientFor(Theme.of(this).brightness);

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
