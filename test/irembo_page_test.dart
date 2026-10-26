import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/irembo/data/irembo_repository.dart';
import 'package:traffic_rule_in_rwanda/features/irembo/presentation/irembo_page.dart';
import 'package:traffic_rule_in_rwanda/features/irembo/presentation/irembo_form_page.dart';
import 'package:traffic_rule_in_rwanda/features/irembo/presentation/irembo_request_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';

class FakeIrembo extends IremboRepository {
  final submissions = <Map<String, dynamic>>[];
  bool failOnce = false;
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    submissions.add(Map.from(data));
    if (failOnce) {
      failOnce = false;
      throw const IremboFailure('network');
    }
    return {...record, ...data};
  }

  Map<String, dynamic> record = {
    'id': 'r1',
    'reference': 'IR-EXAMPLE',
    'fullName': 'Driver',
    'phoneNumber': '0788123456',
    'nationalId': '0123456789012345',
    'dob': '1990-01-01',
    'service': 'Provisoire',
    'examLanguage': 'rw',
    'district': 'Gasabo',
    'status': 'Pending',
    'version': 1,
    'createdAt': '2026-10-01',
    'messages': <dynamic>[],
    'audit': <dynamic>[],
  };
  @override
  Future<Map<String, dynamic>> list(Map<String, String> filters) async => {
    'items': [record],
    'total': 1,
    'page': 1,
  };
  @override
  Future<List<Map<String, dynamic>>> staff() async => [
    {'id': 'staff1', 'name': 'Staff', 'role': 'MANAGER'},
  ];
  @override
  Future<Map<String, dynamic>> get(String id) async => record;
}

Future<AuthBloc> app(
  WidgetTester tester,
  Widget page, {
  String lang = 'en',
  String role = 'USER',
  Size size = const Size(390, 780),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  SharedPreferences.setMockInitialValues({});
  final bloc = AuthBloc()
    ..emit(
      AuthAuthenticated(
        UserModel(
          id: 'u1',
          name: 'Driver',
          phoneNumber: '0788123456',
          role: role,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ),
    );
  addTearDown(bloc.close);
  await tester.pumpWidget(
    BlocProvider<AuthBloc>.value(
      value: bloc,
      child: MaterialApp(
        locale: Locale(lang),
        supportedLocales: const [Locale('en'), Locale('fr'), Locale('rw')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FallbackMaterialLocalizationsDelegate(),
          FallbackCupertinoLocalizationsDelegate(),
        ],
        home: page,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return bloc;
}

void main() {
  for (final lang in ['en', 'fr', 'rw']) {
    testWidgets('localized Irembo service selection $lang', (tester) async {
      await app(tester, IremboPage(repository: FakeIrembo()), lang: lang);
      expect(find.text('Provisoire'), findsOneWidget);
      await tester.tap(find.text('Permis'));
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(tester.element(find.byType(IremboPage)));
      expect(find.text(l.irManual), findsOneWidget);
      expect(find.text(l.irAutomatic), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final selection in [
    ('Provisoire', null),
    ('Permis', 'Manual'),
    ('Permis', 'Automatic'),
  ]) {
    testWidgets('registration fields match $selection', (tester) async {
      await app(
        tester,
        IremboFormPage(
          service: selection.$1,
          permisOption: selection.$2,
          repository: FakeIrembo(),
        ),
      );
      expect(
        find.byKey(const ValueKey('irembo-provisoireCode')),
        selection.$1 == 'Permis' ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(RadioListTile<String>),
        selection.$2 == 'Manual' ? findsNWidgets(3) : findsNothing,
      );
      expect(find.widgetWithText(TextFormField, 'Driver'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final size in [const Size(844, 320), const Size(1200, 800)]) {
    testWidgets('staff table and filters fit $size', (tester) async {
      await app(
        tester,
        IremboPage(manage: true, repository: FakeIrembo()),
        role: 'MANAGER',
        size: size,
      );
      final l = AppLocalizations.of(tester.element(find.byType(IremboPage)));
      await tester.tap(find.text(l.irFilters));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('staff copies full applicant fields with leading zeros', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') copied = call.arguments['text'];
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await app(
      tester,
      IremboRequestPage(id: 'r1', manage: true, repository: FakeIrembo()),
      role: 'MANAGER',
    );
    final l = AppLocalizations.of(
      tester.element(find.byType(IremboRequestPage)),
    );
    await tester.ensureVisible(find.text(l.irCopyAll));
    await tester.tap(find.text(l.irCopyAll));
    await tester.pump();
    expect(copied, contains('0123456789012345'));
    expect(copied, contains('0788123456'));
    expect(copied, contains('1990-01-01'));
    expect(copied, isNot(contains(l.irProvisoireCode)));
  });
  testWidgets('applicant detail has no copy or management controls', (
    tester,
  ) async {
    await app(tester, IremboRequestPage(id: 'r1', repository: FakeIrembo()));
    final l = AppLocalizations.of(
      tester.element(find.byType(IremboRequestPage)),
    );
    expect(find.text(l.irCopyAll), findsNothing);
    expect(find.text(l.irSave), findsNothing);
    expect(find.text(l.irInternalNotes), findsNothing);
  });
  testWidgets(
    'review retains details and reuses the same key after a failed submission',
    (tester) async {
      final repo = FakeIrembo()..failOnce = true;
      await app(
        tester,
        IremboFormPage(service: 'Provisoire', repository: repo),
      );
      final l = AppLocalizations.of(
        tester.element(find.byType(IremboFormPage)),
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('irembo-nationalId')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('irembo-nationalId')),
        '0123456789012345',
      );
      tester
              .widget<TextFormField>(find.byKey(const ValueKey('irembo-dob')))
              .controller!
              .text =
          '1990-01-01';
      final language = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(language);
      await tester.tap(language);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.irKinyarwanda).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(l.irSelectDistrict));
      await tester.tap(find.text(l.irSelectDistrict));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gasabo'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(l.irReview));
      await tester.tap(find.text(l.irReview));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(l.irConfirm));
      await tester.tap(find.text(l.irConfirm));
      await tester.pumpAndSettle();
      expect(find.text(l.irUnavailable), findsOneWidget);
      expect(find.text('0123456789012345'), findsOneWidget);
      await tester.ensureVisible(find.text(l.irConfirm));
      await tester.tap(find.text(l.irConfirm));
      await tester.pumpAndSettle();
      expect(repo.submissions.length, 2);
      expect(repo.submissions[0], repo.submissions[1]);
      expect(repo.submissions.first.containsKey('provisoireCode'), isFalse);
      expect(find.text(l.irSaved), findsOneWidget);
    },
  );
  testWidgets(
    'staff dialer uses the submitted phone and copy failures are visible',
    (tester) async {
      String? launched;
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        if (call.method == 'launch') {
          launched = call.arguments['url'];
          return true;
        }
        return null;
      });
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData')
            throw PlatformException(code: 'clipboard');
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        );
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });
      await app(
        tester,
        IremboRequestPage(id: 'r1', manage: true, repository: FakeIrembo()),
        role: 'ADMIN',
      );
      final l = AppLocalizations.of(
        tester.element(find.byType(IremboRequestPage)),
      );
      await tester.ensureVisible(find.text(l.irCall));
      await tester.tap(find.text(l.irCall));
      await tester.pumpAndSettle();
      expect(launched, 'tel:0788123456');
      await tester.ensureVisible(find.text(l.irCopyAll));
      await tester.tap(find.text(l.irCopyAll));
      await tester.pump();
      expect(find.text(l.irCopyFailed), findsOneWidget);
    },
  );
}
