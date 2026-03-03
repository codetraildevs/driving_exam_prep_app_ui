import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepository {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      final attemptResponse = await supabase
          .from('exam_attempts')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);

      final signsResponse = await supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('is_learned', true);

      final lastScore = attemptResponse.isNotEmpty ? attemptResponse.first['score'] : null;
      final bestScore = attemptResponse.isNotEmpty
          ? (attemptResponse as List).map((e) => e['score'] as int).reduce((a, b) => a > b ? a : b)
          : null;
      final totalAttempts = attemptResponse.length;
      final signsLearned = signsResponse.length;

      return {
        'last_score': lastScore,
        'best_score': bestScore,
        'total_attempts': totalAttempts,
        'signs_learned': signsLearned,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getDailyStreak(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select('daily_streak')
          .eq('id', userId)
          .maybeSingle();

      return response?['daily_streak'] ?? 0;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLastLogin(String userId) async {
    try {
      await supabase
          .from('users')
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
