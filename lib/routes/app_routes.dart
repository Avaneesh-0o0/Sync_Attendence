import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/student_attendance_history/student_attendance_history.dart';

import '../presentation/reports_screen/reports_screen.dart';
import '../presentation/teacher_dashboard/teacher_dashboard.dart';
import '../presentation/live_attendance_screen/live_attendance_screen.dart';
import '../presentation/student_attendance_screen/student_attendance_screen.dart';
import '../presentation/student_profile_setup/student_profile_setup.dart';
import '../presentation/start_attendance_screen/start_attendance_screen.dart';
import '../presentation/teacher_profile/teacher_profile_screen.dart';
import '../presentation/student_profile/student_profile_screen.dart';




class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String login = '/login-screen';
  static const String studentAttendanceHistory = '/student-attendance-history';
  static const String reports = '/reports-screen';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String liveAttendance = '/live-attendance-screen';
  static const String studentAttendance = '/student-attendance-screen';
  static const String studentProfileSetup = '/student-profile-setup';
  static const String startAttendance = '/start-attendance-screen';
  static const String teacherProfile = '/teacher-profile';
  static const String studentProfile = '/student-profile';



  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    studentAttendanceHistory: (context) => const StudentAttendanceHistory(),
    reports: (context) => const ReportsScreen(),
    teacherDashboard: (context) => const TeacherDashboard(),
    liveAttendance: (context) => const LiveAttendanceScreen(),
    studentAttendance: (context) => const StudentAttendanceScreen(),
    studentProfileSetup: (context) => const StudentProfileSetup(),
    startAttendance: (context) => const StartAttendanceScreen(),
    teacherProfile: (context) => const TeacherProfileScreen(),
    studentProfile: (context) => const StudentProfileScreen(),


    // TODO: Add your other routes here
  };
}
