import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple JSON-based offline cache using SharedPreferences.
/// Stores API responses locally so the app works without network.
class OfflineCache {
  static final OfflineCache _instance = OfflineCache._();
  factory OfflineCache() => _instance;
  OfflineCache._();

  static const _prefix = 'offline_cache_';

  /// Save data under [key]. Data can be a List or Map.
  Future<void> save(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', json.encode(data));
  }

  /// Load cached data for [key]. Returns null if nothing cached.
  Future<dynamic> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null) return null;
    return json.decode(raw);
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

  /// Queue a practice result for later sync.
  Future<void> queuePendingResult(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey);
    final List<dynamic> pending = raw != null ? json.decode(raw) : [];
    pending.add(result);
    await prefs.setString(_pendingKey, json.encode(pending));
  }

  /// Get all pending results waiting to sync.
  Future<List<Map<String, dynamic>>> getPendingResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey);
    if (raw == null) return [];
    final List<dynamic> list = json.decode(raw);
    return list.cast<Map<String, dynamic>>();
  }

  /// Clear all pending results after successful sync.
  Future<void> clearPendingResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingKey);
  }

  /// Remove a single pending result by index.
  Future<void> removePendingResult(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey);
    if (raw == null) return;
    final List<dynamic> pending = json.decode(raw);
    if (index >= 0 && index < pending.length) {
      pending.removeAt(index);
      await prefs.setString(_pendingKey, json.encode(pending));
    }
  }
}
