import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../services/teacher_service.dart';
import './widgets/profile_overview_card_widget.dart';
import './widgets/recent_activity_item_widget.dart';
import '../../services/notification_service.dart';
import '../../services/profile_service.dart';
import '../../data/models/notification_model.dart';

/// Teacher Dashboard Screen
/// Overhauled to implement Minimal Cyberpunk UI, glassmorphic subject drawers, and telemetry readouts.
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

  final Map<String, dynamic> teacherProfile = {
    "name": "Teacher",
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

          teacherProfile["totalClasses"] = grouped.keys.length;
          teacherProfile["activeSessions"] = recent
              .where((s) => s['status'] == 'active' || s['is_active'] == true)
              .length;

          _isRefreshing = false;
        });
      }
    } catch (e) {
      print('DASHBOARD_ERROR: $e');
    }
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
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NOTIFICATIONS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: colorScheme.primary,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        _notificationService.markAllAsRead();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'MARK ALL READ',
                        style: TextStyle(
                          
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.secondary,
                        ),
                      ),
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
                              Icons.notifications_off_outlined,
                              size: 48,
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'ALL NETWORKS QUIET',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.4),
                                    
                                    letterSpacing: 1.0,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => Divider(
                        color: colorScheme.primary.withOpacity(0.1),
                      ),
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        final highlightColor = n.isRead
                            ? colorScheme.onSurface.withOpacity(0.4)
                            : colorScheme.primary;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: n.isRead 
                                ? colorScheme.surface
                                : colorScheme.primary.withOpacity(0.08),
                            child: Icon(
                              _getIconForType(n.type),
                              color: highlightColor,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            n.title,
                            style: TextStyle(
                              
                              fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                              color: n.isRead ? colorScheme.onSurface.withOpacity(0.7) : Colors.white,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.message,
                                style: TextStyle(
                                  
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(n.createdAt),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.4),
                                      
                                      fontSize: 9,
                                    ),
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
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'session_start':
        return Icons.rocket_launch_outlined;
      case 'attendance_alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}M AGO';
    if (diff.inHours < 24) return '${diff.inHours}H AGO';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final dt = DateTime.parse(timestamp.toString());
      return DateFormat('dd MMM yyyy').format(dt).toUpperCase();
    } catch (_) {
      return 'N/A';
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final dt = DateTime.parse(timestamp.toString());
      return DateFormat('hh:mm a').format(dt).toUpperCase();
    } catch (_) {
      return 'N/A';
    }
  }

  void _handleSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'SETTINGS DIRECTORY LINKING IN PROGRESS',
          style: TextStyle( color: Theme.of(context).colorScheme.primary),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showAddClassDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    final subjectCodeController = TextEditingController();
    final nameController = TextEditingController();
    final totalStudentsController = TextEditingController(text: '50');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'NEW CLASS DIRECTORY',
          style: TextStyle(color: colorScheme.primary,  fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(),
              decoration: const InputDecoration(
                labelText: 'Class Identifier (e.g. CS-A)',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subjectCodeController,
              style: const TextStyle(),
              decoration: const InputDecoration(
                labelText: 'Subject Name (e.g. Cryptography)',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: totalStudentsController,
              style: const TextStyle(),
              decoration: const InputDecoration(
                labelText: 'Max Headcount',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ABORT',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && subjectCodeController.text.isNotEmpty) {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('LINKING CLOUD CLASS SYSTEM...')),
                 );

                 final int? total = int.tryParse(totalStudentsController.text);

                 await _teacherService.getOrCreateClass(
                   subjectCodeController.text.trim(),
                   nameController.text.trim(),
                   totalStudents: total ?? 50,
                 );

                 await _loadDashboardData();
                 
                 if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CLASS SUCCESSFULLY RECORDED.')),
                   );
                 }
              }
            },
            child: const Text('LINK CLASS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: StreamBuilder<List<NotificationModel>>(
          stream: _notificationService.getNotificationStream(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data?.where((n) => !n.isRead).length ?? 0;
            return CustomAppBar.teacherDashboard(
              title: 'TEACHER HUB',
              onNotificationPressed: _handleNotifications,
              onSettingsPressed: _handleSettings,
              notificationCount: unreadCount,
            );
          },
        ),
      ),
      body: CyberGridBackground(
        child: RefreshIndicator(
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          onRefresh: _handleRefresh,
          child: Responsive(
            mobile: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: _buildDashboardTab(theme),
              ),
            ),
            tablet: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: _buildDashboardTab(theme),
              ),
            ),
            desktop: Row(
              children: [
                DesktopSidebar(
                  currentIndex: _currentBottomNavIndex,
                  onIndexChanged: _handleBottomNavTap,
                  role: 'teacher',
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: _buildDashboardTab(theme),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Responsive.isDesktop(context) ? null : FloatingActionButton.extended(
        onPressed: _handleNewSession,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add_box_outlined, size: 20),
        label: Text(
          'NEW RUNTIME',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onPrimary,
            
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ).animate().scale(delay: 400.ms, duration: 300.ms, curve: Curves.bounceOut),
      bottomNavigationBar: Responsive.isDesktop(context) ? null : CustomBottomBar.teacher(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
        activeSessionCount: teacherProfile["activeSessions"] as int?,
      ),
    );
  }

  Widget _buildDashboardTab(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
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

            // Classes & Subjects Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LINKED SYSTEMS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddClassDialog,
                  icon: Icon(Icons.add_link_outlined, size: 16, color: colorScheme.primary),
                  label: Text(
                    'ADD CLASS',
                    style: TextStyle(
                      
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            // Grouped Classes Accordion
            if (_groupedClasses.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    'NO CLASSES DEPLOYED YET',
                    style: TextStyle(
                      
                      color: colorScheme.onSurface.withOpacity(0.4),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 450.ms),
            ] else ...[
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _groupedClasses.keys.map((className) {
                  final index = _groupedClasses.keys.toList().indexOf(className);
                  final subjects = _groupedClasses[className]!;
                  final isDesktop = Responsive.isDesktop(context);
                  
                  return Container(
                    width: isDesktop ? 450 : double.infinity,
                    margin: isDesktop ? EdgeInsets.zero : EdgeInsets.only(bottom: 1.5.h),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.15),
                        width: 1.0,
                      ),
                    ),
                    child: Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: colorScheme.primary,
                        collapsedIconColor: colorScheme.onSurface.withOpacity(0.5),
                        title: Text(
                          className.toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        subtitle: Text(
                          '${subjects.length} REGISTRATION SYSTEM(S)',
                          style: TextStyle(
                            
                            fontSize: 10,
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primary.withOpacity(0.08),
                          child: Icon(Icons.hub_outlined, color: colorScheme.primary, size: 18),
                        ),
                        children: [
                          Divider(color: colorScheme.primary.withOpacity(0.1), height: 1),
                          ...subjects.map((s) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: colorScheme.secondary.withOpacity(0.08),
                                child: Icon(Icons.subtitles_outlined, size: 14, color: colorScheme.secondary),
                              ),
                              title: Text(
                                (s['subject_code'] ?? 'No Subject').toString().toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ), 
                              subtitle: Text(
                                (s['semester'] ?? 'CURRENT SEMESTER').toString().toUpperCase(),
                                style: TextStyle(
                                  
                                  fontSize: 10,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ), 
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.analytics_outlined, color: colorScheme.primary, size: 18),
                                    tooltip: 'Analytics Reports',
                                    onPressed: () => _handleViewReports({
                                      'id': s['id'],
                                      'name': s['name'],
                                      'subjectCode': s['subject_code'],
                                    }),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios, size: 12, color: colorScheme.onSurface.withOpacity(0.4)),
                                ],
                              ),
                              onTap: () => _handleStartSession({
                                'id': s['id'],
                                'name': s['name'],
                                'subjectCode': s['subject_code'],
                              }),
                            );
                          }),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 80).ms, duration: 400.ms).slideY(begin: 0.05, end: 0);
                }).toList(),
              ),
            ],
            SizedBox(height: 3.h),

            // Recent Activity Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RUNTIME JOURNAL',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'VIEW ARCHIVES',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.secondary,
                      
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            // Recent Activity List
            if (_recentActivity.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    'JOURNAL EMPTY',
                    style: TextStyle(
                      
                      color: colorScheme.onSurface.withOpacity(0.4),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 450.ms),
            ] else ...[
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _recentActivity.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  final isDesktop = Responsive.isDesktop(context);
                  
                  final displayActivity = {
                    "id": activity['id'],
                    "subjectName": activity['classes']?['name'] ?? 'Subject',
                    "subjectCode": activity['classes']?['subject_code'] ?? '',
                    "status": (activity['is_active'] == true) ? "active" : "completed",
                    "sessionDate": _formatDate(activity['start_time']),
                    "sessionTime": _formatTime(activity['start_time']),
                    "attendancePercentage": 0.0,
                    "attendanceCount": 0,
                    "totalStudents": activity['classes']?['total_students'] ?? 0,
                    "duration": "${activity['duration_minutes'] ?? 0} MIN",
                  };

                  return Container(
                    width: isDesktop ? 450 : double.infinity,
                    child: RecentActivityItemWidget(
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
                    ).animate().fadeIn(delay: (index * 80).ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
                  );
                }).toList(),
              ),
            ],
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
