import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/admin/presentation/pages/admin_progress_page.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/network/api_helper.dart';
import 'package:traffic_rule_in_rwanda/shared/responsive/responsive_layout.dart';

UserModel _adminUser() {
  final now = DateTime.now();
  return UserModel(
    id: 'a1',
    name: 'Test Admin',
    phoneNumber: '0788123456',
    role: 'ADMIN',
    createdAt: now,
    updatedAt: now,
  );
}

/// Injected results loader: returns a few exam attempts without touching the
/// network, so the page renders its capped content column.
Future<ApiResponse> _fakeResultsLoader() async {
  return const ApiResponse(
    statusCode: 200,
    data: [
      {
        'userName': 'Jean',
        'score': 95,
        'examTitle': 'Exam 1',
        'createdAt': '2026-06-01 10:00:00',
      },
      {
        'userName': 'Alice',
        'score': 88,
        'examTitle': 'Exam 2',
        'createdAt': '2026-06-02 10:00:00',
      },
      {
        'userName': 'Bob',
        'score': 72,
        'examTitle': 'Exam 3',
        'createdAt': '2026-06-03 10:00:00',
      },
    ],
    isSuccess: true,
    debugInfo: 'test-loader',
  );
}

Widget _buildApp(AuthBloc bloc) {
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: const MaterialApp(
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
      home: AdminProgressPage(resultsLoader: _fakeResultsLoader),
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
  // Let the injected loader resolve and the content render.
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
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

  group('AdminProgressPage responsive content', () {
    testWidgets('caps content width with AppContentWidths.medium on desktop', (
      tester,
    ) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_adminUser()));
      addTearDown(() => bloc.close());

      await _pumpProgress(tester, bloc, const Size(1400, 900));

      // Loaded from the injected loader — the capped content is showing.
      expect(find.text('95%'), findsOneWidget);
      expect(find.byType(ConstrainedContent), findsOneWidget);
      final constrained = tester.widget<ConstrainedContent>(
        find.byType(ConstrainedContent),
      );
      expect(constrained.maxWidth, AppContentWidths.medium);
      // Content is capped at ~1100px instead of stretching to 1400px.
      expect(_cappedWidth(tester), closeTo(AppContentWidths.medium, 8));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_adminUser()));
      addTearDown(() => bloc.close());

      await _pumpProgress(tester, bloc, const Size(400, 800));

      expect(find.byType(ConstrainedContent), findsOneWidget);
      // Below the medium cap the content fills the (padded) window.
      expect(_cappedWidth(tester), lessThanOrEqualTo(400));
      expect(_cappedWidth(tester), greaterThan(300));
    });
  });
}
