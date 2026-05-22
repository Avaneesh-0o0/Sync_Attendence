class AttendanceModel {
  final String id;
  final String sessionId;
  final String studentId;
  final DateTime markedAt;
  final String? deviceId;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.markedAt,
    this.deviceId,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      studentId: json['student_id'] as String,
      markedAt: DateTime.parse(json['marked_at'] as String),
      deviceId: json['device_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'marked_at': markedAt.toIso8601String(),
      'device_id': deviceId,
    };
  }
}
