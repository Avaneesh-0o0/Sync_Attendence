class StudentModel {
  final String userId; // Link to auth.users or users table
  final String rollNo;
  final String? classId;
  final DateTime createdAt;

  StudentModel({
    required this.userId,
    required this.rollNo,
    this.classId,
    required this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      userId: json['user_id'] as String,
      rollNo: json['roll_no'] as String,
      classId: json['class_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'roll_no': rollNo,
      'class_id': classId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
