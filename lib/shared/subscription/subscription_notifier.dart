import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_helper.dart';
import '../session/auth_session.dart';
import 'dart:convert';

/// Immutable state for the subscription/access status.
class SubscriptionState {
  final bool _hasActiveAccess;
  bool get hasActiveAccess => _hasActiveAccess &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
  final DateTime? expiresAt;
  final String? paymentTier;
  final bool isLoading;
  final bool hasLoaded;
  final bool hasError;

  const SubscriptionState({
    bool hasActiveAccess = false,
    this.expiresAt,
    this.paymentTier,
    this.isLoading = false,
    this.hasLoaded = false,
    this.hasError = false,
  }) : _hasActiveAccess = hasActiveAccess;

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
  int _revision = 0;
  String? _userId;
  late Future<void> _prefsReady;
  final Future<ApiResponse> Function(String)? loader;
  SubscriptionNotifier({this.loader});

  @override
  SubscriptionState build() {
    ref.onDispose(() => ++_revision);
    _prefsReady = _restoreCurrentUser();
    return const SubscriptionState();
  }

  Future<void> _restoreCurrentUser() async {
    final revision = _revision;
    final user = await AuthSession().getUser();
    if (revision != _revision || user == null) return;
    await _restore(user.id, revision);
  }

  Future<void> _restore(String userId, int revision) async {
    final prefs = await SharedPreferences.getInstance();
    if (revision != _revision) return;
    _userId = userId;
    final raw = prefs.getString('access_status_$userId');
    try {
      final data = raw == null ? null : json.decode(raw) as Map;
      final expiry = DateTime.tryParse(data?['expiresAt']?.toString() ?? '');
      state = SubscriptionState(
        hasActiveAccess: data?['hasActiveAccess'] == true &&
            expiry != null && expiry.isAfter(DateTime.now()),
        expiresAt: expiry, paymentTier: data?['paymentTier'] as String?,
        hasLoaded: data != null,
      );
    } catch (_) {
      state = const SubscriptionState();
    }
  }

  Future<void> refreshStatus(String userId) async {
    await _prefsReady;
    final revision = ++_revision;
    if (_userId != userId) {
      state = const SubscriptionState();
      await _restore(userId, revision);
    }
    if (revision != _revision) return;
    state = state.copyWith(isLoading: true, hasError: false);
    try {
      final result = await (loader != null ? loader!(userId) :
          ApiHelper().get('/api/access-codes/status', queryParams: {'userId': userId}));
      if (revision != _revision) return;
      if (result.isSuccess && result.data is Map &&
          (result.data as Map).containsKey('hasActiveAccess')) {
        final payload = result.data as Map;
        final expiry = DateTime.tryParse(payload['expiresAt']?.toString() ?? '');
        state = SubscriptionState(hasActiveAccess: payload['hasActiveAccess'] == true,
          expiresAt: expiry, paymentTier: payload['paymentTier'] as String?, hasLoaded: true);
        final prefs = await SharedPreferences.getInstance();
        if (revision != _revision) return;
        await prefs.setString('access_status_$userId', json.encode({
          'hasActiveAccess': state.hasActiveAccess,
          'expiresAt': expiry?.toIso8601String(),
          'paymentTier': state.paymentTier,
        }));
      } else {
        state = state.copyWith(hasError: true);
      }
    } catch (_) {
      if (revision == _revision) state = state.copyWith(hasError: true);
    } finally {
      if (revision == _revision) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> clearStatus() async {
    ++_revision;
    _userId = null;
    state = const SubscriptionState();
    // Discard old unscoped flags; per-account verified records remain isolated.
    final prefs = await SharedPreferences.getInstance();
    for (final key in ['access_active', 'access_expires_at', 'access_tier']) {
      await prefs.remove(key);
    }
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
