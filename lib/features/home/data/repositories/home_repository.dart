import '../../../../shared/network/api_client.dart';
import '../../../../shared/network/api_endpoints.dart';
import '../../../../shared/network/offline_cache.dart';
import '../../../../shared/session/auth_session.dart';

class HomeRepository {
  final ApiClient _api = ApiClient();
  final AuthSession _session = AuthSession();

  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    final cache = OfflineCache();
    final cacheKey = cache.userStatsKey(userId);

    try {
      // Backend available endpoint: GET /api/exam-results/:userId
      final token = await _session.getToken();
      final data = await _api.get(
        ApiEndpoints.examResultsForUser(userId),
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      );

      if (data is! List) {
        final fallback = {
          'last_score': 0,
          'best_score': 0,
          'total_attempts': 0,
          'signs_learned': 0,
        };
        await cache.save(cacheKey, fallback);
        return fallback;
      }

      final scores = <int>[];
      int? lastScore;
      for (final item in data) {
        if (item is Map) {
          final s = item['score'];
          final parsed = s is int ? s : int.tryParse(s?.toString() ?? '');
          if (parsed != null) scores.add(parsed);
        }
      }
      if (scores.isNotEmpty) lastScore = scores.first;

      final bestScore = scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b);
      final totalAttempts = scores.length;

      final stats = {
        'last_score': lastScore ?? 0,
        'best_score': bestScore,
        'total_attempts': totalAttempts,
        'signs_learned': 0,
      };
      await cache.save(cacheKey, stats);
      return stats;
    } catch (e) {
      // Fallback to cache
      final cached = await cache.load(cacheKey);
      if (cached is Map<String, dynamic>) return cached;
      rethrow;
    }
  }

  Future<int> getDailyStreak(String userId) async {
    try {
      // Compute streak from exam results (consecutive days with >=1 attempt).
      final token = await _session.getToken();
      final data = await _api.get(
        ApiEndpoints.examResultsForUser(userId),
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      );
      if (data is! List) return _streakFromCache(userId);

      // Cache for offline use
      final cache = OfflineCache();
      await cache.save(cache.examResultsKey(userId), data);

      return _computeStreak(data);
    } catch (e) {
      return _streakFromCache(userId);
    }
  }

  Future<int> _streakFromCache(String userId) async {
    final cache = OfflineCache();
    final cached = await cache.load(cache.examResultsKey(userId));
    if (cached is List) return _computeStreak(cached);
    return 0;
  }

  int _computeStreak(List<dynamic> data) {
      final daysWithActivity = <DateTime>{};
      for (final item in data) {
        if (item is Map) {
          final raw = item['createdAt'] ?? item['created_at'] ?? item['completedAt'] ?? item['completed_at'];
          final dt = DateTime.tryParse(raw?.toString() ?? '');
          if (dt == null) continue;
          daysWithActivity.add(DateTime(dt.year, dt.month, dt.day));
        }
      }
      if (daysWithActivity.isEmpty) return 0;

      var streak = 0;
      var day = DateTime.now();
      day = DateTime(day.year, day.month, day.day);
      while (daysWithActivity.contains(day)) {
        streak += 1;
        day = day.subtract(const Duration(days: 1));
      }
      return streak;
  }

  Future<void> updateLastLogin(String userId) async {
    try {
      // Not implemented in current backend. Keep as a no-op.
    } catch (e) {
      rethrow;
    }
  }
}
