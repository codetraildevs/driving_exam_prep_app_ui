import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/exam/presentation/pages/exam_page.dart';
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
    home: ExamPage(),
  );
}

Future<void> _pumpExam(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp());
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// ExamPage runs a countdown via `Future.doWhile` whose 1s `Future.delayed`
/// timer is not cancellable, so unmount and advance past it so the loop's
/// `!mounted` check exits it before the pending-timer check.
Future<void> _flushCountdownTimer(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 2));
}

/// Width of the exam progress bar, which lives inside the width-capped
/// progress section — a good proxy for how wide the content is.
double _progressWidth(WidgetTester tester) {
  return tester.getSize(find.byType(LinearProgressIndicator)).width;
}

void main() {
  group('ExamPage responsive content', () {
    testWidgets(
      'desktop width caps content at AppContentWidths.narrow and centers it',
      (tester) async {
        await _pumpExam(tester, const Size(1200, 800));

        // Question view is showing.
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.byType(ConstrainedContent), findsWidgets);

        // Every ConstrainedContent on the exam page uses the narrow preset.
        final constrained = tester
            .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
            .toList();
        expect(constrained, isNotEmpty);
        for (final c in constrained) {
          expect(c.maxWidth, AppContentWidths.narrow);
        }

        // The progress bar is capped at ~800px instead of stretching to the
        // full 1200px window.
        expect(_progressWidth(tester), closeTo(AppContentWidths.narrow, 8));

        await _flushCountdownTimer(tester);
      },
    );

    testWidgets('mobile width lets content fill the screen', (tester) async {
      await _pumpExam(tester, const Size(400, 800));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // No cap below the narrow width — the bar fills the (padded) window.
      expect(_progressWidth(tester), lessThanOrEqualTo(400));
      expect(_progressWidth(tester), greaterThan(300));

      await _flushCountdownTimer(tester);
    });
  });
}
