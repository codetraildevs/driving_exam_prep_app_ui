import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_helper.dart';

/// Immutable state for the subscription/access status.
class SubscriptionState {
  final bool hasActiveAccess;
  final DateTime? expiresAt;
  final String? paymentTier;
  final bool isLoading;
  final bool hasLoaded;
  final bool hasError;

  const SubscriptionState({
    this.hasActiveAccess = false,
    this.expiresAt,
    this.paymentTier,
    this.isLoading = false,
    this.hasLoaded = false,
    this.hasError = false,
  });

  SubscriptionState copyWith({
    bool? hasActiveAccess,
    DateTime? expiresAt,
    String? paymentTier,
    bool? isLoading,
    bool? hasLoaded,
    bool? hasError,
  }) {
    return SubscriptionState(
      hasActiveAccess: hasActiveAccess ?? this.hasActiveAccess,
      expiresAt: expiresAt ?? this.expiresAt,
      paymentTier: paymentTier ?? this.paymentTier,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      hasError: hasError ?? this.hasError,
    );
  }
}

/// Riverpod notifier for subscription/access status.
class SubscriptionNotifier extends Notifier<SubscriptionState> {
  static const _keyActive = 'access_active';
  static const _keyExpiresAt = 'access_expires_at';
  static const _keyTier = 'access_tier';
  int _revision = 0;
  late Future<void> _prefsReady;

  @override
  SubscriptionState build() {
    // Kick off async load from prefs (state will update when complete).
    _prefsReady = _loadFromPrefs();
    return const SubscriptionState();
  }

  Future<void> _loadFromPrefs() async {
    final revision = _revision;
    final prefs = await SharedPreferences.getInstance();
    if (revision != _revision) return;
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
      hasLoaded: prefs.containsKey(_keyActive),
    );
  }

  /// Fetches fresh subscription status from the server.
  Future<void> refreshStatus(String userId) async {
    await _prefsReady;
    final revision = ++_revision;
    state = state.copyWith(isLoading: true, hasError: false);

    try {
      final result =
          await ApiHelper().get('/api/access-codes/status', queryParams: {'userId': userId});

      if (revision != _revision) return;
      if (result.isSuccess && result.data is Map<String, dynamic> && (result.data as Map).containsKey('hasActiveAccess')) {
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
          hasLoaded: true,
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
      } else {
        state = state.copyWith(hasError: true);
      }
    } catch (e) {
      // Retain known data, but identify an unavailable refresh in the UI.
      if (revision == _revision) state = state.copyWith(hasError: true);
    } finally {
      if (revision == _revision) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> clearStatus() async {
    ++_revision;
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
