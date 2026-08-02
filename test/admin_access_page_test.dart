import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/admin/presentation/pages/admin_access_page.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
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

/// Minimal router so `GoRouter.of(context)` used by the tabs' loaders works.
GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/admin/access',
    routes: [
      GoRoute(
        path: '/admin/access',
        builder: (_, __) => const AdminAccessPage(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login'))),
    ],
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

Future<void> _pumpAccess(WidgetTester tester, AuthBloc bloc, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp(bloc));
  // Let both tabs' initState loaders settle.
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AdminAccessPage responsive content', () {
    testWidgets('caps content width with AppContentWidths.wide on desktop', (
      tester,
    ) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_adminUser()));
      addTearDown(() => bloc.close());

      await _pumpAccess(tester, bloc, const Size(1200, 800));

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
