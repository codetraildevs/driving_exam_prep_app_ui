import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/settings/presentation/pages/terms_of_service_page.dart';
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
    home: TermsOfServicePage(),
  );
}

Future<void> _pumpTerms(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp());
  await tester.pump(const Duration(milliseconds: 50));
}

/// Width of the first term card — a full-width element inside the capped
/// content column, so its width reflects the content cap.
double _termCardWidth(WidgetTester tester) {
  final l10n = AppLocalizations.of(
    tester.element(find.byType(TermsOfServicePage)),
  );
  final card = find
      .ancestor(
        of: find.text(l10n.termsAcceptance),
        matching: find.byType(Container),
      )
      .first;
  return tester.getSize(card).width;
}

void main() {
  group('TermsOfServicePage responsive content', () {
    testWidgets('desktop width caps content at AppContentWidths.narrow', (
      tester,
    ) async {
      await _pumpTerms(tester, const Size(1200, 800));

      final constrained = tester
          .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
          .toList();
      expect(constrained, isNotEmpty);
      for (final c in constrained) {
        expect(c.maxWidth, AppContentWidths.narrow);
      }

      expect(_termCardWidth(tester), closeTo(AppContentWidths.narrow, 8));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      await _pumpTerms(tester, const Size(400, 800));

      expect(_termCardWidth(tester), lessThanOrEqualTo(400));
      expect(_termCardWidth(tester), greaterThan(300));
    });
  });
}
