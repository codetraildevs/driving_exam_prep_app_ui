import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/exam/presentation/pages/exam_intro_page.dart';
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
    home: ExamIntroPage(),
  );
}

Future<void> _pumpIntro(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp());
  await tester.pump(const Duration(milliseconds: 50));
}

/// Width of the first instruction card — a stretch child inside the capped
/// content column, so its width reflects the content cap.
double _instructionCardWidth(WidgetTester tester) {
  final l10n = AppLocalizations.of(tester.element(find.byType(ExamIntroPage)));
  final card = find
      .ancestor(
        of: find.text(l10n.examTimeLimit),
        matching: find.byType(Container),
      )
      .first;
  return tester.getSize(card).width;
}

void main() {
  group('ExamIntroPage responsive content', () {
    testWidgets('desktop width caps content at AppContentWidths.form', (
      tester,
    ) async {
      await _pumpIntro(tester, const Size(1200, 800));

      final constrained = tester
          .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
          .toList();
      expect(constrained, isNotEmpty);
      for (final c in constrained) {
        expect(c.maxWidth, AppContentWidths.form);
      }

      expect(_instructionCardWidth(tester), closeTo(AppContentWidths.form, 8));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      await _pumpIntro(tester, const Size(400, 800));

      expect(_instructionCardWidth(tester), lessThanOrEqualTo(400));
      expect(_instructionCardWidth(tester), greaterThan(300));
    });
  });
}
