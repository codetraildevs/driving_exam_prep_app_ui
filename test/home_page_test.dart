import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/home/presentation/pages/home_page.dart';
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

Widget _buildApp(AuthBloc bloc) {
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: const ProviderScope(
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
        home: HomePage(),
      ),
    ),
  );
}

Future<void> _pumpHome(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
  addTearDown(() => bloc.close());

  await tester.pumpWidget(_buildApp(bloc));
  // Let the subscription prefs load and the staggered card entrance
  // animations (up to 80ms * index + 400ms) settle.
  for (int i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Width of the services grid, which stretches to the capped content width —
/// a good proxy for how wide the home content is.
double _gridWidth(WidgetTester tester) {
  return tester.getSize(find.byType(GridView)).width;
}

/// Number of service card columns the responsive grid is configured with.
int _gridColumns(WidgetTester tester) {
  final grid = tester.widget<GridView>(find.byType(GridView));
  final delegate =
      grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
  return delegate.crossAxisCount;
}

void main() {
  setUp(() {
    // SubscriptionNotifier + AuthBloc touch SharedPreferences asynchronously.
    SharedPreferences.setMockInitialValues({});
  });

  group('HomePage responsive content', () {
    testWidgets(
      'desktop width caps content at AppContentWidths.wide and centers it',
      (tester) async {
        await _pumpHome(tester, const Size(1400, 900));

        // The single ConstrainedContent on the home page uses the wide preset.
        expect(find.byType(ConstrainedContent), findsOneWidget);
        final constrained = tester
            .widget<ConstrainedContent>(find.byType(ConstrainedContent));
        expect(constrained.maxWidth, AppContentWidths.wide);

        // The services grid is capped at ~1200px instead of stretching to the
        // full 1400px window.
        expect(_gridWidth(tester), closeTo(AppContentWidths.wide, 8));

        // Wide screens show all four services in a single row.
        expect(_gridColumns(tester), 4);
      },
    );

    testWidgets('mobile width lets content fill the screen', (tester) async {
      await _pumpHome(tester, const Size(400, 800));

      // No cap below the wide width — the grid fills the padded window
      // (16px padding each side).
      expect(_gridWidth(tester), lessThanOrEqualTo(400));
      expect(_gridWidth(tester), greaterThan(300));

      // Phones use two columns.
      expect(_gridColumns(tester), 2);
    });
  });
}
