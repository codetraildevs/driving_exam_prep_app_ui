import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_helper.dart';

/// Immutable state for the subscription/access status.
class SubscriptionState {
  final bool hasActiveAccess;
  final DateTime? expiresAt;
  final String? paymentTier;
  final bool isLoading;

  const SubscriptionState({
    this.hasActiveAccess = false,
    this.expiresAt,
    this.paymentTier,
    this.isLoading = false,
  });

  SubscriptionState copyWith({
    bool? hasActiveAccess,
    DateTime? expiresAt,
    String? paymentTier,
    bool? isLoading,
  }) {
    return SubscriptionState(
      hasActiveAccess: hasActiveAccess ?? this.hasActiveAccess,
      expiresAt: expiresAt ?? this.expiresAt,
      paymentTier: paymentTier ?? this.paymentTier,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Riverpod notifier for subscription/access status.
class SubscriptionNotifier extends Notifier<SubscriptionState> {
  static const _keyActive = 'access_active';
  static const _keyExpiresAt = 'access_expires_at';
  static const _keyTier = 'access_tier';

  @override
  SubscriptionState build() {
    // Kick off async load from prefs (state will update when complete).
    _loadFromPrefs();
    return const SubscriptionState();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getBool(_keyActive) ?? false;
    final expiresAtStr = prefs.getString(_keyExpiresAt);
    final tier = prefs.getString(_keyTier);

    var hasActiveAccess = active;
    DateTime? expiresAt =
        expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null;

    if (hasActiveAccess &&
        expiresAt != null &&
        expiresAt.isBefore(DateTime.now())) {
      hasActiveAccess = false;
    }

    state = SubscriptionState(
      hasActiveAccess: hasActiveAccess,
      expiresAt: expiresAt,
      paymentTier: tier,
    );
  }

  /// Fetches fresh subscription status from the server.
  Future<void> refreshStatus(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
      final result =
          await ApiHelper().get('/api/access-codes/status', queryParams: {'userId': userId});

      if (result.isSuccess) {
        final payload = result.data as Map<String, dynamic>? ?? {};

        final hasActiveAccess = payload['hasActiveAccess'] == true;
        final expiresAt = payload['expiresAt'] != null
            ? DateTime.tryParse(payload['expiresAt'])
            : null;
        final paymentTier = payload['paymentTier'] as String?;

        state = SubscriptionState(
          hasActiveAccess: hasActiveAccess,
          expiresAt: expiresAt,
          paymentTier: paymentTier,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyActive, hasActiveAccess);
        if (expiresAt != null) {
          await prefs.setString(_keyExpiresAt, expiresAt.toIso8601String());
        } else {
          await prefs.remove(_keyExpiresAt);
        }
        if (paymentTier != null) {
          await prefs.setString(_keyTier, paymentTier);
        } else {
          await prefs.remove(_keyTier);
        }
      }
    } catch (e) {
      // Network failure — keep cached values so the app works offline.
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> clearStatus() async {
    state = const SubscriptionState();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActive);
    await prefs.remove(_keyExpiresAt);
    await prefs.remove(_keyTier);
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
