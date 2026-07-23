import 'dart:async';

import '../session/auth_session.dart';

/// App-wide mutex that prevents concurrent token refresh attempts.
///
/// Both [ApiHelper] and [ApiClient] can trigger a refresh when they detect
/// an expired access token. Without coordination, they could race: the
/// backend's refresh-token rotation would cause one to succeed and the
/// other to fail with a "revoked" error.
///
/// Usage:
/// ```dart
/// final ok = await TokenRefreshMutex.runRefresh(() async {
///   // … perform the HTTP refresh call …
///   return true; // or false on failure
/// });
/// ```
class TokenRefreshMutex {
  static Completer<void>? _completer;

  /// Runs [refreshFn] under the shared mutex.
  ///
  /// 1. If another refresh is already in progress, waits for it to finish.
  /// 2. Checks whether the access token is now valid (the other caller may
  ///    have already refreshed it).
  /// 3. If still expired, acquires the lock and runs [refreshFn].
  ///
  /// Returns `true` if the access token is valid after this call (either
  /// refreshed by us or by a concurrent caller).
  static Future<bool> runRefresh(Future<bool> Function() refreshFn) async {
    // ── Round 1: try to acquire lock, or wait for current holder ──
    var wait = _tryLock();
    if (wait != null) {
      // Another refresh is in progress — wait for it to finish.
      await wait;
      if (await _tokenIsValid()) return true; // other refresh succeeded

      // Other caller's refresh failed — try to acquire the lock ourselves.
      // Multiple waiters race here; only one will succeed.
      wait = _tryLock();
      if (wait != null) {
        // Another waiter beat us to the lock — wait for their attempt.
        await wait;
        if (await _tokenIsValid()) return true;
        return false; // that waiter also failed
      }
    }

    // We have the lock — run the refresh.
    // Note: we do NOT check _tokenIsValid() here because the caller
    // (_ensureAccessToken / _ensureFreshToken) already verified the token
    // is expired before entering runRefresh. The only time the token could
    // be valid now is if a concurrent caller refreshed it and we waited
    // above for them — but that path already returned true.
    try {
      try {
        return await refreshFn();
      } catch (_) {
        return false; // exception in refresh → treated as failure
      }
    } finally {
      _unlock();
    }
  }

  /// Returns `null` if the lock was acquired (caller should refresh), or a
  /// [Future] that completes when the current lock holder finishes.
  static Future<void>? _tryLock() {
    if (_completer != null) return _completer!.future;
    _completer = Completer<void>();
    return null;
  }

  /// Releases the lock and wakes any waiters.
  static void _unlock() {
    final c = _completer;
    _completer = null;
    c?.complete();
  }

  /// Quick check: is there a stored access token that hasn't expired?
  static Future<bool> _tokenIsValid() async {
    final s = AuthSession();
    final token = await s.getToken();
    if (token == null || token.isEmpty) return false;
    return !await s.isAccessTokenExpired();
  }
}
