import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sign_model.dart';

class SignsRepository {
  final supabase = Supabase.instance.client;

  Future<List<TrafficSignModel>> getTrafficSigns({
    String? category,
    String? searchQuery,
  }) async {
    try {
      var query = supabase.from('traffic_signs').select();

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query;

      List<TrafficSignModel> signs = (response as List)
          .map((item) => TrafficSignModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        signs = signs
            .where((sign) =>
                sign.title.toLowerCase().contains(query) ||
                sign.description.toLowerCase().contains(query))
            .toList();
      }

      return signs;
    } catch (e) {
      rethrow;
    }
  }

  Future<TrafficSignModel?> getSignById(String signId) async {
    try {
      final response = await supabase
          .from('traffic_signs')
          .select()
          .eq('id', signId)
          .maybeSingle();

      return response != null ? TrafficSignModel.fromJson(response) : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isSignLearned(String userId, String signId) async {
    try {
      final response = await supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('sign_id', signId)
          .maybeSingle();

      return response != null && response['is_learned'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markSignAsLearned(String userId, String signId) async {
    try {
      final existing = await supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('sign_id', signId)
          .maybeSingle();

      if (existing != null) {
        await supabase
            .from('user_progress')
            .update({
              'is_learned': true,
              'learned_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('sign_id', signId);
      } else {
        await supabase.from('user_progress').insert({
          'user_id': userId,
          'sign_id': signId,
          'is_learned': true,
          'learned_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await supabase
          .from('traffic_signs')
          .select('category');

      return (response as List)
          .map((item) => item['category'] as String)
          .toSet()
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
