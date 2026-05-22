import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/profile_avatar_widget.dart';
import '../../services/profile_service.dart';
import '../../services/student_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/attendance_model.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final StudentService _studentService = StudentService();
  int _currentBottomIndex = 2; // Profile index

  bool _isLoading = false;
  UserModel? _userProfile;
  Map<String, dynamic>? _studentDetails;
  List<AttendanceModel> _attendanceHistory = [];

  // Computed stats
  int _totalPresent = 0;
  int _totalSessions = 0;
  double _attendancePercent = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileService.getProfile();
      final studentData = await _studentService.getStudentProfile();
      final history = await _studentService.getAttendanceHistory();

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _studentDetails = studentData;
          _attendanceHistory = history;
          _totalPresent = history.length;
          // Estimate total sessions from unique session IDs in history
          final uniqueSessions = history.map((a) => a.sessionId).toSet();
          _totalSessions = uniqueSessions.length > 0 ? uniqueSessions.length : _totalPresent;
          _attendancePercent = _totalSessions > 0
              ? (_totalPresent / _totalSessions * 100).clamp(0, 100)
              : 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;
    final rollNo = _studentDetails?['student']?['roll_no'] ?? '';
    final className = _studentDetails?['student']?['class_name'] ?? 'Not Set';
    final joinDate = _userProfile?.createdAt;
    final joinStr = joinDate != null
        ? '${_monthName(joinDate.month)} ${joinDate.year}'
        : 'N/A';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'My Profile',
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CyberGridBackground(
              child: RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Hero Card ──
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.surface,
                                  Color.lerp(theme.colorScheme.surface, theme.colorScheme.primary, 0.08)!,
                                ],
                              ),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  spreadRadius: -2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                ProfileAvatarWidget(
                                  initialImageUrl: _userProfile?.avatarUrl,
                                  radius: 50,
                                  onUploadComplete: (url) {
                                    setState(() {
                                      _userProfile = UserModel(
                                        id: _userProfile!.id,
                                        email: _userProfile!.email,
                                        role: _userProfile!.role,
                                        name: _userProfile!.name,
                                        avatarUrl: url,
                                        createdAt: _userProfile!.createdAt,
                                      );
                                    });
                                  },
                                ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                                const SizedBox(height: 18),
                                Text(
                                  _userProfile?.name ?? user?.email ?? 'Student',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'STUDENT',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.tertiary,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                    if (rollNo.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          rollNo,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOutCubic).slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                          const SizedBox(height: 20),

                          // ── Attendance Stats Row ──
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  theme,
                                  icon: Icons.check_circle_outline,
                                  label: 'Present',
                                  value: '$_totalPresent',
                                  color: Colors.green,
                                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  theme,
                                  icon: Icons.percent,
                                  label: 'Attendance',
                                  value: '${_attendancePercent.toStringAsFixed(0)}%',
                                  color: _attendancePercent >= 75
                                      ? Colors.green
                                      : _attendancePercent >= 50
                                          ? Colors.orange
                                          : Colors.red,
                                ).animate().fadeIn(delay: 300.ms, duration: 400.ms).scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  theme,
                                  icon: Icons.calendar_month,
                                  label: 'Joined',
                                  value: joinStr,
                                  color: theme.colorScheme.tertiary,
                                ).animate().fadeIn(delay: 400.ms, duration: 400.ms).scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Academic Information ──
                          _buildSectionHeader(theme, 'Academic Information', Icons.school_outlined)
                              .animate().fadeIn(delay: 450.ms, duration: 300.ms).slideX(begin: -0.05, end: 0, delay: 450.ms),
                          const SizedBox(height: 12),

                          InkWell(
                            onTap: _showEditRollNumberDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: _buildProfileItem(
                              theme,
                              icon: 'badge',
                              label: 'Roll Number',
                              value: rollNo.isNotEmpty ? rollNo : 'Tap to set',
                              isEditable: true,
                            ),
                          ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 500.ms),
                          const SizedBox(height: 12),
                          _buildProfileItem(
                            theme,
                            icon: 'class',
                            label: 'Class',
                            value: className,
                          ).animate().fadeIn(delay: 550.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 550.ms),
                          const SizedBox(height: 12),
                          _buildProfileItem(
                            theme,
                            icon: 'school',
                            label: 'Department',
                            value: _userProfile?.department ?? 'Not Set',
                          ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 600.ms),

                          const SizedBox(height: 24),

                          // ── Account Information ──
                          _buildSectionHeader(theme, 'Account Information', Icons.info_outline)
                              .animate().fadeIn(delay: 650.ms, duration: 300.ms).slideX(begin: -0.05, end: 0, delay: 650.ms),
                          const SizedBox(height: 12),
                          _buildProfileItem(
                            theme,
                            icon: 'email',
                            label: 'Email Address',
                            value: user?.email ?? 'N/A',
                          ).animate().fadeIn(delay: 700.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 700.ms),
                          const SizedBox(height: 12),
                          _buildProfileItem(
                            theme,
                            icon: 'fingerprint',
                            label: 'User ID',
                            value: _userProfile?.id.substring(0, 8) ?? 'N/A',
                          ).animate().fadeIn(delay: 750.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 750.ms),

                          const SizedBox(height: 24),

                          // ── Recent Attendance ──
                          if (_attendanceHistory.isNotEmpty) ...[
                            _buildSectionHeader(theme, 'Recent Attendance', Icons.history)
                                .animate().fadeIn(delay: 800.ms, duration: 300.ms).slideX(begin: -0.05, end: 0, delay: 800.ms),
                            const SizedBox(height: 12),
                            ...(_attendanceHistory.take(5).toList().asMap().entries.map((entry) {
                              final idx = entry.key;
                              final a = entry.value;
                              final itemDelay = 850.ms + (idx * 80).ms;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              a.className ?? 'Class',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              'via ${a.verificationMethod ?? 'N/A'}',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _formatDate(a.markedAt),
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(delay: itemDelay, duration: 400.ms).slideX(begin: 0.05, end: 0, delay: itemDelay);
                            })),
                            const SizedBox(height: 16),
                          ],

                          // ── Logout Button ──
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _handleLogout,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.logout),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.errorContainer,
                                foregroundColor: theme.colorScheme.error,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 950.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, delay: 950.ms),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomBar.student(
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          setState(() => _currentBottomIndex = index);
        },
      ),
    );
  }

  // ── Widgets ──

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    ThemeData theme, {
    required String icon,
    required String label,
    required String value,
    bool isEditable = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isEditable)
            Icon(Icons.edit, size: 16, color: theme.colorScheme.primary),
        ],
      ),
    );
  }

  Future<void> _showEditRollNumberDialog() async {
    final rollNo = _studentDetails?['student']?['roll_no'] ?? '';
    final TextEditingController controller = TextEditingController(text: rollNo);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Roll Number'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Roll Number',
            hintText: 'Enter your roll number',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newRoll = controller.text.trim();
              if (newRoll.isNotEmpty) {
                Navigator.pop(context);
                final success = await _studentService.updateRollNumber(newRoll);
                if (success) {
                  _loadProfile();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Roll number updated!'),
                          ],
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update roll number.')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login-screen');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month];
  }
}
