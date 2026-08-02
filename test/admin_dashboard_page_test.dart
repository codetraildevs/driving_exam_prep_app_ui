import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/admin/presentation/pages/admin_dashboard_page.dart';
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

/// Seeds the dashboard's SharedPreferences cache so the content view renders
/// even though the network request is unavailable inside the widget-test
/// sandbox (the cache is read before the API call).
void _seedDashboardCache() {
  SharedPreferences.setMockInitialValues({
    'admin_dashboard_cache': json.encode({
      'stats': {
        'totalUsers': 12,
        'totalPractices': 34,
        'activeSubscriptions': 8,
        'usersByLanguage': {'rw': 5, 'en': 4, 'fr': 3},
      },
      'ts': DateTime.now().toIso8601String(),
    }),
  });
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
      home: AdminDashboardPage(),
    ),
  );
}

Future<void> _pumpDashboard(
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
  // Let the post-frame _loadData run: cache read + failed API + fade-in.
  for (int i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Width of the capped content column (the ConstrainedBox ConstrainedContent
/// creates), measured directly — a good proxy for how wide the content is.
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
  group('AdminDashboardPage responsive content', () {
    testWidgets('desktop width caps content at AppContentWidths.wide', (
      tester,
    ) async {
      _seedDashboardCache();
      final bloc = AuthBloc()..emit(AuthAuthenticated(_adminUser()));
      addTearDown(() => bloc.close());

      await _pumpDashboard(tester, bloc, const Size(1400, 900));

      expect(find.byType(ConstrainedContent), findsOneWidget);
      final constrained = tester.widget<ConstrainedContent>(
        find.byType(ConstrainedContent),
      );
      expect(constrained.maxWidth, AppContentWidths.wide);
      // Content is capped at ~1200px instead of stretching to the 1400px window.
      expect(_cappedWidth(tester), closeTo(AppContentWidths.wide, 8));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      _seedDashboardCache();
      final bloc = AuthBloc()..emit(AuthAuthenticated(_adminUser()));
      addTearDown(() => bloc.close());

      await _pumpDashboard(tester, bloc, const Size(400, 800));

      expect(find.byType(ConstrainedContent), findsOneWidget);
      // Below the wide cap the content fills the (padded) window.
      expect(_cappedWidth(tester), lessThanOrEqualTo(400));
      expect(_cappedWidth(tester), greaterThan(300));
    });
  });
}
