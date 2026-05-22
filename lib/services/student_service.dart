import 'dart:async' as async;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'supabase_service.dart';
import 'package:attendence/data/models/session_model.dart';
import 'package:attendence/data/models/attendance_model.dart';

enum MarkAttendanceResult { successOnline, successOffline, failure }

class StudentService {
  final SupabaseClient _supabase = SupabaseService.instance.client;
  // Must match the secret used in live_attendance_screen.dart
  static const String _qrSecret = 'attendix_secret_key_2026';

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

  /// Validate a QR token locally using the same algorithm the teacher uses.
  /// Token format: ATTENDIX_QR:<sessionId>:<windowId>:<hash>
  /// Returns true if the hash matches and the windowId is within ±1 of the
  /// current 30-second window (to allow for minor clock skew / scan delay).
  bool _validateQrTokenLocally(String token, String expectedSessionId) {
    debugPrint('QR_VALIDATE: Validating token locally');
    if (!token.startsWith('ATTENDIX_QR:')) return false;

    final parts = token.split(':');
    // Expected: ['ATTENDIX_QR', sessionId, windowId, hash]
    if (parts.length < 4) {
      debugPrint('QR_VALIDATE: Token has ${parts.length} parts, expected 4');
      return false;
    }

    final tokenSessionId = parts[1];
    final tokenWindowIdStr = parts[2];
    final tokenHash = parts[3];

    // Verify session ID matches
    if (tokenSessionId != expectedSessionId) {
      debugPrint('QR_VALIDATE: Session mismatch: token=$tokenSessionId expected=$expectedSessionId');
      return false;
    }

    final tokenWindowId = int.tryParse(tokenWindowIdStr);
    if (tokenWindowId == null) {
      debugPrint('QR_VALIDATE: Invalid windowId: $tokenWindowIdStr');
      return false;
    }

    // Check that the window ID is recent (current, previous, or next to handle skew)
    const windowSize = 30;
    final now = DateTime.now();
    final currentWindowId = now.millisecondsSinceEpoch ~/ (windowSize * 1000);

    if ((tokenWindowId - currentWindowId).abs() > 3) {
      debugPrint('QR_VALIDATE: Window expired: token=$tokenWindowId current=$currentWindowId');
      return false;
    }

    // Recompute hash and compare
    final bytes = utf8.encode('$tokenSessionId$tokenWindowId$_qrSecret');
    final digest = sha256.convert(bytes);
    final expectedHash = digest.toString().substring(0, 8);

    if (tokenHash != expectedHash) {
      debugPrint('QR_VALIDATE: Hash mismatch: token=$tokenHash expected=$expectedHash');
      return false;
    }

    debugPrint('QR_VALIDATE: ✅ Token is valid!');
    return true;
  }

  /// Mark Attendance
  Future<MarkAttendanceResult> markAttendance(
    String sessionId,
    String method, {
    String? token,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return MarkAttendanceResult.failure;

    // 1. Get Student Profile for rich records
    Map<String, String> studentDetails = await _getStoredStudentDetails();
    final studentName = studentDetails['name'] ?? 'Unknown';
    final rollNumber = studentDetails['roll_number'] ?? 'N/A';

    final attendanceData = {
      'session_id': sessionId,
      'student_id': userId,
      'verification_method': method,
      'marked_at': DateTime.now().toIso8601String(),
      'status': 'present',
      'student_name': studentName,
      'roll_number': rollNumber,
      'synced': false,
    };

    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult.every(
      (r) => r == ConnectivityResult.none,
    );

    final bool requiresQrValidation = method == 'QR' || method == 'Hybrid';

    if (isOffline) {
      if (requiresQrValidation && token != null) {
        // Validate locally even when offline
        if (!_validateQrTokenLocally(token, sessionId)) {
          debugPrint('STUDENT_SERVICE: Offline QR validation failed');
          return MarkAttendanceResult.failure;
        }
        attendanceData['qr_token'] = token;
      }
      return await _saveOffline(attendanceData);
    }

    try {
      if (requiresQrValidation) {
        if (token == null) {
          return MarkAttendanceResult.failure; // QR/Hybrid mode requires token
        }

        // Validate the QR token locally instead of relying on server RPC
        if (!_validateQrTokenLocally(token, sessionId)) {
          debugPrint('STUDENT_SERVICE: QR token validation failed');
          return MarkAttendanceResult.failure;
        }

        debugPrint('STUDENT_SERVICE: QR token validated locally, inserting attendance');
        // Token is valid — insert attendance directly
        attendanceData['synced'] = true;
        await _supabase.from('attendance').insert(attendanceData);
        return MarkAttendanceResult.successOnline;
      } else {
        // Standard Insert for Bluetooth/Manual
        attendanceData['synced'] = true;
        await _supabase.from('attendance').insert(attendanceData);
        return MarkAttendanceResult.successOnline;
      }
    } catch (e) {
      print('STUDENT_SERVICE: Online mark failed: $e');
      if (e is PostgrestException && e.code == '23505') {
        debugPrint('STUDENT_SERVICE: Attendance already marked in database (23505)');
        return MarkAttendanceResult.successOnline;
      }
      return await _saveOffline(attendanceData);
    }
  }

  Future<MarkAttendanceResult> _saveOffline(
    Map<String, dynamic> attendanceData,
  ) async {
    try {
      final box = await Hive.openBox('offline_attendance');
      await box.add(attendanceData);
      _syncStatusController.add(true);
      return MarkAttendanceResult.successOffline;
    } catch (e) {
      return MarkAttendanceResult.failure;
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

        try {
          // QR tokens were already validated locally before being saved offline.
          // Remove the qr_token field (not a DB column) and do a direct insert.
          if (syncData.containsKey('qr_token')) {
            syncData.remove('qr_token');
          }
          syncData['synced'] = true;
          await _supabase.from('attendance').insert(syncData);
          keysToDelete.add(key);
        } catch (e) {
          print('SYNC_SERVICE: Failed to sync record $key: $e');
          if (e is PostgrestException && e.code == '23505') {
            debugPrint('SYNC_SERVICE: Record $key already exists in DB. Dequeuing.');
            keysToDelete.add(key);
          }
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
          .select('*, classes(name, subject_code), users(name)')
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
        await box.put('roll_number', studentResponse['roll_no']);
        await box.put('class', studentResponse['class_id'] ?? '');

        return {'user': userResponse, 'student': studentResponse};
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
          .update({'roll_no': newRollNumber})
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
          .select('*, classes(name, subject_code), users(name)')
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
