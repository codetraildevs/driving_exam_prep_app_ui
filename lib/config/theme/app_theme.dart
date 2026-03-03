import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
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
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display,
        headlineLarge: AppTextStyles.heading1,
        headlineMedium: AppTextStyles.heading2,
        headlineSmall: AppTextStyles.heading3,
        titleLarge: AppTextStyles.heading4,
        titleMedium: AppTextStyles.heading5,
        titleSmall: AppTextStyles.heading6,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading5,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      cardTheme: CardTheme(
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
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textInverse,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.neutral200,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surface;
        }),
        side: const BorderSide(color: AppColors.neutral300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primaryLight,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.neutral900,
        primaryContainer: AppColors.primary,
        onPrimaryContainer: AppColors.primaryLight,
        secondary: AppColors.accentLight,
        onSecondary: AppColors.neutral900,
        secondaryContainer: AppColors.accent,
        onSecondaryContainer: AppColors.accentLight,
        tertiary: AppColors.successLight,
        onTertiary: AppColors.neutral900,
        tertiaryContainer: AppColors.success,
        onTertiaryContainer: AppColors.successLight,
        error: AppColors.errorLight,
        onError: AppColors.neutral900,
        errorContainer: AppColors.error,
        onErrorContainer: AppColors.errorLight,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.neutral100,
        outline: AppColors.neutral700,
        outlineVariant: AppColors.neutral800,
        background: AppColors.backgroundDark,
        onBackground: AppColors.neutral100,
      ),
    );
  }
}
