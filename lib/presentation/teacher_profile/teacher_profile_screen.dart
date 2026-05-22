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
                                  _userProfile?.name ?? 'Teacher',
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
                                    'TEACHER',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOutCubic).slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

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
                                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  theme,
                                  icon: Icons.history,
                                  label: 'Sessions',
                                  value: '$_totalSessions',
                                  color: theme.colorScheme.secondary,
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

                          // ── Personal Information Section ──
                          _buildSectionHeader(theme, 'Personal Information', Icons.person_outline)
                              .animate().fadeIn(delay: 450.ms, duration: 300.ms).slideX(begin: -0.05, end: 0, delay: 450.ms),
                          const SizedBox(height: 12),
                          _buildEditableField(
                            theme,
                            icon: Icons.person,
                            label: 'Full Name',
                            controller: _nameController,
                          ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 500.ms),
                          const SizedBox(height: 12),
                          _buildEditableField(
                            theme,
                            icon: Icons.school,
                            label: 'Department',
                            controller: _departmentController,
                            hint: 'e.g. Computer Science',
                          ).animate().fadeIn(delay: 550.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 550.ms),
                          const SizedBox(height: 12),
                          _buildEditableField(
                            theme,
                            icon: Icons.phone,
                            label: 'Phone Number',
                            controller: _phoneController,
                            hint: 'e.g. +91 98765 43210',
                            keyboardType: TextInputType.phone,
                          ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 600.ms),
                          const SizedBox(height: 12),
                          _buildEditableField(
                            theme,
                            icon: Icons.location_on_outlined,
                            label: 'Office / Cabin',
                            controller: _officeController,
                            hint: 'e.g. Room 305, Block A',
                          ).animate().fadeIn(delay: 650.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 650.ms),

                          const SizedBox(height: 24),

                          // ── Account Information Section ──
                          _buildSectionHeader(theme, 'Account Information', Icons.info_outline)
                              .animate().fadeIn(delay: 700.ms, duration: 300.ms).slideX(begin: -0.05, end: 0, delay: 700.ms),
                          const SizedBox(height: 12),
                          _buildReadOnlyField(
                            theme,
                            icon: Icons.email_outlined,
                            label: 'Email Address',
                            value: user?.email ?? 'N/A',
                          ).animate().fadeIn(delay: 750.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 750.ms),
                          const SizedBox(height: 12),
                          _buildReadOnlyField(
                            theme,
                            icon: Icons.badge_outlined,
                            label: 'Role',
                            value: _userProfile?.role.toUpperCase() ?? 'TEACHER',
                          ).animate().fadeIn(delay: 800.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 800.ms),
                          const SizedBox(height: 12),
                          _buildReadOnlyField(
                            theme,
                            icon: Icons.fingerprint,
                            label: 'User ID',
                            value: _userProfile?.id.substring(0, 8) ?? 'N/A',
                          ).animate().fadeIn(delay: 850.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 850.ms),

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
                          ).animate().fadeIn(delay: 900.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, delay: 900.ms),

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
                          ).animate().fadeIn(delay: 950.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, delay: 950.ms),
                          const SizedBox(height: 32),
                        ],
                      ),
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
