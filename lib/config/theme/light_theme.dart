import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Light theme for the Traffic Rules App.
/// Uses the app's primary blue branding colours on a white/grey background.
ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textInverse,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.accent,
      onSecondary: AppColors.textInverse,
      secondaryContainer: AppColors.accentLight,
      onSecondaryContainer: AppColors.accent,
      tertiary: AppColors.success,
      onTertiary: AppColors.textInverse,
      tertiaryContainer: AppColors.successLight,
      onTertiaryContainer: AppColors.success,
      error: AppColors.error,
      onError: AppColors.textInverse,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      outline: AppColors.neutral300,
      outlineVariant: AppColors.neutral200,
    ),
    textTheme: _buildTextTheme(isLight: true),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.heading5,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.neutral300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.neutral300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: AppTextStyles.bodyMedium,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.neutral200,
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.neutral400,
      elevation: 16,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.neutral900,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textInverse),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.neutral200,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textInverse,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.surface;
      }),
      side: const BorderSide(color: AppColors.neutral300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: AppTextStyles.heading5.copyWith(color: AppColors.textPrimary),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.textSecondary,
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.neutral400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryLight.withValues(alpha: 0.4);
        return AppColors.neutral200;
      }),
    ),
  );
}

TextTheme _buildTextTheme({required bool isLight}) {
  final textColor = isLight ? AppColors.textPrimary : AppColors.neutral100;
  final subColor = isLight ? AppColors.textSecondary : AppColors.neutral400;

  return TextTheme(
    displayLarge: AppTextStyles.display.copyWith(color: textColor),
    headlineLarge: AppTextStyles.heading1.copyWith(color: textColor),
    headlineMedium: AppTextStyles.heading2.copyWith(color: textColor),
    headlineSmall: AppTextStyles.heading3.copyWith(color: textColor),
    titleLarge: AppTextStyles.heading4.copyWith(color: textColor),
    titleMedium: AppTextStyles.heading5.copyWith(color: textColor),
    titleSmall: AppTextStyles.heading6.copyWith(color: textColor),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textColor),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(color: textColor),
    bodySmall: AppTextStyles.bodySmall.copyWith(color: subColor),
    labelLarge: AppTextStyles.labelLarge.copyWith(color: textColor),
    labelMedium: AppTextStyles.labelMedium.copyWith(color: subColor),
    labelSmall: AppTextStyles.labelSmall.copyWith(color: subColor),
  );
}
