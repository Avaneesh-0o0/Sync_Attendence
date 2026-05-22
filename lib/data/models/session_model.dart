class SessionModel {
  final String id;
  final String classId;
  final String teacherId;
  final DateTime startTime;
  final DateTime? endTime;
  final String mode; // 'QR', 'BLE', 'HYBRID'
  final bool isActive;
  final String? subject;

  // Joins (optional, populated if select includes them)
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
    this.subject,
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
      subject: json['subject'] as String?,
      className: json['classes']?['name'] ?? json['class_name'],
      teacherName:
          json['users']?['name'] ?? json['teacher_name'], // Nested join helper
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
      'subject': subject,
    };
  }
}
