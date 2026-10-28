import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/home/presentation/pages/main_layout.dart';
import 'package:traffic_rule_in_rwanda/features/resources/presentation/pages/resources_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';

/// Placeholder page used for the shell's child routes — real pages would pull
/// in network/riverpod dependencies that are irrelevant to shell behavior.
class _StubPage extends StatelessWidget {
  final String label;

  const _StubPage(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label));
  }
}

/// Routes every shell destination so MainLayout's GoRouterState lookups and
/// context.go() navigation work exactly like the production router.
GoRouter _buildRouter() {
  final shellNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) =>
            MainLayout(navigatorKey: shellNavigatorKey, child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const _StubPage('HOME', key: Key('page-home')),
          ),
          GoRoute(
            path: '/practice',
            builder: (_, __) =>
                const _StubPage('PRACTICE', key: Key('page-practice')),
          ),
          GoRoute(
            path: '/progress',
            builder: (_, __) =>
                const _StubPage('PROGRESS', key: Key('page-progress')),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) =>
                const _StubPage('PROFILE', key: Key('page-profile')),
          ),
          GoRoute(
            path: '/admin',
            builder: (_, __) =>
                const _StubPage('ADMIN', key: Key('page-admin')),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (_, __) =>
                const _StubPage('ADMIN-USERS', key: Key('page-admin-users')),
          ),
          GoRoute(
            path: '/admin/access',
            builder: (_, __) =>
                const _StubPage('ADMIN-ACCESS', key: Key('page-admin-access')),
          ),
          GoRoute(
            path: '/admin/analytics',
            builder: (_, __) => const _StubPage(
              'ADMIN-ANALYTICS',
              key: Key('page-admin-analytics'),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Builds the full app shell: AuthBloc above a GoRouter-driven MaterialApp
/// with the same localization setup the real app uses.
Widget _buildApp({required AuthBloc bloc, required GoRouter router}) {
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

/// Pumps the shell at [size] (logical pixels) and lets it settle.
Future<void> _pumpShell(WidgetTester tester, AuthBloc bloc, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp(bloc: bloc, router: _buildRouter()));
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Opens the shell's slide-out drawer and settles the animation.
Future<void> _openDrawer(WidgetTester tester) async {
  tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
  await tester.pumpAndSettle();
}

/// Number of navigation tiles inside the (open) drawer.
int _drawerTileCount(WidgetTester tester) {
  return find
      .descendant(of: find.byType(Drawer), matching: find.byType(ListTile))
      .evaluate()
      .length;
}

UserModel _user({String role = 'USER'}) {
  final now = DateTime.now();
  return UserModel(
    id: 'u1',
    name: 'Test Driver',
    phoneNumber: '0788123456',
    role: role,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  setUp(() {
    // AuthBloc's repository touches SharedPreferences during construction,
    // so mock it like the other auth tests in this repo.
    SharedPreferences.setMockInitialValues({});
  });

  group('MainLayout responsive shell', () {
    testWidgets(
      'system back returns from nested reader to resources then home',
      (tester) async {
        final bloc = AuthBloc();
        addTearDown(bloc.close);
        await _pumpShell(tester, bloc, const Size(400, 800));
        final navigator = tester
            .widget<MainLayout>(find.byType(MainLayout))
            .navigatorKey
            .currentState!;
        navigator.push(
          MaterialPageRoute<void>(builder: (_) => const ResourcesPage()),
        );
        await tester.pumpAndSettle();
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const _StubPage('ROAD SIGNS'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('ROAD SIGNS'), findsNothing);
        expect(find.byType(ResourcesPage), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('page-home')), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    for (final role in ['USER', 'ADMIN', 'MANAGER']) {
      for (final destination in [0, 1, 2, 3]) {
        testWidgets('$role bottom tab $destination dismisses pushed pages', (
          tester,
        ) async {
          final bloc = AuthBloc()..emit(AuthAuthenticated(_user(role: role)));
          addTearDown(bloc.close);
          await _pumpShell(tester, bloc, const Size(400, 800));
          final layout = tester.widget<MainLayout>(find.byType(MainLayout));
          final navigator = layout.navigatorKey.currentState!;
          navigator.push(
            MaterialPageRoute<void>(builder: (_) => const ResourcesPage()),
          );
          await tester.pumpAndSettle();
          expect(find.byType(ResourcesPage), findsOneWidget);
          // Also cover a second pushed screen, such as a document reader.
          if (destination != 0) {
            navigator.push(
              MaterialPageRoute<void>(
                builder: (_) => const _StubPage('DOCUMENT'),
              ),
            );
            await tester.pumpAndSettle();
          }
          final bar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          final label = bar.items[destination].label!;
          await tester.tap(
            find.descendant(
              of: find.byType(BottomNavigationBar),
              matching: find.text(label),
            ),
          );
          await tester.pumpAndSettle();
          final pages = role == 'USER'
              ? ['home', 'practice', 'progress', 'profile']
              : ['admin', 'admin-users', 'admin-access', 'admin-analytics'];
          expect(find.byKey(Key('page-${pages[destination]}')), findsOneWidget);
          expect(find.byType(ResourcesPage), findsNothing);
          expect(find.text('DOCUMENT'), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('desktop shows slide-out drawer, no rail or bottom bar', (
      tester,
    ) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await _pumpShell(tester, bloc, const Size(1200, 800));

      // No persistent sidebar or bottom bar on desktop.
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);

      // The drawer only enters the tree once opened.
      expect(find.byType(Drawer), findsNothing);

      await _openDrawer(tester);
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('shows BottomNavigationBar on mobile width, no drawer', (
      tester,
    ) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await _pumpShell(tester, bloc, const Size(400, 800));

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets(
      'breakpoint: 900 uses drawer, shrinking below shows bottom bar',
      (tester) async {
        final bloc = AuthBloc();
        addTearDown(() => bloc.close());

        await _pumpShell(tester, bloc, const Size(900, 800));
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(BottomNavigationBar), findsNothing);

        await _openDrawer(tester);
        expect(find.byType(Drawer), findsOneWidget);

        // Close the drawer, then shrink just below the desktop breakpoint and
        // confirm the shell switches to the mobile bottom bar live.
        Navigator.of(tester.element(find.byType(Drawer))).pop();
        await tester.pumpAndSettle();

        tester.view.physicalSize = const Size(899, 800);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.byType(Drawer), findsNothing);
      },
    );

    testWidgets('desktop drawer has 4 destinations for a regular user', (
      tester,
    ) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await _pumpShell(tester, bloc, const Size(1200, 800));
      await _openDrawer(tester);

      expect(_drawerTileCount(tester), 4);
    });

    testWidgets('desktop drawer has 5 destinations for an admin', (
      tester,
    ) async {
      final bloc = AuthBloc()..emit(AuthAuthenticated(_user(role: 'ADMIN')));
      addTearDown(() => bloc.close());

      await _pumpShell(tester, bloc, const Size(1200, 800));
      await _openDrawer(tester);

      expect(_drawerTileCount(tester), 5);
    });

    testWidgets(
      'tapping a drawer destination navigates and closes the drawer',
      (tester) async {
        final bloc = AuthBloc();
        addTearDown(() => bloc.close());

        await _pumpShell(tester, bloc, const Size(1200, 800));

        // Home is shown first.
        expect(find.byKey(const Key('page-home')), findsOneWidget);

        final l10n = AppLocalizations.of(
          tester.element(find.byType(MainLayout)),
        );

        await _openDrawer(tester);
        await tester.tap(find.text(l10n.navPractice));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('page-practice')), findsOneWidget);
        expect(find.byKey(const Key('page-home')), findsNothing);
        // The drawer closes itself after navigating.
        expect(find.byType(Drawer), findsNothing);
      },
    );

    testWidgets('tapping a mobile bottom-bar destination navigates', (
      tester,
    ) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await _pumpShell(tester, bloc, const Size(400, 800));

      final l10n = AppLocalizations.of(tester.element(find.byType(MainLayout)));
      await tester.tap(find.text(l10n.navProgress));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-progress')), findsOneWidget);
    });
  });
}
