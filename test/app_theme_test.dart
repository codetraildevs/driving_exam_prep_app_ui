import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/config/theme/app_colors.dart';
import 'package:traffic_rule_in_rwanda/config/theme/app_theme.dart';

void main() {
  // AppTheme builds TextStyles that resolve Google Fonts, which needs the
  // binding before a theme can be constructed outside a widget test.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Brand palette', () {
    test('primary is the purple brand colour rgb(96, 44, 145)', () {
      expect(AppColors.primary, const Color(0xFF602C91));
    });

    test('related primary shades keep the purple hue', () {
      // Light shade is lighter than primary, dark shade is darker.
      expect(
        AppColors.primaryLight.computeLuminance(),
        greaterThan(AppColors.primary.computeLuminance()),
      );
      expect(
        AppColors.primaryDark.computeLuminance(),
        lessThan(AppColors.primary.computeLuminance()),
      );
    });

    test('themes use the brand purple as their primary colour', () {
      expect(AppTheme.lightTheme.colorScheme.primary, AppColors.primary);
      // Dark surfaces need the lighter tint to stay legible.
      expect(AppTheme.darkTheme.colorScheme.primary, AppColors.primaryLight);
    });

    test('primary gradients are built from the purple palette', () {
      expect(
        AppColors.primaryGradientFor(Brightness.light),
        AppColors.primaryGradient,
      );
      expect(
        AppColors.primaryGradientFor(Brightness.dark),
        AppColors.primaryGradientDark,
      );
      expect(AppColors.primaryGradient.colors, [
        AppColors.primary,
        AppColors.primaryLight,
      ]);
    });
  });
}
