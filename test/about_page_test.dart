import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/settings/presentation/pages/about_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/responsive/responsive_layout.dart';

Widget _buildApp() {
  return const MaterialApp(
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
    home: AboutPage(),
  );
}

Future<void> _pumpAbout(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp());
  await tester.pump(const Duration(milliseconds: 50));
}

/// Width of the description card — a full-width element inside the capped
/// content column, so its width reflects the content cap.
double _descriptionCardWidth(WidgetTester tester) {
  final l10n = AppLocalizations.of(tester.element(find.byType(AboutPage)));
  final card = find
      .ancestor(
        of: find.text(l10n.aboutDescription),
        matching: find.byType(Container),
      )
      .first;
  return tester.getSize(card).width;
}

void main() {
  group('AboutPage responsive content', () {
    testWidgets('desktop width caps content at AppContentWidths.narrow', (
      tester,
    ) async {
      await _pumpAbout(tester, const Size(1200, 800));

      final constrained = tester
          .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
          .toList();
      expect(constrained, isNotEmpty);
      for (final c in constrained) {
        expect(c.maxWidth, AppContentWidths.narrow);
      }

      // The card is capped at ~800px instead of stretching full-width.
      expect(
        _descriptionCardWidth(tester),
        closeTo(AppContentWidths.narrow, 8),
      );
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      await _pumpAbout(tester, const Size(400, 800));

      // No cap below the narrow width — the card fills the (padded) window.
      expect(_descriptionCardWidth(tester), lessThanOrEqualTo(400));
      expect(_descriptionCardWidth(tester), greaterThan(300));
    });
  });
}
