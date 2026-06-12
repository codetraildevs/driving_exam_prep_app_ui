import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';

/// Helper to build a minimal valid JSON payload for UserModel.
///
/// All fields required by the constructor (id, name, phoneNumber, createdAt,
/// updatedAt) are provided with sensible defaults that can be overridden
/// per test.
Map<String, dynamic> _baseJson({
  dynamic id = 'user-1',
  dynamic name = 'Test User',
  dynamic phoneNumber = '+250788123456',
  dynamic role = 'USER',
  dynamic avatarUrl,
  int dailyStreak = 0,
  String? lastLogin,
  String createdAt = '2025-01-01T00:00:00',
  String updatedAt = '2025-01-01T00:00:00',
}) {
  return {
    if (id != null) 'id': id,
    if (name != null) 'fullName': name, // default: API format
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    'role': role,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    'daily_streak': dailyStreak,
    if (lastLogin != null) 'last_login': lastLogin,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

void main() {
  group('UserModel.fromJson', () {
    // ──────────────────────────────────────────────────────────────────────
    // Standard API format (using fullName)
    // ──────────────────────────────────────────────────────────────────────
    test('parses standard API format with fullName', () {
      final json = _baseJson(
        id: '061abbe8-09f7-4c7c-8fe4-38ffc38985b3',
        name: 'NIKUZE Grace',
        phoneNumber: '0786012616',
        role: 'ADMIN',
      );
      final user = UserModel.fromJson(json);

      expect(user.id, '061abbe8-09f7-4c7c-8fe4-38ffc38985b3');
      expect(user.name, 'NIKUZE Grace');
      expect(user.phoneNumber, '0786012616');
      expect(user.role, 'ADMIN');
    });

    // ──────────────────────────────────────────────────────────────────────
    // Legacy cached format (using name key instead of fullName)
    // ──────────────────────────────────────────────────────────────────────
    test('parses legacy cached format with name key', () {
      final json = _baseJson(name: null) // remove fullName
        ..remove('fullName')
        ..['name'] = 'Legacy User';
      final user = UserModel.fromJson(json);

      expect(user.name, 'Legacy User');
    });

    test('prefers fullName over name when both are present', () {
      final json = _baseJson(name: 'API User')
        ..['name'] = 'Local User'; // add legacy key too
      final user = UserModel.fromJson(json);

      // fullName (mapped via JsonKey) should win
      expect(user.name, 'API User');
    });

    // ──────────────────────────────────────────────────────────────────────
    // Defensive _parseString converter — id field
    // ──────────────────────────────────────────────────────────────────────
    group('id field (_parseString)', () {
      test('handles String id', () {
        final user = UserModel.fromJson(_baseJson(id: 'abc-123'));
        expect(user.id, 'abc-123');
      });

      test('handles int id', () {
        final user = UserModel.fromJson(_baseJson(id: 12345));
        expect(user.id, '12345');
      });

      test('handles num id', () {
        final user = UserModel.fromJson(_baseJson(id: 67890.0));
        expect(user.id, '67890.0');
      });

      test('handles null id with empty string fallback', () {
        final json = _baseJson(id: null);
        final user = UserModel.fromJson(json);
        expect(user.id, '');
      });

      test('handles bool id with empty string fallback', () {
        final json = _baseJson(id: true);
        final user = UserModel.fromJson(json);
        expect(user.id, '');
      });
    });

    // ──────────────────────────────────────────────────────────────────────
    // Defensive _parseString converter — name field (via fullName)
    // ──────────────────────────────────────────────────────────────────────
    group('name field (_parseString via fullName)', () {
      test('handles String name', () {
        final user = UserModel.fromJson(_baseJson(name: 'Alice'));
        expect(user.name, 'Alice');
      });

      test('handles int name (defensive)', () {
        final json = _baseJson(name: 42);
        final user = UserModel.fromJson(json);
        expect(user.name, '42');
      });

      test('handles null fullName with empty string fallback', () {
        final json = _baseJson(name: null);
        final user = UserModel.fromJson(json);
        expect(user.name, '');
      });
    });

    // ──────────────────────────────────────────────────────────────────────
    // Defensive _parseString converter — phoneNumber field
    // ──────────────────────────────────────────────────────────────────────
    group('phoneNumber field (_parseString)', () {
      test('handles String phoneNumber', () {
        final user = UserModel.fromJson(_baseJson(phoneNumber: '0786012616'));
        expect(user.phoneNumber, '0786012616');
      });

      test('handles int phoneNumber (PHP API edge case)', () {
        final json = _baseJson(phoneNumber: 786012616);
        final user = UserModel.fromJson(json);
        expect(user.phoneNumber, '786012616');
      });

      test('handles leading-zero int phoneNumber via string', () {
        // JSON numbers can't have leading zeros, but if sent as int
        // the leading zero is lost. That's why the API sends it as a string.
        final user = UserModel.fromJson(_baseJson(phoneNumber: '0786012616'));
        expect(user.phoneNumber, '0786012616');
      });

      test('handles null phoneNumber with empty string fallback', () {
        final json = _baseJson(phoneNumber: null);
        final user = UserModel.fromJson(json);
        expect(user.phoneNumber, '');
      });

      test('handles num phoneNumber', () {
        final json = _baseJson(phoneNumber: 786012616.0);
        final user = UserModel.fromJson(json);
        expect(user.phoneNumber, '786012616.0');
      });
    });

    // ──────────────────────────────────────────────────────────────────────
    // role field
    // ──────────────────────────────────────────────────────────────────────
    group('role field', () {
      test('parses role from API', () {
        final user = UserModel.fromJson(_baseJson(role: 'MANAGER'));
        expect(user.role, 'MANAGER');
      });

      test('defaults to USER when role is missing', () {
        final json = _baseJson()..remove('role');
        final user = UserModel.fromJson(json);
        expect(user.role, 'USER');
      });

      test('handles null role with USER default', () {
        final json = _baseJson(role: null);
        final user = UserModel.fromJson(json);
        expect(user.role, 'USER');
      });
    });

    // ──────────────────────────────────────────────────────────────────────
    // daily_streak field
    // ──────────────────────────────────────────────────────────────────────
    group('daily_streak field', () {
      test('parses daily streak as int', () {
        final json = _baseJson(dailyStreak: 5);
        final user = UserModel.fromJson(json);
        expect(user.dailyStreak, 5);
      });

      test('defaults to 0 when missing', () {
        final json = _baseJson()..remove('daily_streak');
        final user = UserModel.fromJson(json);
        expect(user.dailyStreak, 0);
      });
    });

    // ──────────────────────────────────────────────────────────────────────
    // Round-trip serialization (toJson → fromJson)
    // ──────────────────────────────────────────────────────────────────────
    group('round-trip serialization', () {
      test('toJson then fromJson preserves all fields', () {
        final original = UserModel(
          id: 'user-99',
          name: 'Round Trip',
          phoneNumber: '0788123456',
          role: 'USER',
          avatarUrl: 'https://example.com/avatar.png',
          dailyStreak: 7,
          lastLogin: DateTime(2025, 6, 1),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 6, 15),
        );

        final json = original.toJson();
        final restored = UserModel.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.phoneNumber, original.phoneNumber);
        expect(restored.role, original.role);
        expect(restored.avatarUrl, original.avatarUrl);
        expect(restored.dailyStreak, original.dailyStreak);
        expect(restored.lastLogin, original.lastLogin);
        expect(restored.createdAt, original.createdAt);
        expect(restored.updatedAt, original.updatedAt);
      });

      test('round-trip preserves empty optional fields', () {
        final original = UserModel(
          id: 'user-100',
          name: 'No Extras',
          phoneNumber: '0788000000',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final json = original.toJson();
        final restored = UserModel.fromJson(json);

        expect(restored.avatarUrl, isNull);
        expect(restored.lastLogin, isNull);
        expect(restored.dailyStreak, 0);
      });
    });

    // ──────────────────────────────────────────────────────────────────────
    // copyWith
    // ──────────────────────────────────────────────────────────────────────
    group('copyWith', () {
      test('returns same instance when no overrides', () {
        final user = UserModel(
          id: 'u1',
          name: 'Original',
          phoneNumber: '0788000000',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final copy = user.copyWith();
        expect(copy.id, user.id);
        expect(copy.name, user.name);
        expect(copy.phoneNumber, user.phoneNumber);
      });

      test('overrides specified fields', () {
        final user = UserModel(
          id: 'u1',
          name: 'Original',
          phoneNumber: '0788000000',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final copy = user.copyWith(name: 'Updated', role: 'ADMIN');
        expect(copy.name, 'Updated');
        expect(copy.role, 'ADMIN');
        expect(copy.id, 'u1'); // unchanged
        expect(copy.phoneNumber, '0788000000'); // unchanged
      });
    });
  });
}
