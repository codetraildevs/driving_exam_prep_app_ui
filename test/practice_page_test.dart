import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/exam/data/repositories/exam_repository.dart';
import 'package:traffic_rule_in_rwanda/features/practice/presentation/pages/practice_page.dart';
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
      home: PracticePage(),
    ),
  );
}

/// Loads the exams into the (singleton) repository cache using real async so
/// the page's loadAllExams resolves without asset I/O during fake-async pumps.
Future<void> _seedExamCache(WidgetTester tester) async {
  await tester.runAsync(() => ExamRepository().loadAllExams('en'));
}

Future<void> _pumpPractice(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp());
  // Let the post-frame exam load and the grid render.
  for (int i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Number of columns configured on the practice grid.
int _gridColumns(WidgetTester tester) {
  final grid = tester.widget<GridView>(find.byType(GridView));
  final delegate =
      grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
  return delegate.crossAxisCount;
}

/// Width of the practice grid, which stretches inside the capped column.
double _gridWidth(WidgetTester tester) {
  return tester.getSize(find.byType(GridView)).width;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ExamRepository().clearCache();
  });

  group('PracticePage responsive grid', () {
    testWidgets('shows 3 columns on desktop width', (tester) async {
      await _seedExamCache(tester);
      await _pumpPractice(tester, const Size(1200, 800));

      expect(find.byType(GridView), findsOneWidget);
      expect(_gridColumns(tester), 3);
    });

    testWidgets('shows 2 columns at tablet width', (tester) async {
      await _seedExamCache(tester);
      await _pumpPractice(tester, const Size(800, 800));

      expect(_gridColumns(tester), 2);
    });

    testWidgets('shows 1 column on mobile width', (tester) async {
      await _seedExamCache(tester);
      await _pumpPractice(tester, const Size(400, 800));

      expect(_gridColumns(tester), 1);
    });
  });

  group('PracticePage responsive content', () {
    testWidgets('desktop width caps content at AppContentWidths.wide', (
      tester,
    ) async {
      await _seedExamCache(tester);
      await _pumpPractice(tester, const Size(1400, 900));

      expect(find.byType(GridView), findsOneWidget);
      final constrained = tester
          .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
          .toList();
      expect(constrained, isNotEmpty);
      for (final c in constrained) {
        expect(c.maxWidth, AppContentWidths.wide);
      }

      // The grid is capped at ~1200px instead of stretching to 1400px.
      expect(_gridWidth(tester), closeTo(AppContentWidths.wide, 8));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      await _seedExamCache(tester);
      await _pumpPractice(tester, const Size(400, 800));

      // No cap below the wide width — the grid fills the padded window.
      expect(_gridWidth(tester), lessThanOrEqualTo(400));
      expect(_gridWidth(tester), greaterThan(300));
    });
  });
}
