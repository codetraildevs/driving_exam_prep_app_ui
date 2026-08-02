import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/profile/presentation/pages/my_certificates_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/network/api_helper.dart';
import 'package:traffic_rule_in_rwanda/shared/responsive/responsive_layout.dart';

/// Injected results loader: returns two passing attempts without touching
/// the network (the page's OfflineCache writes go to mocked prefs).
Future<ApiResponse> _fakeResultsLoader(String userId) async {
  return const ApiResponse(
    statusCode: 200,
    data: [
      {
        'examId': '1',
        'score': 85,
        'createdAt': '2026-06-01 10:00:00',
        'completedAt': '2026-06-01 10:00:00',
      },
      {
        'examId': '2',
        'score': 92,
        'createdAt': '2026-06-02 10:00:00',
        'completedAt': '2026-06-02 10:00:00',
      },
    ],
    isSuccess: true,
    debugInfo: 'test-loader',
  );
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/certificates',
    routes: [
      GoRoute(
        path: '/certificates',
        builder: (_, __) =>
            const MyCertificatesPage(resultsLoader: _fakeResultsLoader),
      ),
    ],
  );
}

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

Widget _buildApp(AuthBloc bloc) {
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: MaterialApp.router(
      routerConfig: _buildRouter(),
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

Future<void> _pumpCertificates(WidgetTester tester, AuthBloc bloc, Size size) async {
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

/// Width of the progress card — the widest element inside the capped column.
double _progressCardWidth(WidgetTester tester) {
  final l10n = AppLocalizations.of(
    tester.element(find.byType(MyCertificatesPage)),
  );
  final card = find
      .ancestor(
        of: find.text(l10n.certificatesAchievements),
        matching: find.byType(Container),
      )
      .first;
  return tester.getSize(card).width;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MyCertificatesPage responsive content', () {
    testWidgets(
      'desktop width caps content at AppContentWidths.medium',
      (tester) async {
        final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
        addTearDown(() => bloc.close());

        await _pumpCertificates(tester, bloc, const Size(1200, 800));

        // Loaded from the injected loader — the capped content is showing.
        expect(find.byType(ConstrainedContent), findsOneWidget);
        expect(find.text('85%'), findsOneWidget);

        final constrained = tester.widget<ConstrainedContent>(
          find.byType(ConstrainedContent),
        );
        expect(constrained.maxWidth, AppContentWidths.medium);

        // Progress card is capped at ~1100px instead of the full 1200px window.
        expect(
          _progressCardWidth(tester),
          closeTo(AppContentWidths.medium, 8),
        );
      },
    );

    testWidgets('mobile width lets content fill the screen', (tester) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
      addTearDown(() => bloc.close());

      await _pumpCertificates(tester, bloc, const Size(400, 800));

      expect(find.byType(ConstrainedContent), findsOneWidget);

      // No cap below the medium width — the card fills the (padded) window.
      expect(_progressCardWidth(tester), lessThanOrEqualTo(400));
      expect(_progressCardWidth(tester), greaterThan(300));
    });
  });
}
