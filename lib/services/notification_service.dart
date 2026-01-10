import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/notification_model.dart';
import 'supabase_service.dart';

class NotificationService {
  final SupabaseClient _supabase = SupabaseService.instance.client;

  /// Fetch notifications for the current user
  Future<List<NotificationModel>> getNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await _supabase
          .from('notifications')
          .select()
          .or('user_id.eq.$userId,user_id.is.null')
          .order('created_at', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(data)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('NOTIFICATION_SERVICE: Error fetching notifications: $e');
      return [];
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('NOTIFICATION_SERVICE: Error marking notification as read: $e');
    }
  }

  /// Send a notification with deduplication logic
  Future<void> sendNotification({
    String? userId,
    required String title,
    required String message,
    String type = 'system',
    Map<String, dynamic>? payload,
  }) async {
    try {
      // Simple deduplication: Check if an unread notification with the same title/message exists
      final existing = await _supabase
          .from('notifications')
          .select()
          .eq('title', title)
          .eq('message', message)
          .eq('is_read', false)
          .maybeSingle();

      if (existing != null) {
        print('NOTIFICATION_SERVICE: Skipping duplicate notification');
        return;
      }

      await _supabase.from('notifications').insert({
        if (userId != null) 'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'payload': payload,
      });
    } catch (e) {
      print('NOTIFICATION_SERVICE: Error sending notification: $e');
    }
  }

  /// Mark all notifications as read for current user
  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId);
    } catch (e) {
      print('NOTIFICATION_SERVICE: Error marking all as read: $e');
    }
  }
  
  /// Stream of notifications for real-time updates
  Stream<List<NotificationModel>> getNotificationStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => NotificationModel.fromJson(json))
            .where((n) => n.userId == userId || n.userId == null)
            .toList());
  }
}
