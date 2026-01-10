class TeacherModel {
  final String id;
  final String userId;
  final String? department;
  final String? designation;

  TeacherModel({
    required this.id,
    required this.userId,
    this.department,
    this.designation,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'department': department,
      'designation': designation,
    };
  }
}
