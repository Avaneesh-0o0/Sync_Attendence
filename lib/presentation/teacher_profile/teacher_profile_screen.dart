import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../services/teacher_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/profile_avatar_widget.dart';
import '../../data/models/user_model.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final TeacherService _teacherService = TeacherService();

  bool _isLoading = false;
  bool _isSaving = false;
  UserModel? _userProfile;

  // Stats
  int _totalClasses = 0;
  int _totalSessions = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _officeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _officeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final profile = await _profileService.getProfile();

    // Load stats
    final classes = await _teacherService.getClasses();
    final recentActivity = await _teacherService.getRecentActivity();

    if (mounted) {
      setState(() {
        _userProfile = profile;
        _totalClasses = classes.length;
        _totalSessions = recentActivity.length;
        if (profile != null) {
          _nameController.text = profile.name ?? '';
          _departmentController.text = profile.department ?? '';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSaveProfile() async {
    setState(() => _isSaving = true);
    try {
      final success = await _profileService.updateProfile(
        name: _nameController.text.trim(),
        department: _departmentController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _loadProfile();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;
    final joinDate = _userProfile?.createdAt;
    final joinStr = joinDate != null
        ? '${_monthName(joinDate.month)} ${joinDate.year}'
        : 'N/A';

    return Scaffold(
      appBar: CustomAppBar.teacherDashboard(
        title: 'Profile',
        onNotificationPressed: () {},
        onSettingsPressed: () {},
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        // ── Hero Card ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withValues(alpha: 0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
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
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _userProfile?.name ?? 'Teacher',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'TEACHER',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Statistics Row ──
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                theme,
                                icon: Icons.class_outlined,
                                label: 'Classes',
                                value: '$_totalClasses',
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                theme,
                                icon: Icons.history,
                                label: 'Sessions',
                                value: '$_totalSessions',
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                theme,
                                icon: Icons.calendar_month,
                                label: 'Joined',
                                value: joinStr,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Personal Information Section ──
                        _buildSectionHeader(theme, 'Personal Information', Icons.person_outline),
                        const SizedBox(height: 12),
                        _buildEditableField(
                          theme,
                          icon: Icons.person,
                          label: 'Full Name',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 12),
                        _buildEditableField(
                          theme,
                          icon: Icons.school,
                          label: 'Department',
                          controller: _departmentController,
                          hint: 'e.g. Computer Science',
                        ),
                        const SizedBox(height: 12),
                        _buildEditableField(
                          theme,
                          icon: Icons.phone,
                          label: 'Phone Number',
                          controller: _phoneController,
                          hint: 'e.g. +91 98765 43210',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildEditableField(
                          theme,
                          icon: Icons.location_on_outlined,
                          label: 'Office / Cabin',
                          controller: _officeController,
                          hint: 'e.g. Room 305, Block A',
                        ),

                        const SizedBox(height: 24),

                        // ── Account Information Section ──
                        _buildSectionHeader(theme, 'Account Information', Icons.info_outline),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          theme,
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: user?.email ?? 'N/A',
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          theme,
                          icon: Icons.badge_outlined,
                          label: 'Role',
                          value: _userProfile?.role.toUpperCase() ?? 'TEACHER',
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          theme,
                          icon: Icons.fingerprint,
                          label: 'User ID',
                          value: _userProfile?.id.substring(0, 8) ?? 'N/A',
                        ),

                        const SizedBox(height: 28),

                        // ── Save Button ──
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _handleSaveProfile,
                            icon: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(_isSaving ? 'Saving...' : 'Save Profile'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // ── Logout Button ──
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _authService.signOut();
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.login,
                                  (route) => false,
                                );
                              }
                            },
                            icon: const Icon(Icons.logout),
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
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomBar.teacher(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.teacherDashboard);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, AppRoutes.reports);
          }
        },
      ),
    );
  }

  // ── Widgets ──

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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

  Widget _buildEditableField(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit, size: 16, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month];
  }
}
