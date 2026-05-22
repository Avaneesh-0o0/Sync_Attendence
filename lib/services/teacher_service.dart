import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'notification_service.dart';

class TeacherService {
  final SupabaseClient _supabase = SupabaseService.instance.client;

  /// Fetch classes for the current teacher
  Future<List<Map<String, dynamic>>> getClasses() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await _supabase
          .from('classes')
          .select()
          .eq('teacher_id', userId);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      // Return empty or throw based on preference
      return [];
    }
  }

  /// Create a new session
  Future<String?> createSession(
    String classId,
    String mode,
    String subject,
  ) async {
    try {
      String dbMode = 'QR';
      if (mode.toLowerCase().contains('ble') ||
          mode.toLowerCase().contains('bluetooth')) {
        dbMode = 'BLE';
      }
      if (mode.toLowerCase().contains('hybrid')) dbMode = 'HYBRID';

      final data = await _supabase
          .from('sessions')
          .insert({
            'class_id': classId,
            'teacher_id': _supabase.auth.currentUser!.id,
            'is_active': true,
            'mode': dbMode,
            'subject': subject,
            'start_time': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final sessionId = data['id'] as String;

      // Send local notification for confirmation
      await NotificationService().sendNotification(
        userId: _supabase.auth.currentUser!.id,
        title: 'Session Started',
        message: 'A new $mode attendance session has been initiated.',
        type: 'session_start',
        payload: {'session_id': sessionId, 'class_id': classId},
      );

      return sessionId;
    } catch (e) {
      print('TEACHER_SERVICE: Error in createSession: $e');
      rethrow;
    }
  }

  /// Ensure the current user exists in the public.users table.
  /// This is a safety net for cases where the DB trigger failed.
  Future<void> _ensureUserInUsersTable() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final existing = await _supabase
          .from('users')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existing == null) {
        // User not in public.users — insert them now
        await _supabase.from('users').insert({
          'id': user.id,
          'email': user.email ?? '',
          'name': user.userMetadata?['name'] ??
              user.userMetadata?['full_name'] ??
              user.email?.split('@').first ??
              'Teacher',
          'role': 'teacher',
        });
        print('TEACHER_SERVICE: Inserted missing user into public.users');
      }
    } catch (e) {
      print('TEACHER_SERVICE: _ensureUserInUsersTable error: $e');
      // If it fails with a unique constraint (already exists), that's fine
    }
  }

  /// Get an existing class ID or create a new one if it doesn't exist
  /// [totalStudents] is updated if class already exists
  Future<String?> getOrCreateClass(
    String subjectCode,
    String className, {
    int totalStudents = 50,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      // Safety net: ensure teacher exists in public.users to prevent FK errors
      await _ensureUserInUsersTable();

      // 1. Fetch all classes for this teacher to do case-insensitive comparison
      final classes = await getClasses();

      final existingClass = classes.cast<Map<String, dynamic>?>().firstWhere(
        (c) =>
            c!['name'].toString().toLowerCase() == className.toLowerCase() &&
            c['subject_code'].toString().toLowerCase() ==
                subjectCode.toLowerCase(),
        orElse: () => null,
      );

      if (existingClass != null) {
        final classId = existingClass['id'] as String;
        // Update total students if different
        if (existingClass['total_students'] != totalStudents) {
          await _supabase
              .from('classes')
              .update({'total_students': totalStudents})
              .eq('id', classId);
        }
        return classId;
      }

      // 2. Create new class if not found
      final newClass = await _supabase
          .from('classes')
          .insert({
            'teacher_id': userId,
            'subject_code': subjectCode,
            'name': className,
            'semester': 'Current', // Default semester
            'total_students': totalStudents,
          })
          .select()
          .single();

      return newClass['id'] as String;
    } catch (e) {
      print('TEACHER_SERVICE: Error in getOrCreateClass: $e');
      rethrow;
    }
  }

  /// Get classes grouped by Name (case-insensitive)
  Future<Map<String, List<Map<String, dynamic>>>> getClassesGrouped() async {
    final classes = await getClasses();
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var c in classes) {
      final key = c['name'].toString().toUpperCase(); // Normalize for map key
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(c);
    }
    return grouped;
  }

  /// Fetch Recent Activity (completed sessions)

  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final classes = await getClasses();
      if (classes.isEmpty) return [];

      final classIds = classes.map((c) => c['id']).toList();

      final sessions = await _supabase
          .from('sessions')
          .select('*, classes(name, subject_code)')
          .filter(
            'class_id',
            'in',
            classIds,
          ) // Note: confirm syntax or use .inFilter('class_id', classIds) if strongly typed
          .order(
            'start_time',
            ascending: false,
          ) // Changed from 'created_at' to matches schema
          .limit(10);

      return List<Map<String, dynamic>>.from(sessions);
    } catch (e) {
      return [];
    }
  }

  /// Get real-time attendance stream for a session
  Stream<List<Map<String, dynamic>>> getAttendanceStream(String sessionId) {
    return _supabase
        .from('attendance')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .order('marked_at', ascending: false)
        .map((data) => data.map((e) => Map<String, dynamic>.from(e)).toList());
  }

  /// End an attendance session
  Future<void> endSession(String sessionId) async {
    try {
      await _supabase
          .from('sessions')
          .update({'is_active': false})
          .eq('id', sessionId);
    } catch (e) {
      print('TEACHER_SERVICE: Error ending session: $e');
    }
  }
}
