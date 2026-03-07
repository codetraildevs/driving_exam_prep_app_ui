import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text styles for the app.
///
/// Base styles (heading*, body*, label*, display) intentionally have NO colour
/// set – they inherit the correct colour from the theme's DefaultTextStyle,
/// which differs between light and dark mode.
///
/// Styles that are always rendered on a coloured/gradient background
/// (buttonLarge, buttonMedium, buttonSmall) keep AppColors.textInverse (white)
/// because they sit on primary/accent backgrounds regardless of theme.
class AppTextStyles {
  static TextStyle _getFont({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height ?? 1.5,
    );
  }

  // ─── Headings (no colour — inherits from theme) ──────────────────────────

  static TextStyle heading1 = _getFont(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle heading2 = _getFont(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static TextStyle heading3 = _getFont(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static TextStyle heading4 = _getFont(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );

  static TextStyle heading5 = _getFont(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle heading6 = _getFont(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // ─── Body (no colour — inherits from theme) ───────────────────────────────

  static TextStyle bodyLarge = _getFont(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle bodyMedium = _getFont(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle bodySmall = _getFont(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // ─── Labels (no colour — inherits from theme) ────────────────────────────

  static TextStyle labelLarge = _getFont(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium = _getFont(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = _getFont(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // ─── Display (no colour — inherits from theme) ───────────────────────────

  static TextStyle display = _getFont(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  // ─── Buttons (always on a coloured background → always textInverse) ──────

  static TextStyle buttonLarge = _getFont(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
    letterSpacing: 0.5,
  );

  static TextStyle buttonMedium = _getFont(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
    letterSpacing: 0.5,
  );

  static TextStyle buttonSmall = _getFont(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
    letterSpacing: 0.5,
  );
}
