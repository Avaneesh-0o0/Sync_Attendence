class StudentModel {
  final String id;
  final String userId; // Link to auth.users or users table
  final String rollNumber;
  final String? department;
  final String? batch;

  StudentModel({
    required this.id,
    required this.userId,
    required this.rollNumber,
    this.department,
    this.batch,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      rollNumber: json['roll_number'] as String,
      department: json['department'] as String?,
      batch: json['batch'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'roll_number': rollNumber,
      'department': department,
      'batch': batch,
    };
  }
}
