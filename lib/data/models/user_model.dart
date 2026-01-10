class UserModel {
  final String id;
  final String email;
  final String role; // 'student', 'teacher', 'admin'
  final String? name;
  final String? avatarUrl;
  final String? department;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.avatarUrl,
    this.department,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      department: json['department'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'avatar_url': avatarUrl,
      'department': department,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
