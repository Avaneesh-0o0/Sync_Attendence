import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/custom_icon_widget.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

/// Login Screen for AttendEase
/// Implements Google Sign-In authentication with college email validation
/// Optimized for educational institution access with institutional branding
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoginMode = true;
  String _selectedRole = 'student';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      } else {
        await authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          _selectedRole,
        );
      }

      if (!mounted) return;

      // After successful auth, navigate based on role
      // For new signups, use _selectedRole if fetch fails
      // For existing logins, MUST fetch from DB
      String? role;
      if (!_isLoginMode) {
        // Sign up mode: we know the role they just picked
        role = _selectedRole;
      } else {
        // Login mode: fetch from DB
        role = await authService.getUserRole();
      }

      if (!mounted) return;

      print('LOGIN: Navigating with role: $role');

      if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, AppRoutes.teacherDashboard);
      } else if (role == 'student') {
        Navigator.pushReplacementNamed(context, AppRoutes.studentAttendance);
      } else {
        // If role is still missing after login, it might be a legacy user or DB issue
        print('LOGIN: Role unknown, redirecting to profile setup');
        Navigator.pushReplacementNamed(context, AppRoutes.studentProfileSetup);
      }

    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'An unexpected error occurred';
      if (e is AuthException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }

      _showErrorDialog(
        _isLoginMode ? 'Login Failed' : 'Sign Up Failed',
        errorMessage,
      );

      // Add special tip for email confirmation error
      if (errorMessage.toLowerCase().contains('email not confirmed')) {
        print('LOGIN_ERROR: Email confirmation required. Tip: Disable in Supabase Dashboard -> Auth -> Providers -> Email -> Confirm email');
      }
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
        // User cancelled or failed
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      // Optional: Validation
      // if (!_validateEducationalEmail(email)) {
      //   await authService.signOut();
      //   if (!mounted) return;
      //    _showErrorDialog('Invalid Email', 'Please use institutional email.');
      //    setState(() => _isLoading = false);
      //    return;
      // }

      // Get Role
      final role = await authService.getUserRole();

      if (!mounted) return;

      if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, AppRoutes.teacherDashboard);
      } else if (role == 'student') {
        Navigator.pushReplacementNamed(context, AppRoutes.studentAttendance);
      } else {
        // Default to student profile setup if role is missing or new user
        Navigator.pushReplacementNamed(context, AppRoutes.studentProfileSetup);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
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
        // Exit app when back button pressed from login screen
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0A0E27)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Desktop Layout (Split-screen)
                if (constraints.maxWidth > 900) {
                  return Row(
                    children: [
                      // Left Side: Branding
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: SingleChildScrollView(
                            child: _buildBrandingSection(theme, colorScheme),
                          ),
                        ),
                      ),
                      // Right Side: Auth Form (Glassmorphic)
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Container(
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 400),
                                child: _buildAuthenticationSection(
                                  theme,
                                  colorScheme,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // Mobile/Tablet Layout (Centered)
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 4.h,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 4.h),
                            _buildBrandingSection(theme, colorScheme),
                            SizedBox(height: 6.h),
                            _buildAuthenticationSection(theme, colorScheme),
                            SizedBox(height: 4.h),
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
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            final logoSize = (SizerUtil.deviceType == DeviceType.mobile)
                ? 120.0
                : 180.0;
            return Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: colorScheme.primary, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(
                      alpha: _glowAnimation.value * 0.8,
                    ),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: colorScheme.secondary.withValues(
                      alpha: _glowAnimation.value * 0.5,
                    ),
                    blurRadius: 60,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'school',
                  size: logoSize * 0.5,
                  color: colorScheme.primary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // App Name
        Text(
          'AttendEase',
          style: theme.textTheme.displaySmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 3.0,
            fontSize: (SizerUtil.deviceType == DeviceType.mobile) ? 28 : 36,
          ),
        ),
        const SizedBox(height: 16),

        // Tagline
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Smart Attendance Management for Educational Institutions',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.secondary,
                height: 1.4,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticationSection(ThemeData theme, ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Field (Sign Up only)
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: 'person',
                  theme: theme,
                  colorScheme: colorScheme,
                  validator: (val) =>
                      !_isLoginMode && (val == null || val.isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                SizedBox(height: 2.h),
                // Role Selector
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
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
                              CustomIconWidget(
                                iconName: role == 'student'
                                    ? 'school'
                                    : 'person_outline',
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                role[0].toUpperCase() + role.substring(1),
                                style: theme.textTheme.bodyLarge,
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
                ),
                const SizedBox(height: 16),
              ],
            ),
            crossFadeState: _isLoginMode
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Duration(milliseconds: 300),
          ),

          // Email Field
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: 'email',
            theme: theme,
            colorScheme: colorScheme,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Email is required';
              if (!val.contains('@')) return 'Invalid email';
              return null;
            },
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),

          // Password Field
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: 'lock',
            isPassword: true,
            theme: theme,
            colorScheme: colorScheme,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              if (val.length < 6) return 'Min 6 characters';
              return null;
            },
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: 24),

          // Auth Button (Sign In / Sign Up)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
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
                      _isLoginMode ? 'Sign In' : 'Create Account',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Toggle Mode
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
                    ? "Don't have an account? "
                    : "Already have an account? ",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                children: [
                  TextSpan(
                    text: _isLoginMode ? 'Sign Up' : 'Sign In',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Google Sign-In Button (Secondary)
          OutlinedButton(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName:
                      'login', // Reusing login icon, ideally use google brand icon
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue with Google',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
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
    required String icon,
    required ThemeData theme,
    required ColorScheme colorScheme,
    bool isPassword = false,
    String? Function(String?)? validator,
    Iterable<String>? autofillHints,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: theme.textTheme.bodyLarge,
      validator: validator,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: EdgeInsets.all(12),
          child: CustomIconWidget(
            iconName: icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
    );
  }

  Widget _buildFooterSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Divider(
          color: colorScheme.primary.withValues(alpha: 0.3),
          thickness: 1.5,
        ),
        const SizedBox(height: 16),
        Text(
          'Secure Authentication',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'verified_user',
              size: 16,
              color: colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Protected by Google',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
