class ClassModel {
  final String id;
  final String name;
  final String subjectCode;
  final String? semester;
  final String? department;
  final String teacherId; // Foreign Key to teachers/users
  final int totalStudents;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.name,
    required this.subjectCode,
    this.semester,
    this.department,
    required this.teacherId,
    this.totalStudents = 0,
    required this.createdAt,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      name: json['name'] as String,
      subjectCode: json['subject_code'] as String? ?? '',
      semester: json['semester'] as String? ?? 'Current',
      department: json['department'] as String?,
      teacherId: json['teacher_id'] as String,
      totalStudents: json['total_students'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject_code': subjectCode,
      'semester': semester,
      'department': department,
      'teacher_id': teacherId,
      'total_students': totalStudents,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
