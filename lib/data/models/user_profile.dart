class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final bool isAdmin;
  final bool isBanned;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    required this.isAdmin,
    this.isBanned = false,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      isBanned: json['is_banned'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    bool? isAdmin,
    bool? isBanned,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      isAdmin: isAdmin ?? this.isAdmin,
      isBanned: isBanned ?? this.isBanned,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
