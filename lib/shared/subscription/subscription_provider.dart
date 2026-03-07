import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionProvider extends ChangeNotifier {
  static const _keyActive = 'access_active';
  static const _keyExpiresAt = 'access_expires_at';
  static const _keyTier = 'access_tier';

  bool _hasActiveAccess = false;
  DateTime? _expiresAt;
  String? _paymentTier;
  bool _isLoading = false;

  bool get hasActiveAccess => _hasActiveAccess;
  DateTime? get expiresAt => _expiresAt;
  String? get paymentTier => _paymentTier;
  bool get isLoading => _isLoading;

  SubscriptionProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getBool(_keyActive) ?? false;
    final expiresAtStr = prefs.getString(_keyExpiresAt);
    final tier = prefs.getString(_keyTier);

    _hasActiveAccess = active;
    _expiresAt = expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null;
    _paymentTier = tier;

    // If cached as active but expiry has passed, mark inactive
    if (_hasActiveAccess && _expiresAt != null && _expiresAt!.isBefore(DateTime.now())) {
      _hasActiveAccess = false;
    }

    notifyListeners();
  }

  Future<void> refreshStatus(String userId, String baseUrl, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl/api/access-codes/status?userId=$userId');
      final response = await http
          .get(uri, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payload = data['data'] ?? data;

        _hasActiveAccess = payload['hasActiveAccess'] == true;
        _expiresAt = payload['expiresAt'] != null
            ? DateTime.tryParse(payload['expiresAt'])
            : null;
        _paymentTier = payload['paymentTier'] as String?;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyActive, _hasActiveAccess);
        if (_expiresAt != null) {
          await prefs.setString(_keyExpiresAt, _expiresAt!.toIso8601String());
        }
        if (_paymentTier != null) {
          await prefs.setString(_keyTier, _paymentTier!);
        }
      }
    } catch (e) {
      // Keep cached values on network error (logged for debugging)
      assert(() {
        // ignore: avoid_print
        print('[SubscriptionProvider] refreshStatus error: $e');
        return true;
      }());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearStatus() async {
    _hasActiveAccess = false;
    _expiresAt = null;
    _paymentTier = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActive);
    await prefs.remove(_keyExpiresAt);
    await prefs.remove(_keyTier);

    notifyListeners();
  }
}
