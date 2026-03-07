class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String role;
  final String? avatarUrl;
  final int dailyStreak;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.avatarUrl,
    this.dailyStreak = 0,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'] ?? json['createdAt'];
    final updatedRaw = json['updated_at'] ?? json['updatedAt'];
    final lastLoginRaw = json['last_login'] ?? json['lastLogin'];

    return UserModel(
      id: json['id'] as String,
      name: (json['name'] ?? json['fullName'] ?? '') as String,
      phoneNumber: (json['phoneNumber'] ?? json['phone_number'] ?? '') as String,
      role: (json['role'] ?? 'USER') as String,
      avatarUrl: json['avatar_url'] as String?,
      dailyStreak: json['daily_streak'] as int? ?? 0,
      lastLogin: lastLoginRaw != null
          ? DateTime.tryParse(lastLoginRaw.toString())
          : null,
      createdAt: DateTime.tryParse(createdRaw?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'role': role,
    'avatar_url': avatarUrl,
    'daily_streak': dailyStreak,
    'last_login': lastLogin?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

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
