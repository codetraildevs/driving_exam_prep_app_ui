class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int dailyStreak;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.dailyStreak = 0,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      dailyStreak: json['daily_streak'] as int? ?? 0,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar_url': avatarUrl,
    'daily_streak': dailyStreak,
    'last_login': lastLogin?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    int? dailyStreak,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
