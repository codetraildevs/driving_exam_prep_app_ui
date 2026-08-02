import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/signs/data/models/sign_model.dart';
import 'package:traffic_rule_in_rwanda/features/signs/data/repositories/signs_repository.dart';
import 'package:traffic_rule_in_rwanda/features/signs/presentation/pages/signs_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/responsive/responsive_layout.dart';

/// Deterministic repository so the grid renders without network calls.
class _FakeSignsRepository extends SignsRepository {
  final List<TrafficSignModel> signs;

  _FakeSignsRepository(this.signs);

  @override
  Future<List<TrafficSignModel>> getTrafficSigns({
    String? category,
    String? searchQuery,
  }) async {
    return signs;
  }

  @override
  Future<List<String>> getCategories() async {
    return <String>['Warning', 'Prohibition'];
  }

  @override
  Future<bool> isSignLearned(String userId, String signId) async => false;
}

List<TrafficSignModel> _sampleSigns(int count) {
  return List.generate(
    count,
    (i) => TrafficSignModel(
      id: 'sign-$i',
      title: 'Sign $i',
      description: 'A test road sign',
      category: 'Warning',
    ),
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

/// Number of columns configured on the signs grid.
int _gridColumns(WidgetTester tester) {
  final grid = tester.widget<GridView>(find.byType(GridView));
  final delegate =
      grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
  return delegate.crossAxisCount;
}

Widget _buildApp(AuthBloc bloc, SignsRepository repo) {
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: MaterialApp(
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
      home: SignsPage(repository: repo),
    ),
  );
}

Future<void> _pumpSigns(WidgetTester tester, AuthBloc bloc, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final repo = _FakeSignsRepository(_sampleSigns(8));
  await tester.pumpWidget(_buildApp(bloc, repo));
  // Let the two async loads (categories + signs) settle.
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SignsPage responsive grid', () {
    testWidgets('shows 4 columns on desktop width', (tester) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
      addTearDown(() => bloc.close());

      await _pumpSigns(tester, bloc, const Size(1200, 800));

      expect(find.byType(GridView), findsOneWidget);
      expect(_gridColumns(tester), 4);
    });

    testWidgets('shows 3 columns at tablet width', (tester) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
      addTearDown(() => bloc.close());

      await _pumpSigns(tester, bloc, const Size(800, 800));

      expect(_gridColumns(tester), 3);
    });

    testWidgets('shows 2 columns on mobile width', (tester) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
      addTearDown(() => bloc.close());

      await _pumpSigns(tester, bloc, const Size(400, 800));

      expect(_gridColumns(tester), 2);
    });

    testWidgets('caps content width with AppContentWidths.wide on desktop', (
      tester,
    ) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
      addTearDown(() => bloc.close());

      await _pumpSigns(tester, bloc, const Size(1200, 800));

      final constrained = tester
          .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
          .toList();
      expect(constrained, isNotEmpty);
      for (final c in constrained) {
        expect(c.maxWidth, AppContentWidths.wide);
      }
    });
  });
}
