import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/session_model.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final SupabaseClient _supabase;

  AttendanceRepository(this._supabase);

  /// Fetch active sessions for a student's classes
  /// This is a complex query: get sessions where end_time > now or active = true
  /// For simplicity, we just fetch all active sessions for now and filter in UI/Service if needed
  /// Ideally, we'd join with enrollments to only show relevant sessions
  Future<List<SessionModel>> getActiveSessions() async {
    try {
      final now = DateTime.now().toIso8601String();

      // Select sessions that are active OR (have end_time in future)
      final response = await _supabase
          .from('sessions')
          .select('*, classes(name, subject_code), teachers(users(name))')
          .filter('is_active', 'eq', true)
          .order('start_time', ascending: false);

      return (response as List).map((e) => SessionModel.fromJson(e)).toList();
    } catch (e) {
      throw 'Failed to fetch active sessions: $e';
    }
  }

  /// Mark attendance for a session
  Future<AttendanceModel> markAttendance({
    required String sessionId,
    required String studentId,
    required String status,
    required String verificationMethod,
  }) async {
    final response = await _supabase
        .from('attendance')
        .insert({
          'session_id': sessionId,
          'student_id': studentId,
          'marked_at': DateTime.now().toIso8601String(),
          'status': status,
          'verification_method': verificationMethod,
        })
        .select()
        .single();

    return AttendanceModel.fromJson(response);
  }

  /// Get attendance history for a student
  Future<List<AttendanceModel>> getAttendanceHistory(String studentId) async {
    final response = await _supabase
        .from('attendance')
        .select('*, sessions(*, classes(*), teachers(users(name)))')
        .eq('student_id', studentId)
        .order('marked_at', ascending: false);

    return (response as List).map((e) => AttendanceModel.fromJson(e)).toList();
  }
}
