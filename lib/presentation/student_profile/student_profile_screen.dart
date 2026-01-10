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
      
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _studentDetails = studentData;
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Student Profile',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Avatar Section
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
                const SizedBox(height: 16),
                Text(
                  _userProfile?.name ?? _authService.currentUser?.email ?? 'Student',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Student Account',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Info Cards
                InkWell(
                  onTap: _showEditRollNumberDialog,
                  child: _buildProfileItem(
                    theme,
                    icon: 'badge',
                    label: 'Roll Number',
                    value: _studentDetails?['student']?['roll_number'] ?? 'Tap to set',
                    isEditable: true,
                  ),
                ),
                const SizedBox(height: 12),
                _buildProfileItem(
                  theme,
                  icon: 'school',
                  label: 'Department',
                  value: 'Computer Science',
                ),
                const SizedBox(height: 12),
                _buildProfileItem(
                  theme,
                  icon: 'class',
                  label: 'Class & Section',
                  value: 'Final Year - Section A',
                ),

                const SizedBox(height: 40),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleLogout,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
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
    final TextEditingController controller = TextEditingController(
      text: _studentDetails?['student']?['roll_number'] ?? '',
    );
    
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
                // Determine if we should optimize optimistically or wait
                Navigator.pop(context);
                final success = await _studentService.updateRollNumber(newRoll);
                if (success) {
                   _loadProfile(); // Reload
                   if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Roll number updated!')),
                     );
                   }
                } else {
                   if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Failed to update roll number.', style: TextStyle(color: Theme.of(context).colorScheme.error))),
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
}
