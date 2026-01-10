class SessionModel {
  final String id;
  final String classId;
  final String teacherId;
  final DateTime startTime;
  final DateTime? endTime;
  final String mode; // 'QR', 'Bluetooth', 'Manual'
  final bool isActive;
  final String? qrCode; // Session specific implementation details if needed

  // Joins (optional, populated if select includes them)
  final String? subjectName;
  final String? subjectCode;
  final String? className;
  final String? teacherName;

  SessionModel({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.startTime,
    this.endTime,
    required this.mode,
    required this.isActive,
    this.qrCode,
    this.subjectName,
    this.subjectCode,
    this.className,
    this.teacherName,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      teacherId: json['teacher_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      mode: json['mode'] as String? ?? 'QR',
      isActive: json['is_active'] as bool? ?? true,
      qrCode: json['qr_code'] as String?,
      subjectName: json['classes']?['name'] ?? json['subject_name'], 
      subjectCode: json['classes']?['subject_code'] ?? json['subject_code'],
      className: json['classes']?['name'] ?? json['class_name'],
      teacherName:
          json['teachers']?['users']?['name'] ??
          json['teacher_name'], // Nested join helper
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'teacher_id': teacherId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'mode': mode,
      'is_active': isActive,
      'qr_code': qrCode,
    };
  }
}
