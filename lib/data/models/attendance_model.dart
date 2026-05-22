class AttendanceModel {
  final String id;
  final String sessionId;
  final String studentId;
  final DateTime markedAt;
  final String? deviceId;
  final String? verificationMethod;
  final String? status;
  final String? studentName;
  final String? rollNumber;

  // Joined from sessions → classes
  final String? className;
  final String? subjectCode;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.markedAt,
    this.deviceId,
    this.verificationMethod,
    this.status,
    this.studentName,
    this.rollNumber,
    this.className,
    this.subjectCode,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    // Parse joined session → class data if available
    final sessions = json['sessions'] as Map<String, dynamic>?;
    final classes = sessions?['classes'] as Map<String, dynamic>?;

    return AttendanceModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      studentId: json['student_id'] as String,
      markedAt: DateTime.parse(json['marked_at'] as String),
      deviceId: json['device_id'] as String?,
      verificationMethod: json['verification_method'] as String?,
      status: json['status'] as String?,
      studentName: json['student_name'] as String?,
      rollNumber: json['roll_number'] as String?,
      className: classes?['name'] as String?,
      subjectCode: classes?['subject_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'marked_at': markedAt.toIso8601String(),
      'device_id': deviceId,
      'verification_method': verificationMethod,
      'status': status,
      'student_name': studentName,
      'roll_number': rollNumber,
    };
  }
}
