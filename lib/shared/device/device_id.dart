import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides a persistent, unique-per-device identifier.
///
/// Strategy (in order of preference):
///  1. **Native platform channel** → `Settings.Secure.ANDROID_ID` (SHA-256
///     hashed).  Survives uninstall/reinstall, unique per device + signing key
///     on Android 8.0+.  No dangerous permissions needed.
///  2. **SharedPreferences cache** → if the platform call fails (e.g. on an
///     emulator or unsupported platform), we fall back to a locally-generated
///     UUID-v4 that is cached in SharedPreferences.  This is less persistent
///     (wiped on uninstall) but keeps the app functional.
///
/// The resolved ID is cached in SharedPreferences so subsequent calls are fast
/// and the app works even if the native channel is temporarily unavailable.
class DeviceId {
  static const _key = 'device_id';
  static const _channel = MethodChannel('com.driveprep.rwanda/device_id');

  Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Try the native hardware-persistent ID.
    try {
      final nativeId = await _channel.invokeMethod<String>('getPersistentDeviceId');
      if (nativeId != null && nativeId.isNotEmpty) {
        // Persist so we never lose it even if future calls fail.
        await prefs.setString(_key, nativeId);
        return nativeId;
      }
    } on PlatformException {
      // Platform call failed — fall through to cache / fallback.
    } on MissingPluginException {
      // Running on a platform without the native channel (e.g. tests, web).
    }

    // 2. Return cached value if we had one from a previous launch.
    final cached = prefs.getString(_key)?.trim();
    if (cached != null && cached.isNotEmpty) return cached;

    // 3. Last resort: generate a UUID-v4 (lost on uninstall, but keeps the
    //    app functional on platforms without the native channel).
    final generated = _generateUuidV4();
    await prefs.setString(_key, generated);
    return generated;
  }

  /// RFC 4122 version-4 UUID using a cryptographically secure RNG.
  String _generateUuidV4() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant 1

    String hex(int byte) => byte.toRadixString(16).padLeft(2, '0');
    final sb = StringBuffer()
      ..writeAll(bytes.sublist(0, 4).map(hex))
      ..write('-')
      ..writeAll(bytes.sublist(4, 6).map(hex))
      ..write('-')
      ..writeAll(bytes.sublist(6, 8).map(hex))
      ..write('-')
      ..writeAll(bytes.sublist(8, 10).map(hex))
      ..write('-')
      ..writeAll(bytes.sublist(10, 16).map(hex));
    return sb.toString();
  }
}

