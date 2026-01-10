import 'dart:async' as async;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'supabase_service.dart';
import 'package:attendence/data/models/session_model.dart';
import 'package:attendence/data/models/attendance_model.dart';

enum MarkAttendanceResult { successOnline, successOffline, failure }

class StudentService {
  final SupabaseClient _supabase = SupabaseService.instance.client;
  
  // Stream to notify UI of sync status changes
  final _syncStatusController = async.StreamController<bool>.broadcast();
  async.Stream<bool> get syncStatusStream => _syncStatusController.stream;

  StudentService() {
    // Start auto-sync listener
    Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        syncOfflineData();
      }
    });
  }

  /// Mark Attendance
  Future<MarkAttendanceResult> markAttendance(String sessionId, String method, {String? token}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return MarkAttendanceResult.failure;

    // Validate token if provided (e.g. for QR mode)
    if (token != null) {
      // Here we would normally validate the token against the current time window
      // For now, we'll store it. In a production app, the server should validate this.
    }

    // 1. Get Student Profile for rich records (Requested by user)
    // In a real app, we might cache this in Hive to ensure it's available offline
    Map<String, String> studentDetails = await _getStoredStudentDetails();

    // Data matching 'attendance' table in Supabase
    final attendanceData = {
      'session_id': sessionId,
      'student_id': userId,
      'verification_method': method,
      'marked_at': DateTime.now().toIso8601String(),
      'status': 'present',
      'student_name': studentDetails['name'] ?? 'Unknown',
      'roll_number': studentDetails['roll_number'] ?? 'N/A',
      'synced': false,
    };

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.any((r) => r == ConnectivityResult.none)) {
      // Offline: Save to Hive
      try {
        final box = await Hive.openBox('offline_attendance');
        await box.add(attendanceData);
        _syncStatusController.add(true); // Notify UI that we have pending data
        return MarkAttendanceResult.successOffline;
      } catch (e) {
        return MarkAttendanceResult.failure;
      }
    }

    try {
      await _supabase.from('attendance').insert(attendanceData);
      return MarkAttendanceResult.successOnline;
    } catch (e) {
      // If error (e.g. timeout), save locally
      try {
        final box = await Hive.openBox('offline_attendance');
        await box.add(attendanceData);
        _syncStatusController.add(true);
        return MarkAttendanceResult.successOffline;
      } catch (innerE) {
        return MarkAttendanceResult.failure;
      }
    }
  }

  /// Sync Offline Data
  Future<void> syncOfflineData() async {
    try {
      final box = await Hive.openBox('offline_attendance');
      if (box.isEmpty) {
        _syncStatusController.add(false);
        return;
      }

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.any((r) => r == ConnectivityResult.none)) return;

      _syncStatusController.add(true); // Start syncing
      final keysToDelete = [];

      for (var key in box.keys) {
        final data = Map<String, dynamic>.from(box.get(key));
        final syncData = {...data};
        syncData.remove('synced'); // Remove UI helper before upload

        try {
          await _supabase.from('attendance').insert(syncData);
          keysToDelete.add(key);
        } catch (e) {
          print('SYNC_SERVICE: Failed to sync record $key: $e');
        }
      }

      await box.deleteAll(keysToDelete);
      _syncStatusController.add(false); // Finished syncing
    } catch (e) {
      print('SYNC_SERVICE: Sync error: $e');
      _syncStatusController.add(false);
    }
  }

  /// Fetch Attendance History
  Future<List<AttendanceModel>> getAttendanceHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await _supabase
          .from('attendance')
          .select('*, sessions(start_time, classes(name, subject_code))')
          .eq('student_id', userId)
          .order('marked_at', ascending: false);

      return (data as List).map((e) => AttendanceModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get Active Session
  Future<SessionModel?> getActiveSession() async {
    try {
      final response = await _supabase
          .from('sessions')
          .select('*, classes(name, subject_code), teachers(users(name))')
          .eq('is_active', true)
          .order('start_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return SessionModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get student profile including roll number
  Future<Map<String, dynamic>?> getStudentProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final userResponse = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final studentResponse = await _supabase
          .from('students')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (userResponse != null && studentResponse != null) {
        // Cache for offline use
        final box = await Hive.openBox('student_profile');
        await box.put('name', userResponse['name']);
        await box.put('roll_number', studentResponse['roll_number']);
        await box.put('class', studentResponse['class_name'] ?? ''); // or similar

        return {
          'user': userResponse,
          'student': studentResponse,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>> _getStoredStudentDetails() async {
    try {
      final box = await Hive.openBox('student_profile');
      return {
        'name': box.get('name') ?? '',
        'roll_number': box.get('roll_number') ?? '',
        'class': box.get('class') ?? '',
      };
    } catch (e) {
      return {};
    }
  }

  /// Update Student Roll Number
  Future<bool> updateRollNumber(String newRollNumber) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _supabase
          .from('students')
          .update({'roll_number': newRollNumber})
          .eq('user_id', userId);
      
      // Update cache
      final box = await Hive.openBox('student_profile');
      await box.put('roll_number', newRollNumber);
      
      return true;
    } catch (e) {
      print('STUDENT_SERVICE: Error updating roll number: $e');
      return false;
    }
  }

  /// Get Session Details by ID
  Future<SessionModel?> getSessionById(String sessionId) async {
    try {
      final response = await _supabase
          .from('sessions')
          .select('*, classes(name, subject_code), teachers(users(name))')
          .eq('id', sessionId)
          .maybeSingle();

      if (response == null) return null;
      return SessionModel.fromJson(response);
    } catch (e) {
      print('STUDENT_SERVICE: Error fetching session by ID: $e');
      return null;
    }
  }
}
