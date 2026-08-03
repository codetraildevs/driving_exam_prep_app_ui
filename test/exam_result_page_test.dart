import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/exam/presentation/pages/exam_result_page.dart';
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
    home: ExamResultPage(
      attemptId: 'a1',
      // Below the pass threshold so no confetti particles are spawned.
      score: 60,
      totalQuestions: 30,
      correctAnswers: 18,
      timeSpentSeconds: 420,
      examTitle: 'Test Exam',
    ),
  );
}


Future<void> _pumpResult(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp());
  // Let the staggered entrance animations (200/400ms delays) settle.
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Width of the capped result card column, measured directly.
double _cappedWidth(WidgetTester tester) {
  final box = find
      .descendant(
        of: find.byType(ConstrainedContent),
        matching: find.byType(ConstrainedBox),
      )
      .first;
  return tester.getSize(box).width;
}

void main() {
  group('ExamResultPage responsive content', () {
    testWidgets('desktop width caps content at AppContentWidths.compact', (
      tester,
    ) async {
      await _pumpResult(tester, const Size(1200, 800));

      final constrained = tester
          .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
          .toList();
      expect(constrained, isNotEmpty);
      for (final c in constrained) {
        expect(c.maxWidth, AppContentWidths.compact);
      }

      // The result card is capped at ~720px instead of stretching to 1200px.
      expect(_cappedWidth(tester), closeTo(AppContentWidths.compact, 8));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      await _pumpResult(tester, const Size(400, 800));

      // Below the compact cap the content fills the (padded) window.
      expect(_cappedWidth(tester), lessThanOrEqualTo(400));
      expect(_cappedWidth(tester), greaterThan(300));
    });
  });
}
