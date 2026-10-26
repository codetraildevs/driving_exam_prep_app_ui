import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/network/api_helper.dart';
import 'package:traffic_rule_in_rwanda/shared/widgets/whatsapp_groups_page.dart';

const failure = ApiResponse(
  statusCode: 0,
  data: null,
  isSuccess: false,
  errorMessage: 'Raw timeout details',
  debugInfo: 'test',
);
const groups = ApiResponse(
  statusCode: 200,
  isSuccess: true,
  debugInfo: 'test',
  data: [
    {
      'id': 'g1',
      'name': 'Study group',
      'inviteUrl': 'https://chat.whatsapp.com/TestInvite123',
    },
  ],
);

Widget app(Future<ApiResponse> Function() loader, {String language = 'en'}) =>
    MaterialApp(
      locale: Locale(language),
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('rw')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
      ],
      home: WhatsappGroupsPage(loadGroups: loader),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('saved group directory remains available without internet', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'auth_user_json': jsonEncode({
        'id': 'u1',
        'name': 'Driver',
        'phoneNumber': '0788123456',
        'role': 'USER',
        'createdAt': '2026-01-01',
        'updatedAt': '2026-01-01',
      }),
      'offline_cache_whatsapp_groups_u1': jsonEncode(groups.data),
    });
    await tester.pumpWidget(app(() async => failure));
    await tester.pumpAndSettle();
    expect(find.text('Study group'), findsOneWidget);
    final l = AppLocalizations.of(
      tester.element(find.byType(WhatsappGroupsPage)),
    );
    expect(find.text(l.waCached), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final size in [const Size(320, 640), const Size(844, 320), const Size(1200, 800)]) {
    testWidgets('group directory fits $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(app(() async => groups));
      await tester.pumpAndSettle();
      expect(find.text('Study group'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final language in ['en', 'fr', 'rw']) {
    testWidgets('failed request offers localized retry in $language', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        app(() async => ++calls == 1 ? failure : groups, language: language),
      );
      await tester.pumpAndSettle();
      expect(find.text('Raw timeout details'), findsNothing);
      expect(find.byType(OutlinedButton), findsOneWidget);
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      expect(find.text('Study group'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(calls, 2);
    });
  }

  testWidgets('refresh is single flight and preserves groups on failure', (
    tester,
  ) async {
    var calls = 0;
    final pending = Completer<ApiResponse>();
    await tester.pumpWidget(
      app(() => ++calls == 1 ? Future.value(groups) : pending.future),
    );
    await tester.pumpAndSettle();
    final refresh = find.byKey(const ValueKey('whatsapp-refresh'));
    await tester.tap(refresh);
    await tester.pump();
    expect(tester.widget<IconButton>(refresh).onPressed, isNull);
    expect(find.text('Study group'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(calls, 2);
    pending.complete(failure);
    await tester.pumpAndSettle();
    expect(find.text('Study group'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  testWidgets('leaving while loading does not update disposed state', (
    tester,
  ) async {
    final pending = Completer<ApiResponse>();
    await tester.pumpWidget(app(() => pending.future));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(groups);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
