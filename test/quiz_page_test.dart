import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/exam/data/repositories/exam_repository.dart';
import 'package:traffic_rule_in_rwanda/features/practice/presentation/pages/quiz_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/responsive/responsive_layout.dart';

/// quizId known to exist in `assets/exams/en_exams.json`.
const _kQuizId = '177';

void _stubChannels(WidgetTester tester) {
  // QuizPage calls the screen-protector plugin and its own security channel
  // in initState/dispose without awaiting them, so stub both to avoid
  // MissingPluginException failing the test.
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('screen_protector'),
    (MethodCall call) async => null,
  );
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('com.driveprep.rwanda/security'),
    (MethodCall call) async => null,
  );
  addTearDown(() {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('screen_protector'),
      null,
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.driveprep.rwanda/security'),
      null,
    );
  });
}

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
      home: QuizPage(quizId: _kQuizId),
    ),
  );
}

/// Loads the exams into the (singleton) repository cache using real async so
/// the page's lookup resolves without asset I/O during fake-async pumping.
Future<void> _seedExamCache(WidgetTester tester) async {
  await tester.runAsync(() => ExamRepository().loadAllExams('en'));
}

Future<void> _pumpQuiz(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp());
  // Let the exam future resolve and the first frame render.
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }

  // Always unmount before the test ends so the countdown timer is cancelled
  // even if an assertion fails mid-test.
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
  });
}

/// Width of the quiz progress bar, which lives inside the width-capped
/// progress section — a good proxy for how wide the content is.
double _progressWidth(WidgetTester tester) {
  return tester.getSize(find.byType(LinearProgressIndicator)).width;
}

void main() {
  setUp(() {
    ExamRepository().clearCache();
  });

  group('QuizPage responsive content', () {
    testWidgets(
      'desktop width caps content at AppContentWidths.narrow and centers it',
      (tester) async {
        _stubChannels(tester);
        await _seedExamCache(tester);
        await _pumpQuiz(tester, const Size(1200, 800));

        // Exam loaded — the question view is showing.
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.byType(ConstrainedContent), findsWidgets);

        // Every ConstrainedContent on the quiz page uses the narrow preset.
        final constrained = tester
            .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
            .toList();
        expect(constrained, isNotEmpty);
        for (final c in constrained) {
          expect(c.maxWidth, AppContentWidths.narrow);
        }

        // The progress bar is capped at ~800px instead of stretching to the
        // full 1200px window (800 − no inner padding → ~800).
        expect(_progressWidth(tester), closeTo(AppContentWidths.narrow, 8));
      },
    );

    testWidgets('mobile width lets content fill the screen', (tester) async {
      _stubChannels(tester);
      await _seedExamCache(tester);
      await _pumpQuiz(tester, const Size(400, 800));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // No cap below the narrow width — the bar fills the (padded) window.
      expect(_progressWidth(tester), lessThanOrEqualTo(400));
      expect(_progressWidth(tester), greaterThan(300));
    });
  });
}
