import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/settings/presentation/pages/privacy_policy_page.dart';
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
    home: PrivacyPolicyPage(),
  );
}

Future<void> _pumpPrivacy(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp());
  await tester.pump(const Duration(milliseconds: 50));
}

/// Width of the first policy card — a full-width element inside the capped
/// content column, so its width reflects the content cap.
double _policyCardWidth(WidgetTester tester) {
  final l10n = AppLocalizations.of(
    tester.element(find.byType(PrivacyPolicyPage)),
  );
  final card = find
      .ancestor(
        of: find.text(l10n.privacyDataCollection),
        matching: find.byType(Container),
      )
      .first;
  return tester.getSize(card).width;
}

void main() {
  group('PrivacyPolicyPage responsive content', () {
    testWidgets('desktop width caps content at AppContentWidths.narrow', (
      tester,
    ) async {
      await _pumpPrivacy(tester, const Size(1200, 800));

      final constrained = tester
          .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
          .toList();
      expect(constrained, isNotEmpty);
      for (final c in constrained) {
        expect(c.maxWidth, AppContentWidths.narrow);
      }

      expect(_policyCardWidth(tester), closeTo(AppContentWidths.narrow, 8));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      await _pumpPrivacy(tester, const Size(400, 800));

      expect(_policyCardWidth(tester), lessThanOrEqualTo(400));
      expect(_policyCardWidth(tester), greaterThan(300));
    });
  });
}
