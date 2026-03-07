import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceId {
  static const _key = 'device_id';

  Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key)?.trim();
    final platformId = await _readPlatformId();

    // Prefer a real platform identifier whenever available.
    if (platformId != null && platformId.isNotEmpty) {
      if (existing != platformId) {
        await prefs.setString(_key, platformId);
      }
      return platformId;
    }

    if (existing != null && existing.isNotEmpty) return existing;

    final generated = _generate();
    await prefs.setString(_key, generated);
    return generated;
  }

  Future<String?> _readPlatformId() async {
    try {
      final info = await DeviceInfoPlugin().deviceInfo;
      final data = info.data;

      const preferredKeys = <String>[
        'androidId',
        'identifierForVendor',
        'machineId',
        'id',
      ];

      for (final key in preferredKeys) {
        final value = data[key]?.toString().trim();
        if (value != null && value.isNotEmpty && value.toLowerCase() != 'unknown') {
          return value;
        }
      }
    } catch (_) {
      // Keep fallback behavior when platform APIs are unavailable.
    }

    return null;
  }

  String _generate() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

