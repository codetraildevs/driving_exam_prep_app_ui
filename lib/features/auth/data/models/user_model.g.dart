// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => $checkedCreate(
  'UserModel',
  json,
  ($checkedConvert) {
    final val = UserModel(
      id: $checkedConvert('id', (v) => _parseString(v)),
      name: $checkedConvert('fullName', (v) => _parseString(v)),
      phoneNumber: $checkedConvert('phoneNumber', (v) => _parseString(v)),
      role: $checkedConvert('role', (v) => v as String? ?? 'USER'),
      avatarUrl: $checkedConvert('avatar_url', (v) => v as String?),
      dailyStreak: $checkedConvert(
        'daily_streak',
        (v) => (v as num?)?.toInt() ?? 0,
      ),
      lastLogin: $checkedConvert(
        'last_login',
        (v) => _parseNullableDateTime(v as String?),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => _parseDateTime(v as String?),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => _parseDateTime(v as String?),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'name': 'fullName',
    'avatarUrl': 'avatar_url',
    'dailyStreak': 'daily_streak',
    'lastLogin': 'last_login',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.name,
  'phoneNumber': instance.phoneNumber,
  'role': instance.role,
  'avatar_url': ?instance.avatarUrl,
  'daily_streak': instance.dailyStreak,
  'last_login': ?_nullableDateTimeToJson(instance.lastLogin),
  'created_at': _dateTimeToJson(instance.createdAt),
  'updated_at': _dateTimeToJson(instance.updatedAt),
};
