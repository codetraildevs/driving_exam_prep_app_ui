import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/progress/presentation/pages/progress_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/responsive/responsive_layout.dart';

UserModel _user() {
  final now = DateTime.now();
  return UserModel(
    id: 'u1',
    name: 'Test Driver',
    phoneNumber: '0788123456',
    role: 'USER',
    createdAt: now,
    updatedAt: now,
  );
}

/// Seed the offline cache with exam results. In widget tests the API call
/// fails (mock HTTP returns 400), so the page falls back to this cache and
/// renders its capped content column.
Future<void> _seedOfflineCache() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    'offline_cache_exam_results_u1',
    jsonEncode([
      {
        'score': 95,
        'passed': true,
        'totalQuestions': 30,
        'correctAnswers': 29,
        'completedAt': '2026-06-01 10:00:00',
      },
      {
        'score': 72,
        'passed': true,
        'totalQuestions': 30,
        'correctAnswers': 22,
        'completedAt': '2026-06-02 10:00:00',
      },
    ]),
  );
}

Widget _buildApp(AuthBloc bloc) {
  final router = GoRouter(
    initialLocation: '/progress',
    routes: [
      GoRoute(path: '/progress', builder: (_, __) => const ProgressPage()),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login'))),
      GoRoute(path: '/practice', builder: (_, __) => const Scaffold(body: Text('Practice'))),
    ],
  );

  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      supportedLocales: LocaleNotifier.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
      ],
    ),
  );
}

Future<void> _pumpProgress(
  WidgetTester tester,
  AuthBloc bloc,
  Size size,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp(bloc));
  // Let the failing API call resolve and the cache fallback render.
  for (int i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Width of the capped content column, measured directly.
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProgressPage responsive content', () {
    testWidgets('desktop width caps content at AppContentWidths.wide', (
      tester,
    ) async {
      await _seedOfflineCache();

      final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
      addTearDown(() => bloc.close());

      await _pumpProgress(tester, bloc, const Size(1400, 900));

      // Loaded from the seeded cache — the capped content column is showing.
      // (95% appears in both the summary stat card and the result card.)
      expect(find.textContaining('95%'), findsWidgets);
      expect(find.byType(ConstrainedContent), findsOneWidget);

      final constrained = tester
          .widget<ConstrainedContent>(find.byType(ConstrainedContent));
      expect(constrained.maxWidth, AppContentWidths.wide);
      // Content is capped at ~1200px instead of stretching to 1400px.
      expect(_cappedWidth(tester), closeTo(AppContentWidths.wide, 8));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      await _seedOfflineCache();

      final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
      addTearDown(() => bloc.close());

      await _pumpProgress(tester, bloc, const Size(400, 800));

      expect(find.byType(ConstrainedContent), findsOneWidget);
      // Below the wide cap the content fills the (padded) window.
      expect(_cappedWidth(tester), lessThanOrEqualTo(400));
      expect(_cappedWidth(tester), greaterThan(300));
    });
  });
}
