import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple JSON-based offline cache using SharedPreferences.
/// Stores API responses locally so the app works without network.
class OfflineCache {
  static final OfflineCache _instance = OfflineCache._();
  factory OfflineCache() => _instance;
  OfflineCache._();

  static const _prefix = 'offline_cache_';
  Future<void> _writes = Future.value();

  Future<T> _serial<T>(Future<T> Function() action) {
    final next = _writes.then((_) => action());
    _writes = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }

  String _resultId() {
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  List<Map<String, dynamic>> _pending(SharedPreferences prefs) {
    final raw = prefs.getString(_pendingKey);
    if (raw == null) return [];
    return (json.decode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }


  /// Save data under [key]. Data can be a List or Map.
  Future<void> save(String key, dynamic data) => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    if (key.startsWith('exam_results_') && data is List) {
      final userId = key.substring('exam_results_'.length);
      final merged = List<dynamic>.from(data);
      final ids = merged.whereType<Map>().map((r) => r['id']?.toString()).toSet();
      for (final row in _pending(prefs).where((r) => r['userId'] == userId)) {
        if (!ids.contains(row['clientResultId'])) {
          merged.add({...row, 'id': row['clientResultId']});
        }
      }
      merged.sort((a, b) => (b['createdAt'] ?? b['completedAt'] ?? '').toString()
          .compareTo((a['createdAt'] ?? a['completedAt'] ?? '').toString()));
      data = merged;
    }
    await prefs.setString('$_prefix$key', json.encode(data));
  });

  /// Load cached data for [key]. Returns null if nothing cached.
  Future<dynamic> load(String key) async {
    await _writes;
    final prefs = await SharedPreferences.getInstance();
    dynamic data;
    try { data = json.decode(prefs.getString('$_prefix$key') ?? 'null'); } catch (_) {}
    if (!key.startsWith('exam_results_')) return data;
    // Recover progress if the app closed after saving the outbox but before
    // writing its derived cache.
    final userId = key.substring('exam_results_'.length);
    final pending = (await getPendingResults()).where((r) => r['userId'] == userId);
    if (data is! List && pending.isEmpty) return null;
    final merged = data is List ? List<dynamic>.from(data) : <dynamic>[];
    final ids = merged.whereType<Map>().map((r) => r['id']?.toString()).toSet();
    for (final row in pending) {
      if (!ids.contains(row['clientResultId'])) {
        merged.add({...row, 'id': row['clientResultId']});
      }
    }
    merged.sort((a, b) => (b['createdAt'] ?? b['completedAt'] ?? '').toString()
        .compareTo((a['createdAt'] ?? a['completedAt'] ?? '').toString()));
    return merged;
  }

  /// Remove cached data for [key].
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
  }

  /// Clear all cached data.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  // ── Convenience keys ─────────────────────────────────────────────────────

  String examResultsKey(String userId) => 'exam_results_$userId';
  String userStatsKey(String userId) => 'user_stats_$userId';

  // ── Pending results queue (for offline submissions) ──────────────────────

  static const _pendingKey = '${_prefix}pending_results';

  /// Persist the attempt and its local progress before attempting the network.
  Future<void> queuePendingResult(Map<String, dynamic> result) => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    final row = {...result};
    row['clientResultId'] ??= _resultId();
    row['createdAt'] ??= DateTime.now().toUtc().toIso8601String();
    final pending = _pending(prefs);
    if (!pending.any((r) => r['clientResultId'] == row['clientResultId'])) pending.add(row);
    // The outbox is authoritative: write it before the derived progress cache.
    await prefs.setString(_pendingKey, json.encode(pending));
    final key = '$_prefix${examResultsKey(row['userId'] as String)}';
    List<dynamic> local = [];
    try { local = json.decode(prefs.getString(key) ?? '[]') as List; } catch (_) {}
    local.removeWhere((r) => r is Map && r['id'] == row['clientResultId']);
    local.insert(0, {...row, 'id': row['clientResultId']});
    await prefs.setString(key, json.encode(local));
  });

  Future<List<Map<String, dynamic>>> getPendingResults() => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = _pending(prefs);
    var migrated = false;
    for (final row in pending) {
      if (row['clientResultId'] == null) {
        row['clientResultId'] = _resultId();
        row['createdAt'] ??= DateTime.now().toUtc().toIso8601String();
        migrated = true;
      }
    }
    if (migrated) await prefs.setString(_pendingKey, json.encode(pending));
    return pending;
  });

  /// Remove only the acknowledged attempt; newly queued attempts are preserved.
  Future<void> acknowledgeResult(String clientId, String userId, String serverId) => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${examResultsKey(userId)}';
    final local = json.decode(prefs.getString(key) ?? '[]') as List;
    for (final row in local.whereType<Map>()) {
      if (row['id'] == clientId) row['id'] = serverId;
    }
    await prefs.setString(key, json.encode(local));
    final pending = _pending(prefs)
      ..removeWhere((r) => r['clientResultId'] == clientId && r['userId'] == userId);
    await prefs.setString(_pendingKey, json.encode(pending));
  });

  Future<void> clearPendingResults() => _serial(() async {
    await (await SharedPreferences.getInstance()).remove(_pendingKey);
  });

  Future<void> removePendingResult(int index) => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = _pending(prefs);
    if (index >= 0 && index < pending.length) {
      pending.removeAt(index);
      await prefs.setString(_pendingKey, json.encode(pending));
    }
  });
}
