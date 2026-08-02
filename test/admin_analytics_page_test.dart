import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/admin/presentation/pages/admin_analytics_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/network/api_helper.dart';
import 'package:traffic_rule_in_rwanda/shared/responsive/responsive_layout.dart';

/// Injected analytics loader: returns a couple of days of stats without
/// touching the network, so the page renders its capped content column.
Future<ApiResponse> _fakeAnalyticsLoader() async {
  return const ApiResponse(
    statusCode: 200,
    data: {
      'analytics': {
        'totalExams': 42,
        'uniqueUsers': 15,
        'dailyStats': [
          {'date': '2026-06-01', 'count': 5},
          {'date': '2026-06-02', 'count': 8},
        ],
      },
    },
    isSuccess: true,
    debugInfo: 'test-loader',
  );
}

Widget _buildApp() {
  return const MaterialApp(
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
    home: AdminAnalyticsPage(analyticsLoader: _fakeAnalyticsLoader),
  );
}

Future<void> _pumpAnalytics(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(_buildApp());
  // Let the post-frame loader resolve and the content render.
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

  group('AdminAnalyticsPage responsive content', () {
    testWidgets('caps content width with AppContentWidths.wide on desktop', (
      tester,
    ) async {
      await _pumpAnalytics(tester, const Size(1400, 900));

      // Loaded from the injected loader — the capped content is showing.
      expect(find.text('42'), findsOneWidget);
      expect(find.byType(ConstrainedContent), findsOneWidget);
      final constrained = tester.widget<ConstrainedContent>(
        find.byType(ConstrainedContent),
      );
      expect(constrained.maxWidth, AppContentWidths.wide);
      // Content is capped at ~1200px instead of stretching to 1400px.
      expect(_cappedWidth(tester), closeTo(AppContentWidths.wide, 8));
    });

    testWidgets('mobile width lets content fill the screen', (tester) async {
      await _pumpAnalytics(tester, const Size(400, 800));

      expect(find.byType(ConstrainedContent), findsOneWidget);
      // Below the wide cap the content fills the (padded) window.
      expect(_cappedWidth(tester), lessThanOrEqualTo(400));
      expect(_cappedWidth(tester), greaterThan(300));
    });
  });
}
