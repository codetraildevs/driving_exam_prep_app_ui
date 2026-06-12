import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

DateTime _parseDateTime(String? json) {
  if (json == null) return DateTime.now();
  return DateTime.tryParse(json) ?? DateTime.now();
}

String _dateTimeToJson(DateTime date) => date.toIso8601String();

DateTime? _parseNullableDateTime(String? json) {
  if (json == null) return null;
  return DateTime.tryParse(json);
}

String? _nullableDateTimeToJson(DateTime? date) => date?.toIso8601String();

/// Defensive string parser — accepts both String and int/num from the API.
/// Returns empty string for any other type (null, bool, list, etc.).
String _parseString(dynamic value) {
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is num) return value.toString();
  return '';
}

@JsonSerializable()
class UserModel {
  @JsonKey(fromJson: _parseString)
  final String id;

  @JsonKey(name: 'fullName', fromJson: _parseString)
  final String name;

  @JsonKey(fromJson: _parseString)
  final String phoneNumber;
  final String role;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @JsonKey(name: 'daily_streak', defaultValue: 0)
  final int dailyStreak;

  @JsonKey(
    name: 'last_login',
    fromJson: _parseNullableDateTime,
    toJson: _nullableDateTimeToJson,
  )
  final DateTime? lastLogin;

  @JsonKey(
    name: 'created_at',
    fromJson: _parseDateTime,
    toJson: _dateTimeToJson,
  )
  final DateTime createdAt;

  @JsonKey(
    name: 'updated_at',
    fromJson: _parseDateTime,
    toJson: _dateTimeToJson,
  )
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.role = 'USER',
    this.avatarUrl,
    this.dailyStreak = 0,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Support both 'fullName' (API) and 'name' (legacy cached data) keys.
    if (json['name'] is String && json['fullName'] is! String) {
      return _$UserModelFromJson({...json, 'fullName': json['name']});
    }
    return _$UserModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? role,
    String? avatarUrl,
    int? dailyStreak,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
