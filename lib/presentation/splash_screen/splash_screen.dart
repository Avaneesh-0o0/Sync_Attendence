import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../core/app_export.dart';
import '../../services/auth_service.dart' as auth_service;

/// Splash Screen for AttendEase application
/// Provides branded app launch experience while initializing Firebase authentication
/// and determining user navigation path
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  bool _isInitializing = true;
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Setup fade-in animation for logo
  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  /// Initialize app and perform authentication checks
  Future<void> _initializeApp() async {
    try {
      // Simulate Firebase initialization and authentication check
      await Future.delayed(Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _statusMessage = 'Checking authentication...';
      });

      await Future.delayed(Duration(milliseconds: 800));

      if (!mounted) return;

      setState(() {
        _statusMessage = 'Loading preferences...';
      });

      await Future.delayed(Duration(milliseconds: 600));

      if (!mounted) return;

      // Navigate based on authentication status
      await _navigateToNextScreen();
    } catch (e) {
      if (!mounted) return;
      _handleInitializationError();
    }
  }

  /// Navigate to appropriate screen based on authentication status
  Future<void> _navigateToNextScreen() async {
    final auth_service.AuthService authService = auth_service.AuthService();
    final user = authService.currentUser;


    if (user == null) {
      print('SPLASH: No active session, going to Login');
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    print('SPLASH: Session found for ${user.email}, fetching role...');
    try {
      final role = await authService.getUserRole();
      print('SPLASH: Role fetched: $role');

      if (!mounted) return;

      if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, AppRoutes.teacherDashboard);
      } else if (role == 'student') {
        Navigator.pushReplacementNamed(context, AppRoutes.studentAttendance);
      } else {
        print('SPLASH: Role unknown or missing, going to profile setup');
        Navigator.pushReplacementNamed(context, AppRoutes.studentProfileSetup);
      }
    } catch (e) {
      print('SPLASH: Error fetching role: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }


  /// Handle initialization errors
  void _handleInitializationError() {
    setState(() {
      _isInitializing = false;
      _statusMessage = 'Initialization failed';
    });

    // Show retry option after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      if (!mounted) return;
      _showRetryDialog();
    });
  }

  /// Show retry dialog for failed initialization
  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Connection Error'),
        content: Text(
          'Unable to initialize the app. Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isInitializing = true;
                _statusMessage = 'Retrying...';
              });
              _initializeApp();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Deep Slate Blue
              Color(0xFF1E293B), // Slate 800
              Color(0xFF0F172A), // Deep Slate Blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  _buildLogo(theme),
                  const SizedBox(height: 48),
                  _buildAppName(theme),
                  const SizedBox(height: 12),
                  _buildTagline(theme),
                  const Spacer(flex: 3),
                  _buildLoadingIndicator(theme),
                  const SizedBox(height: 24),
                  _buildStatusMessage(theme),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),

      ),
    );
  }

  /// Build animated logo
  Widget _buildLogo(ThemeData theme) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.surface.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(32.0),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'school',
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );

  }

  /// Build app name
  Widget _buildAppName(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'AttendEase',
        style: theme.textTheme.displayMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 4.0,
        ),
      ),
    );

  }

  /// Build tagline
  Widget _buildTagline(ThemeData theme) {
    return Text(
      'Smart Attendance Management',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.secondary,
        letterSpacing: 1.5,
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator(ThemeData theme) {
    return _isInitializing
        ? SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          )
        : const SizedBox.shrink();

  }

  /// Build status message
  Widget _buildStatusMessage(ThemeData theme) {
    return Text(
      _statusMessage,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      ),
    );
  }
}
