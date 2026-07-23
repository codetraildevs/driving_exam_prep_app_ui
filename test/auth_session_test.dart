import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/shared/network/token_refresh_mutex.dart';
import 'package:traffic_rule_in_rwanda/shared/session/auth_session.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Test helpers
// ═════════════════════════════════════════════════════════════════════════════

/// Builds a minimal HS256 JWT with the given [exp] (epoch seconds).
///
/// The signature is a placeholder — `_isTokenExpired` only inspects the
/// base64url-encoded payload, so any well-formed token works.
String _jwtWithExp(int exp) {
  final header = _base64urlEncode(utf8.encode('{"typ":"JWT","alg":"HS256"}'));
  final payload = _base64urlEncode(
    utf8.encode('{"exp":$exp,"userId":"test","role":"USER"}'),
  );
  final sig = _base64urlEncode(utf8.encode('fake-sig'));
  return '$header.$payload.$sig';
}

/// Returns a JWT whose `exp` is [minutesFromNow] minutes in the future.
String _jwtMinutesFromNow(int minutesFromNow) {
  final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + minutesFromNow * 60;
  return _jwtWithExp(exp);
}

/// Returns a JWT whose `exp` is in the past (expired).
String _expiredJwt() => _jwtWithExp(0); // epoch = Jan 1 1970

/// Returns a JWT without an `exp` claim.
String _jwtWithoutExp() {
  final header = _base64urlEncode(utf8.encode('{"typ":"JWT","alg":"HS256"}'));
  final payload = _base64urlEncode(
    utf8.encode('{"userId":"test","role":"USER"}'), // no exp
  );
  final sig = _base64urlEncode(utf8.encode('fake-sig'));
  return '$header.$payload.$sig';
}

String _malformedJwt() => 'not-a-valid-jwt';

