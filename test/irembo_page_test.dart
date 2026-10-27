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
import 'package:traffic_rule_in_rwanda/features/irembo/presentation/irembo_payment_bar.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';

class FakeIrembo extends IremboRepository {
  final submissions = <Map<String, dynamic>>[];
  bool failOnce = false;
  bool failList = false;
  bool hasRequest = false;
  Map<String, String>? lastFilters;
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
  Future<Map<String, dynamic>> list(Map<String, String> filters) async {
    lastFilters = filters;
    if (failList) {
      throw const IremboFailure('iremboSetupRequired', statusCode: 503);
    }
    return {
      'items': hasRequest ? [record] : [],
      'total': hasRequest ? 1 : 0,
      'page': 1,
    };
  }

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
  testWidgets('existing request has status only and no second registration', (
    tester,
  ) async {
    final repo = FakeIrembo()..hasRequest = true;
    repo.record = {
      ...repo.record,
      'service': 'Permis',
      'permisOption': 'Automatic',
    };
    await app(tester, IremboPage(repository: repo));
    final l = AppLocalizations.of(tester.element(find.byType(IremboPage)));
    expect(find.byKey(const ValueKey('irembo-continue')), findsNothing);
    expect(find.text(l.irAlreadySubmitted), findsOneWidget);
    expect(find.text('IR-EXAMPLE'), findsNothing);
    expect(find.text('0123456789012345'), findsNothing);
    expect(find.text(l.irView), findsNothing);
    expect(find.text('*182*8*1*644203*5000#'), findsOneWidget);
    expect(
      tester.getRect(find.byKey(const ValueKey('irembo-pay'))).bottom,
      lessThan(780),
    );
  });
  for (final selection in [
    ('Provisoire', null, 1000),
    ('Permis', 'Manual', 1000),
    ('Permis', 'Automatic', 5000),
  ]) {
    testWidgets('service payment opens exact USSD for $selection', (
      tester,
    ) async {
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
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      await app(
        tester,
        Scaffold(
          body: IremboPaymentBar(service: selection.$1, option: selection.$2),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('irembo-pay')));
      await tester.pumpAndSettle();
      expect(Uri.parse(launched!).scheme, 'tel');
      expect(
        Uri.decodeComponent(Uri.parse(launched!).path),
        '*182*8*1*644203*${selection.$3}#',
      );
      expect(Uri.parse(launched!).fragment, isEmpty);
    });
  }
  testWidgets('direct submission rejects incomplete registration', (
    tester,
  ) async {
    final repo = FakeIrembo();
    await app(tester, IremboFormPage(service: 'Provisoire', repository: repo));
    final l = AppLocalizations.of(tester.element(find.byType(IremboFormPage)));
    await tester.ensureVisible(find.text(l.irConfirm));
    await tester.tap(find.text(l.irConfirm));
    await tester.pumpAndSettle();
    expect(repo.submissions, isEmpty);
    expect(find.text(l.irInvalid), findsOneWidget);
    expect(find.text(l.irReview), findsNothing);
  });
  testWidgets(
    'failed request is not a zero result and applicants have no pager',
    (tester) async {
      final repo = FakeIrembo()..failList = true;
      await app(tester, IremboPage(repository: repo));
      final l = AppLocalizations.of(tester.element(find.byType(IremboPage)));
      expect(find.text('${l.irResults}: 0'), findsNothing);
      expect(find.text(l.irNoRequests), findsNothing);
      expect(find.text(l.irServerSetup), findsOneWidget);
      expect(find.text(l.irPrevious), findsNothing);
      expect(repo.lastFilters!.containsKey('page'), isFalse);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('irembo-continue')))
            .onPressed,
        isNull,
      );
    },
  );
  testWidgets('selection is explicit and conditional option resets', (
    tester,
  ) async {
    await app(tester, IremboPage(repository: FakeIrembo()));
    final proceed = find.byKey(const ValueKey('irembo-continue'));
    expect(tester.widget<FilledButton>(proceed).onPressed, isNull);
    final permis = find.byKey(const ValueKey('service-permis'));
    await tester.ensureVisible(permis);
    await tester.tap(permis);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(proceed).onPressed, isNull);
    final manual = find.byKey(const ValueKey('option-manual'));
    await tester.ensureVisible(manual);
    await tester.tap(manual);
    await tester.pumpAndSettle();
    expect(tester.widget<ChoiceChip>(manual).selected, isTrue);
    expect(tester.widget<FilledButton>(proceed).onPressed, isNotNull);
    final provisoire = find.byKey(const ValueKey('service-provisoire'));
    await tester.ensureVisible(provisoire);
    await tester.tap(provisoire);
    await tester.pumpAndSettle();
    expect(manual, findsNothing);
    await tester.ensureVisible(permis);
    await tester.tap(permis);
    await tester.pumpAndSettle();
    expect(tester.widget<ChoiceChip>(manual).selected, isFalse);
    expect(tester.widget<FilledButton>(proceed).onPressed, isNull);
  });
  for (final lang in ['en', 'fr', 'rw']) {
    testWidgets('localized Irembo service selection $lang', (tester) async {
      await app(
        tester,
        IremboPage(repository: FakeIrembo()),
        lang: lang,
        size: const Size(320, 740),
      );
      final left = tester.getTopLeft(
        find.byKey(const ValueKey('service-provisoire')),
      );
      final right = tester.getTopLeft(
        find.byKey(const ValueKey('service-permis')),
      );
      expect(left.dy, right.dy);
      expect(left.dx, lessThan(right.dx));
      expect(find.text('Provisoire'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('service-permis')));
      await tester.tap(find.byKey(const ValueKey('service-permis')));
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
        IremboPage(manage: true, repository: FakeIrembo()..hasRequest = true),
        role: 'MANAGER',
        size: size,
      );
      final l = AppLocalizations.of(tester.element(find.byType(IremboPage)));
      await tester.ensureVisible(find.text(l.irFilters));
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
    'submits directly and retains details and retry key after a failure',
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
      expect(find.text(l.irReview), findsNothing);
      await tester.ensureVisible(find.text(l.irConfirm));
      await tester.tap(find.text(l.irConfirm));
      await tester.pumpAndSettle();
      expect(find.text(l.irUnavailable), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('irembo-nationalId')),
            )
            .controller!
            .text,
        '0123456789012345',
      );
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
          if (call.method == 'Clipboard.setData') {
            throw PlatformException(code: 'clipboard');
          }
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
