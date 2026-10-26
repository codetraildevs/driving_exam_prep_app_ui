import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/profile/presentation/pages/profile_page.dart';
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

Widget _buildApp(AuthBloc bloc, {String language = 'en', double scale = 1}) {
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: ProviderScope(
      child: MaterialApp(
        locale: Locale(language),
        builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
        supportedLocales: LocaleNotifier.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FallbackMaterialLocalizationsDelegate(),
          FallbackCupertinoLocalizationsDelegate(),
        ],
        home: ProfilePage(),
      ),
    ),
  );
}

Future<void> _pumpProfile(WidgetTester tester, AuthBloc bloc, Size size, {String language = 'en', double scale = 1}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp(bloc, language: language, scale: scale));
  // Let the auth rebuild + async progress load settle.
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// The content column is wrapped in a `Container` whose `BoxConstraints`
/// carry the computed max-content width — this is what caps the profile
/// content on desktop instead of ConstrainedContent. Scoped to the scroll
/// body because the gradient header's `width: double.infinity` also produces
/// a `BoxConstraints` with `maxWidth: infinity`.
Finder _contentContainer(double expectedMaxWidth) {
  return find.descendant(
    of: find.byType(SingleChildScrollView),
    matching: find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.constraints is BoxConstraints &&
          (w.constraints as BoxConstraints).maxWidth == expectedMaxWidth,
    ),
  );
}

void main() {
  for (final size in [const Size(844, 320), const Size(800, 1280), const Size(1280, 800)]) {
    for (final language in ['rw', 'en', 'fr']) {
      testWidgets('profile remains scrollable at $size in $language', (tester) async {
        final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
        addTearDown(() => bloc.close());
        await _pumpProfile(tester, bloc, size, language: language, scale: 1.6);
        expect(tester.takeException(), isNull);
        final l10n = AppLocalizations.of(tester.element(find.byType(ProfilePage)));
        final signOut = find.text(l10n.profileSignOut);
        await tester.ensureVisible(signOut);
        await tester.pumpAndSettle();
        expect(signOut.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        // Scrolling to the last action must move the large header out of the way.
        if (size.height <= 400) expect(find.text('Test Driver').hitTestable(), findsNothing);
      });
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfilePage responsive content', () {
    testWidgets('desktop width caps content at AppContentWidths.compact', (
      tester,
    ) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
      addTearDown(() => bloc.close());

      await _pumpProfile(tester, bloc, const Size(1200, 800));

      final finder = _contentContainer(AppContentWidths.compact);
      expect(finder, findsOneWidget);
      // The container itself is capped at ~720px (not the full 1200px).
      expect(
        tester.getSize(finder).width,
        closeTo(AppContentWidths.compact, 1),
      );
    });

    testWidgets('tablet width caps content at AppContentWidths.tablet', (
      tester,
    ) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
      addTearDown(() => bloc.close());

      await _pumpProfile(tester, bloc, const Size(800, 800));

      final finder = _contentContainer(AppContentWidths.tablet);
      expect(finder, findsOneWidget);
      expect(tester.getSize(finder).width, closeTo(AppContentWidths.tablet, 1));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_user()));
      addTearDown(() => bloc.close());

      await _pumpProfile(tester, bloc, const Size(400, 800));

      // Below the tablet breakpoint the width is unconstrained (infinity).
      final finder = _contentContainer(double.infinity);
      expect(finder, findsOneWidget);
      expect(tester.getSize(finder).width, lessThanOrEqualTo(400));
      expect(tester.getSize(finder).width, greaterThan(300));
    });
  });
}
