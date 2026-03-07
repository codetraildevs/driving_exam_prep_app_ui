import '../../../../shared/network/api_client.dart';
import '../../../../shared/session/auth_session.dart';
import '../../../../shared/network/api_endpoints.dart';
import '../models/sign_model.dart';

class SignsRepository {
  final ApiClient _api = ApiClient();
  final AuthSession _session = AuthSession();

  Future<List<TrafficSignModel>> getTrafficSigns({
    String? category,
    String? searchQuery,
  }) async {
    try {
      final token = await _session.getToken();
      final qp = <String, String>{
        if (category != null && category.isNotEmpty) 'category': category,
        if (searchQuery != null && searchQuery.isNotEmpty) 'q': searchQuery,
      };

      final data = await _api.get(
        ApiEndpoints.signs,
        queryParameters: qp.isEmpty ? null : qp,
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      );

      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .map(TrafficSignModel.fromJson)
            .toList();
      }
      return const <TrafficSignModel>[];
    } on ApiException catch (e) {
      // Backend may not implement signs yet; keep UI usable.
      if (e.statusCode == 404) return const <TrafficSignModel>[];
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<TrafficSignModel?> getSignById(String signId) async {
    try {
      final token = await _session.getToken();
      final data = await _api.get(
        ApiEndpoints.signById(signId),
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      );
      if (data is Map<String, dynamic>) return TrafficSignModel.fromJson(data);
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isSignLearned(String userId, String signId) async {
    try {
      final token = await _session.getToken();
      final data = await _api.get(
        ApiEndpoints.signProgress(userId, signId),
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      );
      if (data is Map<String, dynamic>) {
        final v = data['is_learned'] ?? data['learned'];
        if (v is bool) return v;
        if (v is int) return v == 1;
        if (v is String) return v.toLowerCase() == 'true' || v == '1';
      }
      if (data is bool) return data;
      return false;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return false;
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markSignAsLearned(String userId, String signId) async {
    try {
      final token = await _session.getToken();
      await _api.post(
        ApiEndpoints.markSignLearned(userId, signId),
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) return;
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final token = await _session.getToken();
      final data = await _api.get(
        ApiEndpoints.signCategories,
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      );

      if (data is List) {
        return data.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      }

      if (data is Map<String, dynamic> && data['categories'] is List) {
        return (data['categories'] as List)
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      return const <String>[];
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const <String>[];
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
