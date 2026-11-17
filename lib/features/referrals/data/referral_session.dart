import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/session/auth_session.dart';

/// First valid invitation wins until registration completes or the user logs in.
/// Android persists this document encrypted using Android Keystore.
class ReferralSession {
  static final instance = ReferralSession();
  static const channel = MethodChannel('com.trafficrules.rwanda.app/referrals');
  static const host = 'backendapi.rwandatraffic.rw';
  final bool android;
  Future<void> _queue = Future.value();
  Future<void>? _initializing;
  Future<void>? _recovering;

  ReferralSession({bool? android})
    : android =
          android ??
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  static String? codeFromLink(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != host ||
        uri.hasPort ||
        uri.userInfo.isNotEmpty ||
        uri.path != '/referral' ||
        uri.queryParametersAll['code']?.length != 1) {
      return null;
    }
    return validCode(uri.queryParameters['code']);
  }

  static String? validCode(String? value) =>
      value != null && RegExp(r'^RW[A-F0-9]{16}$').hasMatch(value)
      ? value
      : null;

  Future<Map<String, dynamic>> _read() async {
    final raw = android
        ? await channel.invokeMethod<String>('read')
        : (await SharedPreferences.getInstance()).getString(
            'pending_referral_v1',
          );
    if (raw == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> _write(Map<String, dynamic> data) async {
    final raw = jsonEncode(data);
    if (android) {
      await channel.invokeMethod<void>('write', raw);
    } else {
      await (await SharedPreferences.getInstance()).setString(
        'pending_referral_v1',
        raw,
      );
    }
  }

  Future<T> _serialized<T>(Future<T> Function() action) {
    final next = _queue.then((_) => action());
    _queue = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }

  Future<void> capture(String link) async {
    final code = codeFromLink(link);
    if (code == null) return;
    if (await AuthSession().hasPersistedSession()) {
      await complete();
      return;
    }
    await _captureCode(code);
  }

  Future<void> _captureCode(String code) => _serialized(() async {
    final state = await _read();
    if (state['consumed'] == true ||
        state['code'] != null ||
        state['attempt'] != null) {
      return;
    }
    state['code'] = code;
    await _write(state);
  });

  Future<void> initialize() =>
      _initializing ??= _initialize().catchError((Object error) {
        _initializing = null;
        throw error;
      });

  Future<void> _initialize() async {
    if (!android) return;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'link' && call.arguments is String) {
        try {
          await capture(call.arguments as String);
        } catch (_) {
          /* Retry on next launch. */
        }
      }
    });
    if (await AuthSession().hasPersistedSession()) {
      await complete();
      return;
    }
    final link = await channel.invokeMethod<String>('initialLink');
    if (link != null) await capture(link);
    await recoverInstallReferrer();
  }

  Future<void> recoverInstallReferrer() =>
      _recovering ??= _recoverInstallReferrer().whenComplete(() {
        _recovering = null;
      });

  Future<void> _recoverInstallReferrer() async {
    if (!android) return;
    final state = await _serialized(_read);
    if (state['consumed'] == true ||
        state['installChecked'] == true ||
        state['code'] != null) {
      return;
    }
    Map<String, dynamic>? result;
    try {
      result = await channel.invokeMapMethod<String, dynamic>(
        'installReferrer',
      );
    } on PlatformException {
      return; // Keep recovery eligible for a later launch or signup retry.
    } on MissingPluginException {
      return; // Builds without Play support can still register.
    }
    if (result?['complete'] != true) {
      return; // Transient failure: retry before signup/next launch.
    }
    final raw = result?['referrer'];
    if (raw is String) {
      try {
        final values = Uri.splitQueryString(raw);
        final code = validCode(values['referral_code']);
        if (code != null) await _captureCode(code);
      } on FormatException {
        /* Invalid referrers never block registration. */
      }
    }
    await _serialized(() async {
      final latest = await _read();
      latest['installChecked'] = true;
      await _write(latest);
    });
  }

  /// Persist the exact request and random retry secret before sending it.
  /// Editing the form starts a new attempt; network retries reuse the secret.
  Future<Map<String, dynamic>> registrationFields(
    Map<String, dynamic> form,
  ) async {
    await initialize();
    await recoverInstallReferrer();
    return _serialized(() async {
      final state = await _read();
      final signature = jsonEncode(form);
      var attempt = state['attempt'] as Map?;
      if (attempt == null || attempt['form'] != signature) {
        final random = Random.secure();
        attempt = {
          'form': signature,
          'key': List.generate(
            32,
            (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
          ).join(),
          'code': state['consumed'] == true ? null : state['code'],
        };
        state['attempt'] = attempt;
        await _write(state);
      }
      return {
        'registrationKey': attempt['key'],
        if (attempt['code'] != null) 'referralCode': attempt['code'],
      };
    });
  }

  Future<void> complete() =>
      _serialized(() => _write({'consumed': true, 'installChecked': true}));
}
