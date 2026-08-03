import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/signs/data/models/sign_model.dart';
import 'package:traffic_rule_in_rwanda/features/signs/data/repositories/signs_repository.dart';
import 'package:traffic_rule_in_rwanda/features/signs/presentation/pages/sign_detail_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/responsive/responsive_layout.dart';

/// Deterministic repository so the detail page renders without network calls.
class _FakeSignsRepository extends SignsRepository {
  @override
  Future<TrafficSignModel?> getSignById(String signId) async {
    return TrafficSignModel(
      id: signId,
      title: 'Stop',
      description: 'A test sign description',
      category: 'Prohibition',
      scenario: 'Stop completely at the line.',
    );
  }

  @override
  Future<bool> isSignLearned(String userId, String signId) async => false;
}

Widget _buildApp(AuthBloc bloc) {
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
      home: SignDetailPage(
        signId: 'sign-1',
        repository: _FakeSignsRepository(),
      ),
    ),
  );
}

Future<void> _pumpDetail(WidgetTester tester, AuthBloc bloc, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp(bloc));
  // Let the injected sign future resolve and the content render.
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

  group('SignDetailPage responsive content', () {
    testWidgets('desktop width caps content at AppContentWidths.narrow', (
      tester,
    ) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await _pumpDetail(tester, bloc, const Size(1200, 800));

      // The sign content loaded from the injected repository.
      expect(find.text('Stop'), findsOneWidget);

      final constrained = tester
          .widgetList<ConstrainedContent>(find.byType(ConstrainedContent))
          .toList();
      expect(constrained, isNotEmpty);
      for (final c in constrained) {
        expect(c.maxWidth, AppContentWidths.narrow);
      }

      // Content is capped at ~800px instead of stretching to 1200px.
      expect(_cappedWidth(tester), closeTo(AppContentWidths.narrow, 8));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await _pumpDetail(tester, bloc, const Size(400, 800));

      // Below the narrow cap the content fills the (padded) window.
      expect(_cappedWidth(tester), lessThanOrEqualTo(400));
      expect(_cappedWidth(tester), greaterThan(300));
    });
  });
}