String _base64urlEncode(List<int> bytes) {
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// A valid UserModel for session persistence tests.
UserModel _testUser({String id = 'user-1'}) => UserModel(
      id: id,
      name: 'Test User',
      phoneNumber: '+250788123456',
      role: 'USER',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

// ═════════════════════════════════════════════════════════════════════════════
// AuthSession tests
// ═════════════════════════════════════════════════════════════════════════════

void main() {
  late AuthSession session;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    session = AuthSession();
  });

  // ── getToken / setToken ─────────────────────────────────────────────────
  group('getToken / setToken', () {
    test('returns null when no token is stored', () async {
      expect(await session.getToken(), isNull);
    });

    test('returns the stored token when set', () async {
      await session.setToken('my-access-token');
      expect(await session.getToken(), 'my-access-token');
    });

    test('returns the stored token even when JWT is expired', () async {
      final expired = _expiredJwt();
      await session.setToken(expired);
      // After our fix, getToken() MUST return the stored token regardless
      // of expiry so that API calls always have an auth header.
      expect(await session.getToken(), expired);
    });

    test('returns the stored token when JWT is still valid', () async {
      final valid = _jwtMinutesFromNow(60);
      await session.setToken(valid);
      expect(await session.getToken(), valid);
    });

    test('returns null after setToken(null)', () async {
      await session.setToken('some-token');
      await session.setToken(null);
      expect(await session.getToken(), isNull);
    });

    test('returns null after setToken("")', () async {
      await session.setToken('some-token');
      await session.setToken('');
      expect(await session.getToken(), isNull);
    });
  });

  // ── isAccessTokenExpired ────────────────────────────────────────────────
  group('isAccessTokenExpired', () {
    test('returns false when no token is stored', () async {
      expect(await session.isAccessTokenExpired(), isFalse);
    });

    test('returns true for an expired JWT', () async {
      await session.setToken(_expiredJwt());
      expect(await session.isAccessTokenExpired(), isTrue);
    });

    test('returns false for a valid (non-expired) JWT', () async {
      await session.setToken(_jwtMinutesFromNow(60));
      expect(await session.isAccessTokenExpired(), isFalse);
    });

    test('returns false for a JWT without an exp claim', () async {
      await session.setToken(_jwtWithoutExp());
      // No exp claim → assume valid (safe default)
      expect(await session.isAccessTokenExpired(), isFalse);
    });

    test('returns true for a malformed JWT', () async {
      await session.setToken(_malformedJwt());
      // Malformed → treat as expired (safe default)
      expect(await session.isAccessTokenExpired(), isTrue);
    });

    test('returns false when token is empty string', () async {
      await session.setToken('');
      expect(await session.isAccessTokenExpired(), isFalse);
    });
  });

  // ── getRefreshToken / setRefreshToken ───────────────────────────────────
  group('getRefreshToken / setRefreshToken', () {
    test('returns null when no refresh token is stored', () async {
      expect(await session.getRefreshToken(), isNull);
    });

    test('round-trips a refresh token', () async {
      await session.setRefreshToken('my-refresh-token');
      expect(await session.getRefreshToken(), 'my-refresh-token');
    });

    test('removes key on setRefreshToken(null)', () async {
      await session.setRefreshToken('some-refresh');
      await session.setRefreshToken(null);
      expect(await session.getRefreshToken(), isNull);
    });
  });

  // ── getUser / setUser ───────────────────────────────────────────────────
  group('getUser / setUser', () {
    test('returns null when no user is stored', () async {
      expect(await session.getUser(), isNull);
    });

    test('round-trips a UserModel', () async {
      final user = _testUser();
      await session.setUser(user);
      final restored = await session.getUser();
      expect(restored, isNotNull);
      expect(restored!.id, user.id);
      expect(restored.name, user.name);
      expect(restored.phoneNumber, user.phoneNumber);
    });

    test('removes key on setUser(null)', () async {
      await session.setUser(_testUser());
      await session.setUser(null);
      expect(await session.getUser(), isNull);
    });

    test('recovers gracefully from corrupted JSON', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_json', '{corrupted');
      expect(await session.getUser(), isNull);
    });

    test('handles non-Map JSON gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_json', '"just-a-string"');
      expect(await session.getUser(), isNull);
    });
  });

  // ── hasPersistedSession ─────────────────────────────────────────────────
  group('hasPersistedSession', () {
    test('returns false when nothing is stored', () async {
      expect(await session.hasPersistedSession(), isFalse);
    });

    test('returns true when a refresh token exists', () async {
      await session.setRefreshToken('some-refresh');
      expect(await session.hasPersistedSession(), isTrue);
    });

    test('returns true when a user is cached (even without token)', () async {
      await session.setUser(_testUser());
      expect(await session.hasPersistedSession(), isTrue);
    });

    test('returns true when both token and user exist', () async {
      await session.setToken('some-token');
      await session.setRefreshToken('some-refresh');
      await session.setUser(_testUser());
      expect(await session.hasPersistedSession(), isTrue);
    });

    test('returns false after clear()', () async {
      await session.setRefreshToken('some-refresh');
      await session.setUser(_testUser());
      await session.clear();
      expect(await session.hasPersistedSession(), isFalse);
    });
  });

  // ── clear ───────────────────────────────────────────────────────────────
  group('clear', () {
    test('removes token, refresh token, and user', () async {
      await session.setToken('token');
      await session.setRefreshToken('refresh');
      await session.setUser(_testUser());

      await session.clear();

      expect(await session.getToken(), isNull);
      expect(await session.getRefreshToken(), isNull);
      expect(await session.getUser(), isNull);
    });

    test('is idempotent (safe to call twice)', () async {
      await session.clear();
      // Should not throw
      await session.clear();
      expect(await session.getToken(), isNull);
    });
  });

  // ── getStoredAccessToken (backward compat) ──────────────────────────────
  group('getStoredAccessToken (backward compat)', () {
    test('returns the stored token regardless of expiry', () async {
      final expired = _expiredJwt();
      await session.setToken(expired);
      // After the refactor, getStoredAccessToken() delegates to getToken()
      // which returns the stored token even when expired.
      expect(await session.getStoredAccessToken(), expired);
    });

    test('returns null when no token is stored', () async {
      expect(await session.getStoredAccessToken(), isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  // Offline auth flow — session persistence without network
  // ═════════════════════════════════════════════════════════════════════════

  group('Offline auth flow', () {
    test('hasPersistedSession() returns true with only a cached user', () async {
      // Simulate a user who logged in previously and now has no internet.
      // The user model is cached — should be enough to stay authenticated.
      await session.setUser(_testUser());
      expect(await session.hasPersistedSession(), isTrue);
    });

    test('hasPersistedSession() returns true with only a refresh token', () async {
      // Even if the user fetch never completed, a stored refresh token
      // indicates the user has a valid session.
      await session.setRefreshToken('persistent-refresh');
      expect(await session.hasPersistedSession(), isTrue);
    });

    test('getToken() returns stored JWT even when expired (offline)', () async {
      // When offline, the JWT may be expired. getToken() must return it so
      // that API calls (which will fail anyway) still have an auth header.
      final expired = _expiredJwt();
      await session.setToken(expired);
      expect(await session.getToken(), expired);
    });

    test('getUser() returns cached user when offline', () async {
      // fetchUserProfile() falls back to cached user on network error.
      // This test verifies the cached user is retrievable.
      final user = _testUser(id: 'offline-user');
      await session.setUser(user);
      final restored = await session.getUser();
      expect(restored, isNotNull);
      expect(restored!.id, 'offline-user');
      expect(restored.name, user.name);
      expect(restored.phoneNumber, user.phoneNumber);
    });

    test('clear() removes all session data (simulates logout)', () async {
      // Full session setup
      await session.setToken('token');
      await session.setRefreshToken('refresh');
      await session.setUser(_testUser());

      // Logout
      await session.clear();

      // All data gone — user must re-authenticate
      expect(await session.getToken(), isNull);
      expect(await session.getRefreshToken(), isNull);
      expect(await session.getUser(), isNull);
      expect(await session.hasPersistedSession(), isFalse);
    });

    test('session survives across app restarts (SharedPreferences persistence)',
        () async {
      // Simulate first login
      await session.setToken('persistent-token');
      await session.setRefreshToken('persistent-refresh');
      await session.setUser(_testUser(id: 'persistent-user'));

      // Simulate app restart by creating a fresh AuthSession instance
      // (SharedPreferences data persists between instances)
      final freshSession = AuthSession();

      expect(await freshSession.getToken(), 'persistent-token');
      expect(await freshSession.getRefreshToken(), 'persistent-refresh');
      final cachedUser = await freshSession.getUser();
      expect(cachedUser, isNotNull);
      expect(cachedUser!.id, 'persistent-user');
      expect(await freshSession.hasPersistedSession(), isTrue);
    });

    test('user stays authenticated as long as cached user exists', () async {
      // Scenario: User opens app offline, JWT expired, refresh fails.
      // hasPersistedSession() should return true due to cached user.
      await session.setUser(_testUser());
      await session.setToken(_expiredJwt());

      // isAuthenticated() calls in AuthRepository should observe this:
      expect(await session.hasPersistedSession(), isTrue);
      expect(await session.getToken(), isNotNull); // token still available
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  // TokenRefreshMutex — concurrency scenarios
  // ═════════════════════════════════════════════════════════════════════════

  group('TokenRefreshMutex', () {
    setUp(() async {
      // The shared_preferences mock cache (_store) persists across tests.
      // setMockInitialValues only updates _initialValues, but the cached
      // FakeSharedPreferencesStore still references the OLD map, so
      // remove() calls on the cached instance are the reliable way to
      // clear leaked state between tests.
      final prefs = await SharedPreferences.getInstance();
      for (final key in ['auth_token', 'auth_refresh_token', 'auth_user_json']) {
        await prefs.remove(key);
      }
    });

    test('single caller acquires lock and refreshes', () async {
      var refreshCalled = false;

      final result = await TokenRefreshMutex.runRefresh(() async {
        refreshCalled = true;
        return true;
      });

      expect(refreshCalled, isTrue, reason: 'refresh function must be called');
      expect(result, isTrue, reason: 'must return true on success');
    });

    test('two concurrent callers: first succeeds, second reuses token', () async {
      // Set up a non-expired token (simulating successful first refresh)
      final validToken = _jwtMinutesFromNow(60);
      await session.setToken(validToken);

      var firstCallCount = 0;
      var secondCallCount = 0;

      await Future.wait([
        TokenRefreshMutex.runRefresh(() async {
          firstCallCount++;
          // Store a fresh token so the second caller finds it valid
          await session.setToken(_jwtMinutesFromNow(60));
          return true;
        }),
        TokenRefreshMutex.runRefresh(() async {
          secondCallCount++;
          return true;
        }),
      ]);

      // Only the first caller should have executed the refresh body;
      // the second found the token already valid and returned early.
      expect(firstCallCount, 1);
      expect(secondCallCount, 0);
    });

    test('two concurrent callers: first fails, second retries', () async {
      // No token at all — both callers will find it expired
      var callOrder = <int>[];

      await Future.wait([
        TokenRefreshMutex.runRefresh(() async {
          callOrder.add(1);
          // Store a fresh token so if the other waiter checks, it finds it valid
          await session.setToken(_jwtMinutesFromNow(60));
          return true; // first succeeds
        }),
        TokenRefreshMutex.runRefresh(() async {
          callOrder.add(2);
          return true; // should not be called if first succeeds
        }),
      ]);

      // First caller (1) should have run. The second (2) should have
      // waited, found the token valid, and returned true without running.
      expect(callOrder, [1]);
    });

    test('first fails, second retries and succeeds', () async {
      var attempts = <int>[];

      await Future.wait([
        TokenRefreshMutex.runRefresh(() async {
          attempts.add(1);
          return false; // first fails
        }),
        TokenRefreshMutex.runRefresh(() async {
          attempts.add(2);
          // Store a fresh token for any further waiters
          await session.setToken(_jwtMinutesFromNow(60));
          return true; // second succeeds
        }),
      ]);

      // Both should have attempted because the first failed
      expect(attempts, containsAll([1, 2]));
    });

    test('all callers fail returns false', () async {
      final results = await Future.wait([
        TokenRefreshMutex.runRefresh(() async => false),
        TokenRefreshMutex.runRefresh(() async => false),
      ]);

      expect(results, [false, false]);
    });

    test('mutex resets after refresh completes', () async {
      // Run one refresh successfully
      var firstResult = await TokenRefreshMutex.runRefresh(() async {
        return true;
      });
      expect(firstResult, isTrue);

      // The mutex should be fully released — run another without issues.
      // runRefresh always calls refreshFn when it directly acquires the
      // lock (the callers already verified the token is expired before
      // entering runRefresh). The key assertion is that the mutex does
      // not leak state between sequential calls.
      var secondCalled = false;
      final result = await TokenRefreshMutex.runRefresh(() async {
        secondCalled = true;
        return true;
      });

      expect(secondCalled, isTrue,
          reason: 'sequential call should acquire clean lock and execute');
      expect(result, isTrue);
    });

    test('mutex handles rapid sequential calls', () async {
      // Rapid fire 5 refreshes sequentially — should all succeed
      for (int i = 0; i < 5; i++) {
        final result = await TokenRefreshMutex.runRefresh(() async {
          await session.setToken(_jwtMinutesFromNow(60));
          return true;
        });
        expect(result, isTrue, reason: 'refresh $i should succeed');
      }
    });

    test('returns false when refresh function throws', () async {
      final result = await TokenRefreshMutex.runRefresh(() async {
        throw Exception('network error');
      });

      expect(result, isFalse,
          reason: 'exception in refresh should gracefully return false');
    });
  });
}
