import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/shared/network/offline_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/config/theme/app_colors.dart';
import 'package:traffic_rule_in_rwanda/features/exam/data/repositories/exam_repository.dart';
import 'package:traffic_rule_in_rwanda/features/practice/presentation/pages/quiz_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/responsive/responsive_layout.dart';

/// quizId known to exist in both `assets/exams/en_exams.json` and
/// `assets/exams/rw_exams.json`.
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
    const MethodChannel('com.trafficrules.rwanda.app/security'),
    (MethodCall call) async => null,
  );
  addTearDown(() {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('screen_protector'),
      null,
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.trafficrules.rwanda.app/security'),
      null,
    );
  });
}

Widget _buildApp({AuthBloc? bloc}) {
  const app = ProviderScope(
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
  return bloc == null
      ? app
      : BlocProvider<AuthBloc>.value(value: bloc, child: app);
}

/// Loads the exams into the (singleton) repository cache using real async so
/// the page's lookup resolves without asset I/O during fake-async pumping.
/// The app defaults to Kinyarwanda, so that is the language the page requests.
Future<void> _seedExamCache(WidgetTester tester) async {
  await tester.runAsync(() => ExamRepository().loadAllExams('rw'));
}

Future<void> _pumpQuiz(WidgetTester tester, Size size, {AuthBloc? bloc}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp(bloc: bloc));
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

/// Width of the quiz numbered progress section, which lives inside the width-capped
/// progress section — a good proxy for how wide the content is.
double _progressWidth(WidgetTester tester) {
  return tester.getSize(find.byKey(const ValueKey('question-progress'))).width;
}

void main() {
  testWidgets(
    'numbered progress tracks correct, incorrect and skipped answers',
    (tester) async {
      _stubChannels(tester);
      await _seedExamCache(tester);
      await _pumpQuiz(tester, const Size(400, 800));
      final exam = (await ExamRepository().getExamById(_kQuizId, 'rw'))!;
      final l10n = AppLocalizations.of(tester.element(find.byType(QuizPage)));

      Color markerColor(int index) =>
          (tester
                      .widget<Container>(
                        find.byKey(ValueKey('question-progress-$index')),
                      )
                      .decoration!
                  as BoxDecoration)
              .color!;

      Future<void> choose(String answer) async {
        final row = find.ancestor(
          of: find.text(answer),
          matching: find.byType(Row),
        );
        await tester.tap(
          find.descendant(of: row, matching: find.byType(GestureDetector)),
        );
        await tester.pump();
      }

      for (var index = 0; index < exam.questions.length; index++) {
        final marker = find.byKey(ValueKey('question-progress-$index'));
        final firstMarker = find.byKey(const ValueKey('question-progress-0'));
        expect(tester.getTopLeft(marker).dy, tester.getTopLeft(firstMarker).dy);
        expect(tester.getSize(marker).height, 24);
        expect(tester.getSize(marker).width, lessThanOrEqualTo(24));
        expect(markerColor(index), AppColors.neutral500);
        expect(
          find.descendant(
            of: find.byKey(ValueKey('question-progress-$index')),
            matching: find.text('${index + 1}'),
          ),
          findsOneWidget,
        );
      }
      expect(
        tester
            .getBottomRight(
              find.byKey(
                ValueKey('question-progress-${exam.questions.length - 1}'),
              ),
            )
            .dx,
        lessThanOrEqualTo(400),
      );

      await choose(exam.questions[0].correctAnswer);
      expect(markerColor(0), AppColors.success);
      await tester.tap(find.text(l10n.quizNext));
      await tester.pump();
      final second = exam.questions[1];
      await choose(
        [
          second.option1,
          second.option2,
          second.option3,
          second.option4,
        ].firstWhere(
          (option) => option.isNotEmpty && option != second.correctAnswer,
        ),
      );
      expect(markerColor(1), AppColors.error);
      await tester.tap(find.text(l10n.quizNext));
      await tester.pump();
      await tester.tap(find.text(l10n.quizNext));
      await tester.pump();
      expect(markerColor(2), AppColors.neutral500);
      expect(markerColor(0), AppColors.success);
      expect(markerColor(1), AppColors.error);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'exam timer finishes and saves locally without an online session',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final bloc = AuthBloc()
        ..emit(
          AuthAuthenticated(
            UserModel(
              id: 'offline-user',
              name: 'Driver',
              phoneNumber: '0788123456',
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          ),
        );
      addTearDown(bloc.close);
      _stubChannels(tester);
      await _seedExamCache(tester);
      await _pumpQuiz(tester, const Size(400, 800), bloc: bloc);
      await tester.pump(const Duration(seconds: 1202));
      await tester.pump();
      final l10n = AppLocalizations.of(tester.element(find.byType(QuizPage)));
      expect(find.text(l10n.quizResults), findsOneWidget);
      final rows = await OfflineCache().getPendingResults();
      expect(rows.single['userId'], 'offline-user');
      expect(rows.single['examId'], _kQuizId);
      expect(rows.single['totalQuestions'], greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [
    const Size(320, 640),
    const Size(844, 320),
    const Size(800, 1280),
    const Size(1280, 800),
  ]) {
    testWidgets('page fits landscape and tablet $size', (tester) async {
      _stubChannels(tester);
      await _seedExamCache(tester);
      await _pumpQuiz(tester, size);
      expect(find.byKey(const ValueKey('question-progress')), findsOneWidget);
      final progress = find.byKey(const ValueKey('question-progress'));
      expect(
        find.descendant(of: progress, matching: find.byType(Scrollable)),
        findsNothing,
      );
      final exam = (await ExamRepository().getExamById(_kQuizId, 'rw'))!;
      final first = tester.getRect(
        find.byKey(const ValueKey('question-progress-0')),
      );
      final last = tester.getRect(
        find.byKey(ValueKey('question-progress-${exam.questions.length - 1}')),
      );
      final bounds = tester.getRect(progress);
      expect(last.top, closeTo(first.top, 0.01));
      expect(first.left, greaterThanOrEqualTo(bounds.left - 0.01));
      expect(last.right, lessThanOrEqualTo(bounds.right + 0.01));
      expect(tester.takeException(), isNull);
    });
  }

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
        expect(find.byKey(const ValueKey('question-progress')), findsOneWidget);
        expect(find.byType(ConstrainedContent), findsWidgets);

        // Every ConstrainedContent on the quiz page uses the narrow preset.
        final constrained = tester
            .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
            .toList();
        expect(constrained, isNotEmpty);
        for (final c in constrained) {
          expect(c.maxWidth, AppContentWidths.narrow);
        }

        // The numbered progress section is capped at ~800px instead of stretching to the
        // full 1200px window (800 − no inner padding → ~800).
        expect(_progressWidth(tester), closeTo(AppContentWidths.narrow, 8));
      },
    );

    testWidgets('mobile width lets content fill the screen', (tester) async {
      _stubChannels(tester);
      await _seedExamCache(tester);
      await _pumpQuiz(tester, const Size(400, 800));

      expect(find.byKey(const ValueKey('question-progress')), findsOneWidget);

      // No cap below the narrow width — the section fills the (padded) window.
      expect(_progressWidth(tester), lessThanOrEqualTo(400));
      expect(_progressWidth(tester), greaterThan(300));
    });
  });
}
