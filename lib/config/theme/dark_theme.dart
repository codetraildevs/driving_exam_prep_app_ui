import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Dark theme for the Traffic Rules App.
/// Uses a comfortable dark palette that avoids eye-straining high contrast.
ThemeData buildDarkTheme() {
  // Dark-mode surface and background
  const surface = AppColors.surfaceDark;         // #1E293B
  const background = AppColors.backgroundDark;   // #0F0F23
  // Use neutral200 (#E5E7EB) instead of near-white neutral100 to reduce harshness
  const onSurface = AppColors.neutral200;
  const onSurface70 = AppColors.neutral400;      // #9CA3AF
  const outline = AppColors.neutral700;
  const outlineVariant = AppColors.neutral800;

  // In dark mode use primaryLight (#3B82F6) wherever primary would create
  // near-black artefacts on dark backgrounds
  const darkPrimary = AppColors.primaryLight;

  final textColor = onSurface;
  final subColor = onSurface70;

  final textTheme = TextTheme(
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

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: AppColors.primaryLight,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
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
      surface: surface,
      onSurface: onSurface,
      outline: outline,
      outlineVariant: outlineVariant,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.heading5.copyWith(color: onSurface),
      iconTheme: const IconThemeData(color: onSurface),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.neutral900,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: AppTextStyles.buttonMedium.copyWith(color: AppColors.neutral900),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.primaryLight, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: AppTextStyles.buttonMedium.copyWith(color: AppColors.primaryLight),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTextStyles.buttonMedium.copyWith(color: AppColors.primaryLight),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF243447),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.errorLight),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: subColor),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: subColor),
      errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.errorLight),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: outline),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: outline,
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: onSurface70,
      elevation: 16,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryLight),
      unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(color: onSurface70),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2D3748),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      linearTrackColor: outline,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.neutral900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
        return surface;
      }),
      side: const BorderSide(color: outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: AppTextStyles.heading5.copyWith(color: textColor),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: textColor),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: subColor,
      textColor: textColor,
    ),
    iconTheme: const IconThemeData(color: onSurface),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return darkPrimary;
        return onSurface70;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return darkPrimary.withValues(alpha: 0.4);
        return outline;
      }),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: background),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: darkPrimary.withValues(alpha: 0.2),
      iconTheme: WidgetStateProperty.all(const IconThemeData(color: onSurface)),
    ),
  );
}
