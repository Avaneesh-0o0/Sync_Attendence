class AttendanceModel {
  final String id;
  final String sessionId;
  final String studentId;
  final DateTime markedAt;
  final String status; // 'present', 'absent', 'late'
  final String verificationMethod; // 'QR', 'Bluetooth'

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.markedAt,
    required this.status,
    required this.verificationMethod,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      studentId: json['student_id'] as String,
      markedAt: DateTime.parse(json['marked_at'] as String),
      status: json['status'] as String? ?? 'present',
      verificationMethod: json['verification_method'] as String? ?? 'QR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'marked_at': markedAt.toIso8601String(),
      'status': status,
      'verification_method': verificationMethod,
    };
  }
}
