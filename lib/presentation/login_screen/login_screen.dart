import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'widgets/role_selection_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoginMode = true;
  String _selectedRole = 'student';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final authService = AuthService();
      if (_isLoginMode) {
        await authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (!mounted) return;
        final role = await authService.getUserRole();

        if (!mounted) return;
        print('LOGIN: Navigating with role: $role');

        if (role == 'teacher') {
          Navigator.pushReplacementNamed(context, AppRoutes.teacherDashboard);
        } else if (role == 'student') {
          final supabase = Supabase.instance.client;
          final user = supabase.auth.currentUser;
          if (user != null) {
            final studentRecord = await supabase
                .from('students')
                .select()
                .eq('user_id', user.id)
                .maybeSingle();

            if (studentRecord != null &&
                studentRecord['roll_no'] != null &&
                studentRecord['roll_no'].toString().isNotEmpty) {
              Navigator.pushReplacementNamed(
                  context, AppRoutes.studentAttendance);
            } else {
              print('LOGIN: Profile incomplete, redirecting to setup');
              Navigator.pushReplacementNamed(
                  context, AppRoutes.studentProfileSetup);
            }
          } else {
            Navigator.pushReplacementNamed(
                context, AppRoutes.studentProfileSetup);
          }
        } else {
          print('LOGIN: Role unknown, redirecting to profile setup');
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.studentProfileSetup,
          );
        }
      } else {
        await authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          _selectedRole,
        );

        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.mark_email_unread_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('Verify Your Email'),
              ],
            ),
            content: const Text(
              'A verification link has been sent to your email. Please verify your email before signing in.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        setState(() {
          _isLoginMode = true;
          _passwordController.clear();
        });
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'An unexpected error occurred';
      if (e is AuthException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }

      if (errorMessage.toLowerCase().contains('already registered')) {
        errorMessage =
            'An account with this email already exists. Please sign in instead.';
      }

      _showErrorDialog(
        _isLoginMode ? 'Login Failed' : 'Sign Up Failed',
        errorMessage,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final authService = AuthService();
      final response = await authService.signInWithGoogle();

      if (response == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      String? role = await authService.getUserRole();

      if (!mounted) return;

      if (role == null) {
        final selectedRole = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const RoleSelectionDialog(),
        );

        if (selectedRole != null && mounted) {
          await authService.updateUserRole(selectedRole);
          role = selectedRole;
        } else {
          role = 'student';
          await authService.updateUserRole(role);
        }
      }

      if (!mounted) return;

      if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, AppRoutes.teacherDashboard);
      } else {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;
        if (user != null) {
          final studentRecord = await supabase
              .from('students')
              .select()
              .eq('user_id', user.id)
              .maybeSingle();

          if (studentRecord != null &&
              studentRecord['roll_no'] != null &&
              studentRecord['roll_no'].toString().isNotEmpty) {
            Navigator.pushReplacementNamed(
                context, AppRoutes.studentAttendance);
          } else {
            print('LOGIN: Profile incomplete, redirecting to setup');
            Navigator.pushReplacementNamed(
                context, AppRoutes.studentProfileSetup);
          }
        } else {
          Navigator.pushReplacementNamed(
              context, AppRoutes.studentProfileSetup);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Authentication Failed', 'Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: CyberGridBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Desktop Layout (Split-screen)
                if (constraints.maxWidth > 900) {
                  return Row(
                    children: [
                      // Left Side: Branding Hero
                      Expanded(
                        flex: 5,
                        child: _buildDesktopBrandingSection(theme, colorScheme),
                      ),
                      // Right Side: Auth Form (Glassmorphic Card)
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Container(
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.03),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 400),
                                child: _buildAuthenticationSection(theme, colorScheme),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // Mobile/Tablet Layout (Centered)
                return Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 4.h,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 2.h),
                            _buildBrandingSection(theme, colorScheme),
                            SizedBox(height: 4.h),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(0.15),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: _buildAuthenticationSection(theme, colorScheme),
                            ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0),
                            SizedBox(height: 3.h),
                            _buildFooterSection(theme, colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // App Logo
        const CustomLogoWidget(size: 130),
        const SizedBox(height: 24),

        // App Name
        Text(
          'AttendEase',
          style: theme.textTheme.displaySmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 4.0,
            
          ),
        ).animate().fadeIn(duration: 500.ms).shimmer(duration: 1000.ms, color: colorScheme.secondary),
        const SizedBox(height: 12),

        // Tagline
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Secure Attendance Marking & AI-Powered Live Analytics',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildDesktopBrandingSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/oursplash.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            theme.scaffoldBackgroundColor.withOpacity(0.8),
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomLogoWidget(size: 160),
            const SizedBox(height: 32),
            Text(
              'AttendEase',
              style: theme.textTheme.displayMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
                
                shadows: [
                  Shadow(color: colorScheme.primary.withOpacity(0.5), blurRadius: 20),
                ],
              ),
            ).animate().fadeIn(duration: 800.ms).shimmer(duration: 2000.ms, color: colorScheme.secondary),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Text(
                'Secure Attendance Marking & AI-Powered Live Analytics',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                  letterSpacing: 1.0,
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationSection(ThemeData theme, ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Field & Role Selector (Sign Up only)
          if (!_isLoginMode) ...[
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              theme: theme,
              colorScheme: colorScheme,
              validator: (val) =>
                  !_isLoginMode && (val == null || val.isEmpty)
                      ? 'Name is required'
                      : null,
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            
            // Cyber Role Selector
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  dropdownColor: colorScheme.surface,
                  items: ['student', 'teacher'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Row(
                        children: [
                          Icon(
                            role == 'student'
                                ? Icons.school_outlined
                                : Icons.badge_outlined,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            role[0].toUpperCase() + role.substring(1),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
          ],

          // Email Field
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            theme: theme,
            colorScheme: colorScheme,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Email is required';
              if (!val.contains('@')) return 'Invalid email';
              return null;
            },
            autofillHints: const [AutofillHints.email],
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),

          // Password Field
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            theme: theme,
            colorScheme: colorScheme,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              if (_isLoginMode) {
                if (val.length < 6) {
                  return 'Password must be at least 6 characters';
                }
              } else {
                if (val.length < 8) return 'Minimum 8 characters required';
                if (!RegExp(r'(?=.*[a-z])').hasMatch(val)) {
                  return 'Must contain a lowercase letter';
                }
                if (!RegExp(r'(?=.*[A-Z])').hasMatch(val)) {
                  return 'Must contain an uppercase letter';
                }
                if (!RegExp(r'(?=.*\d)').hasMatch(val)) {
                  return 'Must contain a number';
                }
                if (!RegExp(r'(?=.*[\W_])').hasMatch(val)) {
                  return 'Must contain a special character';
                }
              }
              return null;
            },
            autofillHints: const [AutofillHints.password],
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // Auth Button (Sign In / Sign Up)
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 8,
                shadowColor: colorScheme.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isLoginMode ? 'INITIALIZE SESSION' : 'REGISTER PROFILE',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),

          // Toggle Mode Link
          TextButton(
            onPressed: () {
              setState(() {
                _isLoginMode = !_isLoginMode;
                _formKey.currentState?.reset();
              });
            },
            child: Text.rich(
              TextSpan(
                text: _isLoginMode
                    ? "New Operator? "
                    : "Existing Operator? ",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                children: [
                  TextSpan(
                    text: _isLoginMode ? 'Register Here' : 'Sign In Here',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: colorScheme.primary.withOpacity(0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR SECURE HUB ACCESS',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: colorScheme.primary.withOpacity(0.15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Google Sign-In Button
          OutlinedButton(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: colorScheme.secondary.withOpacity(0.4),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: colorScheme.secondary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.vpn_key_outlined,
                  size: 20,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Text(
                  'AUTHENTICATE WITH GOOGLE',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    
                    fontSize: 13,
                    letterSpacing: 1.0,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    required ColorScheme colorScheme,
    bool isPassword = false,
    String? Function(String?)? validator,
    Iterable<String>? autofillHints,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: theme.textTheme.bodyLarge?.copyWith(
        
      ),
      validator: validator,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor.withOpacity(0.7),
      ),
    );
  }

  Widget _buildFooterSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          'SECURE PROTOCOL ENABLED',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.4),
            
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 14,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'End-to-End Encryption Mode',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
                
              ),
            ),
          ],
        ),
      ],
    );
  }
}
