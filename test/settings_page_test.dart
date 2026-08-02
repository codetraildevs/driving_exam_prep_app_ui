import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/settings/presentation/pages/settings_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/responsive/responsive_layout.dart';

Widget _buildApp() {
  return const ProviderScope(
    child: MaterialApp(
      locale: Locale('en'),
      supportedLocales: LocaleNotifier.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
      ],
      home: SettingsPage(),
    ),
  );
}

Future<void> _pumpSettings(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp());
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Width of the appearance card — the widest element inside the capped
/// content column, so its width reflects the content cap.
double _themeCardWidth(WidgetTester tester) {
  final l10n = AppLocalizations.of(tester.element(find.byType(SettingsPage)));
  final card = find
      .ancestor(
        of: find.text(l10n.settingsAppearance),
        matching: find.byType(Container),
      )
      .first;
  return tester.getSize(card).width;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsPage responsive content', () {
    testWidgets('desktop width caps content at AppContentWidths.narrow', (
      tester,
    ) async {
      await _pumpSettings(tester, const Size(1200, 800));

      final constrained = tester
          .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
          .toList();
      expect(constrained, isNotEmpty);
      for (final c in constrained) {
        expect(c.maxWidth, AppContentWidths.narrow);
      }

      // The appearance card is capped at ~800px (narrow minus its own
      // 16px side margins) instead of stretching to the full 1200px window.
      expect(_themeCardWidth(tester), closeTo(AppContentWidths.narrow, 8));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      await _pumpSettings(tester, const Size(400, 800));

      // No cap below the narrow width — the card fills the window.
      expect(_themeCardWidth(tester), lessThanOrEqualTo(400));
      expect(_themeCardWidth(tester), greaterThan(300));
    });
  });
}
