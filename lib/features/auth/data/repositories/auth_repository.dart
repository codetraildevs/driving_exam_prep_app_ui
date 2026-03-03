import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final supabase = Supabase.instance.client;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await supabase.from('users').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
        });

        return UserModel(
          id: response.user!.id,
          name: name,
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (response != null) {
          await supabase
              .from('users')
              .update({'last_login': DateTime.now().toIso8601String()})
              .eq('id', user.id);

          return UserModel.fromJson(response);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  UserModel? getCurrentUser() {
    final user = supabase.auth.currentUser;
    return user != null
        ? UserModel(
      id: user.id,
      name: user.userMetadata?['name'] ?? '',
      email: user.email ?? '',
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    )
        : null;
  }

  Future<UserModel?> fetchUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response != null ? UserModel.fromJson(response) : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String name,
    String? avatarUrl,
  }) async {
    try {
      await supabase.from('users').update({
        'name': name,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  bool isAuthenticated() => supabase.auth.currentUser != null;

  String? getCurrentUserId() => supabase.auth.currentUser?.id;
}
