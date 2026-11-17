import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/repositories/auth_repository.dart';
import 'package:traffic_rule_in_rwanda/features/referrals/data/referral_session.dart';
import 'package:traffic_rule_in_rwanda/shared/network/api_client.dart';

const code = 'RW0123456789ABCDEF';
const link = 'https://backendapi.rwandatraffic.rw/referral?code=$code';
const form = {'phoneNumber': '0788123456', 'fullName': 'Test Driver'};

class RegistrationApi extends ApiClient {
  final requests = <Map<String, dynamic>>[];
  bool fail = true;
  @override
  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    requests.add(Map<String, dynamic>.from(body as Map));
    if (fail) throw ApiException('offline');
    return {
      'id': 'new-user',
      'fullName': 'Test Driver',
      'phoneNumber': '0788123456',
      'token': 'test-token',
      'referralStatus': 'confirmed',
    };
  }
}

class CleanupFailureSession extends ReferralSession {
  CleanupFailureSession() : super(android: false);

  @override
  Future<void> complete() async => throw PlatformException(code: 'STORAGE');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'referral cleanup failure does not fail successful authentication',
    () async {
      final api = RegistrationApi()..fail = false;
      final repository = AuthRepository(
        apiClient: api,
        referralSession: CleanupFailureSession(),
      );
      expect(
        (await repository.signUp(
          fullName: 'Test Driver',
          phoneNumber: '0788123456',
        ))?.id,
        'new-user',
      );
      expect(
        (await repository.signIn(phoneNumber: '0788123456'))?.id,
        'new-user',
      );
    },
  );

  test(
    'platform referrer errors remain retryable without blocking signup',
    () async {
      String? document;
      var calls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(ReferralSession.channel, (call) async {
            switch (call.method) {
              case 'read':
                return document;
              case 'write':
                document = call.arguments as String;
                return null;
              case 'initialLink':
                return link;
              case 'installReferrer':
                calls++;
                throw PlatformException(code: 'SERVICE_UNAVAILABLE');
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(ReferralSession.channel, null),
      );
      final session = ReferralSession(android: true);
      // Exercise service failure before capturing the direct invitation.
      await session.recoverInstallReferrer();
      await session.recoverInstallReferrer();
      expect(calls, 2);
      expect((await session.registrationFields(form))['referralCode'], code);
    },
  );

  test('accepts only canonical production invitations', () {
    expect(ReferralSession.codeFromLink('$link&lang=fr'), code);
    for (final bad in [
      'http://backendapi.rwandatraffic.rw/referral?code=$code',
      'https://evil.example/referral?code=$code',
      'https://backendapi.rwandatraffic.rw.evil.example/referral?code=$code',
      'https://backendapi.rwandatraffic.rw:8080/referral?code=$code',
      'https://backendapi.rwandatraffic.rw/other?code=$code',
      '$link&code=RWAAAAAAAAAAAAAAAA',
      '$link%0A',
    ]) {
      expect(ReferralSession.codeFromLink(bad), isNull, reason: bad);
    }
  });

  test(
    'first invitation survives restarts, cancelled signup and retries',
    () async {
      await ReferralSession(android: false).capture(link);
      final session = ReferralSession(android: false);
      await session.capture(
        'https://backendapi.rwandatraffic.rw/referral?code=RWAAAAAAAAAAAAAAAA',
      );
      final fields = await session.registrationFields(form);
      expect(fields['referralCode'], code);
      expect(fields['registrationKey'], matches(RegExp(r'^[a-f0-9]{64}$')));
      expect(
        await ReferralSession(android: false).registrationFields(form),
        fields,
      );
      final edited = await session.registrationFields({
        ...form,
        'fullName': 'Edited Name',
      });
      expect(edited['registrationKey'], isNot(fields['registrationKey']));
      expect(edited['referralCode'], code);
    },
  );

  test(
    'completed or existing users cannot acquire attribution from a link',
    () async {
      final session = ReferralSession(android: false);
      await session.capture(link);
      await session.complete();
      await session.capture(link);
      expect(
        (await session.registrationFields(form)).containsKey('referralCode'),
        isFalse,
      );
      SharedPreferences.setMockInitialValues({
        'auth_refresh_token': 'existing-session',
      });
      final existing = ReferralSession(android: false);
      await existing.capture(link);
      expect(
        (await existing.registrationFields(form)).containsKey('referralCode'),
        isFalse,
      );
    },
  );

  test(
    'a late invitation cannot change an in-flight registration retry',
    () async {
      final session = ReferralSession(android: false);
      final before = await session.registrationFields(form);
      await session.capture(link);
      expect(await session.registrationFields(form), before);
    },
  );

  test(
    'failed registration retains invitation and request key until success',
    () async {
      final session = ReferralSession(android: false);
      await session.capture(link);
      final api = RegistrationApi();
      final repository = AuthRepository(
        apiClient: api,
        referralSession: session,
      );
      await expectLater(
        repository.signUp(fullName: 'Test Driver', phoneNumber: '0788123456'),
        throwsA(isA<ApiException>()),
      );
      api.fail = false;
      await repository.signUp(
        fullName: 'Test Driver',
        phoneNumber: '0788123456',
      );
      expect(api.requests[0]['referralCode'], code);
      expect(api.requests[1], api.requests[0]);
      final persisted = (await SharedPreferences.getInstance()).getString(
        'pending_referral_v1',
      )!;
      expect(jsonDecode(persisted), {'consumed': true, 'installChecked': true});
    },
  );

  test(
    'Play referrer survives onboarding and transient service failures retry',
    () async {
      String? encryptedDocument;
      var calls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(ReferralSession.channel, (call) async {
            switch (call.method) {
              case 'read':
                return encryptedDocument;
              case 'write':
                encryptedDocument = call.arguments as String;
                return null;
              case 'initialLink':
                return null;
              case 'installReferrer':
                calls++;
                return calls == 1
                    ? {'complete': false}
                    : {'complete': true, 'referrer': 'referral_code=$code'};
            }
            throw PlatformException(code: 'unexpected');
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(ReferralSession.channel, null),
      );
      final session = ReferralSession(android: true);
      await session.initialize();
      final fields = await session.registrationFields(form);
      expect(fields['referralCode'], code);
      expect(calls, 2);
      await session.complete();
      await session.recoverInstallReferrer();
      expect(calls, 2);
    },
  );
}
