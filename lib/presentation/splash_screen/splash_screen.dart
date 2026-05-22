import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart' as auth_service;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      await _navigateToNextScreen();
    } catch (e) {
      if (!mounted) return;
      _navigateToNextScreen(); // default to login on error
    }
  }

  Future<void> _navigateToNextScreen() async {
    final auth_service.AuthService authService = auth_service.AuthService();
    final user = authService.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    try {
      final role = await authService.getUserRole();

      if (!mounted) return;

      if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, AppRoutes.teacherDashboard);
      } else if (role == 'student') {
        Navigator.pushReplacementNamed(context, AppRoutes.studentAttendance);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.studentProfileSetup);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/oursplash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Subtle dark overlay to ensure the logo pops if the splash image is bright
          color: Colors.black.withValues(alpha: 0.3),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Holographic Spinning Ring 1
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF00F5FF).withValues(alpha: 0.6),
                          ),
                          strokeWidth: 2,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                       .rotate(duration: 3000.ms, curve: Curves.linear),
                      
                      // Holographic Spinning Ring 2 (reverse)
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF7C3AED).withValues(alpha: 0.3),
                          ),
                          strokeWidth: 1,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                       .rotate(begin: 1, end: 0, duration: 5000.ms, curve: Curves.linear),

                      // Logo Widget
                      const CustomLogoWidget(size: 130),
                    ],
                  ).animate().fadeIn(duration: 1000.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 1500.ms,
                    curve: Curves.easeOutExpo,
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 1500.ms), 
      ),
    );
  }
}
