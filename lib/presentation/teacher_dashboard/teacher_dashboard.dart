import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../services/teacher_service.dart';
import './widgets/profile_overview_card_widget.dart';
import './widgets/recent_activity_item_widget.dart';
import '../../services/notification_service.dart';
import '../../services/profile_service.dart';
import '../../data/models/notification_model.dart';
import 'package:intl/intl.dart';

/// Teacher Dashboard Screen
/// Provides comprehensive attendance management optimized for tablet interfaces
/// with large touch targets and clear information hierarchy
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _currentBottomNavIndex = 0;
  bool _isRefreshing = false;

  final TeacherService _teacherService = TeacherService();
  final NotificationService _notificationService = NotificationService();
  final ProfileService _profileService = ProfileService();
  Map<String, List<Map<String, dynamic>>> _groupedClasses = {};
  List<Map<String, dynamic>> _recentActivity = [];

  // TODO: Fetch real profile
  final Map<String, dynamic> teacherProfile = {
    "name": "Teacher", // Placeholder until profile table integrated
    "department": "Department",
    "avatar": "",
    "semanticLabel": "Teacher Profile",
    "currentSemester": "Spring 2026",
    "totalClasses": 0,
    "averageAttendance": 0.0,
    "activeSessions": 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final grouped = await _teacherService.getClassesGrouped();
      final recent = await _teacherService.getRecentActivity();
      final profile = await _profileService.getProfile();

      if (mounted) {
        setState(() {
          _groupedClasses = grouped;
          _recentActivity = recent;

          if (profile != null) {
            teacherProfile["name"] = profile.name ?? "Teacher";
            teacherProfile["avatar"] = profile.avatarUrl ?? "";
            teacherProfile["department"] = profile.department ?? "Department";
          }

          // Update profile stats
          teacherProfile["totalClasses"] = grouped.keys.length;
          teacherProfile["activeSessions"] = recent
              .where((s) => s['status'] == 'active')
              .length;

          _isRefreshing = false;
        });
      }
    } catch (e) {
      // Handle error, e.g., show a snackbar
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await _loadDashboardData();
  }

  void _handleBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);
  }

  void _handleStartSession(Map<String, dynamic> subject) {
    Navigator.pushNamed(
      context,
      '/start-attendance-screen',
      arguments: subject,
    );
  }

  void _handleViewReports(Map<String, dynamic> subject) {
    Navigator.pushNamed(context, '/reports-screen', arguments: subject);
  }


  void _handleNewSession() {
    Navigator.pushNamed(context, '/start-attendance-screen');
  }

  void _handleNotifications() {
    _showNotificationTray();
  }

  void _showNotificationTray() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      _notificationService.markAllAsRead();
                      Navigator.pop(context);
                    },
                    child: const Text('Mark all as read'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<List<NotificationModel>>(
                stream: _notificationService.getNotificationStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final notifications = snapshot.data ?? [];
                  
                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: n.isRead 
                              ? Theme.of(context).colorScheme.surfaceContainerHighest
                              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            _getIconForType(n.type),
                            color: n.isRead 
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.message),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(n.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        onTap: () {
                          if (!n.isRead) _notificationService.markAsRead(n.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'session_start':
        return Icons.play_circle_outline;
      case 'attendance_alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final dt = DateTime.parse(timestamp.toString());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return 'N/A';
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final dt = DateTime.parse(timestamp.toString());
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return 'N/A';
    }
  }

  void _handleSettings() {
    // Navigate to settings screen (not implemented in this scope)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }


  Future<void> _showAddClassDialog() async {
    final theme = Theme.of(context);
    final subjectCodeController = TextEditingController();
    final nameController = TextEditingController();
    final totalStudentsController = TextEditingController(text: '50');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Class Name (e.g. CS1)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subjectCodeController,
              decoration: const InputDecoration(
                labelText: 'Subject (e.g. Algorithms)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
             const SizedBox(height: 16),
            TextField(
              controller: totalStudentsController,
              decoration: const InputDecoration(
                labelText: 'Total Students',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && subjectCodeController.text.isNotEmpty) {
                 Navigator.pop(context); // Close dialog
                 // Show loading
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Adding class...')),
                 );

                 final int? total = int.tryParse(totalStudentsController.text);

                 await _teacherService.getOrCreateClass(
                   subjectCodeController.text.trim(),
                   nameController.text.trim(),
                   totalStudents: total ?? 50,
                 );

                 // Refresh dashboard
                 await _loadDashboardData();
                 
                 if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Class added successfully!')),
                   );
                 }
              }
            },
            child: const Text('Add Class'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: StreamBuilder<List<NotificationModel>>(
          stream: _notificationService.getNotificationStream(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data?.where((n) => !n.isRead).length ?? 0;
            return CustomAppBar.teacherDashboard(
              title: 'Teacher Dashboard',
              onNotificationPressed: _handleNotifications,
              onSettingsPressed: _handleSettings,
              notificationCount: unreadCount,
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _buildDashboardTab(theme),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleNewSession,
        icon: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onSecondary,
          size: 24,
        ),
        label: Text(
          'New Session',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar.teacher(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
        activeSessionCount: teacherProfile["activeSessions"] as int?,
      ),
    );
  }

  Widget _buildDashboardTab(ThemeData theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Overview Card
            ProfileOverviewCardWidget(teacherProfile: teacherProfile),
            SizedBox(height: 3.h),

            // Classes & Subjects Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Classes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddClassDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Class'),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _groupedClasses.keys.length,
              itemBuilder: (context, index) {
                final className = _groupedClasses.keys.elementAt(index);
                final subjects = _groupedClasses[className]!;
                
                return Card(
                  margin: EdgeInsets.only(bottom: 2.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      className,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('${subjects.length} Subjects'),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.school, color: theme.colorScheme.primary),
                    ),
                    children: subjects.map((s) {
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.book_outlined, size: 20, color: theme.colorScheme.primary),
                        ),
                        title: Text(
                          s['subject_code'] ?? 'No Subject',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ), 
                        // name is the Class Name, already shown in header, so maybe no subtitle or different info
                        subtitle: Text(s['semester'] ?? 'Current Semester'), 
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.bar_chart_rounded),
                              tooltip: 'Reports',
                              onPressed: () => _handleViewReports({
                                'id': s['id'],
                                'name': s['name'],
                                'subjectCode': s['subject_code'],
                              }),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          ],
                        ),
                        onTap: () => _handleStartSession({
                          'id': s['id'],
                          'name': s['name'],
                          'subjectCode': s['subject_code'],
                        }),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            SizedBox(height: 3.h),

            // Recent Activity Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full activity history
                  },
                  child: Text(
                    'View All',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Recent Activity List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentActivity.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final activity = _recentActivity[index];
                final displayActivity = {
                  "id": activity['id'],
                  "subjectName": activity['classes']?['name'] ?? 'Subject',
                  "subjectCode": activity['classes']?['subject_code'] ?? '',
                  "status": activity['is_active'] == true ? "active" : "completed",
                  "sessionDate": _formatDate(activity['start_time']),
                  "sessionTime": _formatTime(activity['start_time']),
                  "attendancePercentage": 0.0, // Default to 0.0 to avoid crash
                  "attendanceCount": 0,
                  "totalStudents": activity['classes']?['total_students'] ?? 0,
                  "duration": "${activity['duration_minutes'] ?? 0} min",
                };

                return RecentActivityItemWidget(
                  activity: displayActivity,
                  onTap: () {
                    if (displayActivity["status"] == "active") {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.liveAttendance,
                        arguments: {
                          'sessionId': displayActivity['id'],
                          'subjectName': displayActivity['subjectName'],
                          'classId': activity['class_id'],
                          'totalStudents': displayActivity['totalStudents'],
                        },
                      );
                    }
                  },
                );
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }


}
