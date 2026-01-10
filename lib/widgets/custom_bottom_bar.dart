import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../routes/app_routes.dart';


/// Navigation item configuration for bottom bar
enum BottomBarItem { dashboard, history, profile }

/// Custom bottom navigation bar for educational attendance app
/// Implements role-based navigation with teacher dashboard and student attendance flow
/// Optimized for one-handed operation with bottom-heavy touch targets
class CustomBottomBar extends StatelessWidget {
  /// Current selected navigation item
  final BottomBarItem currentItem;

  /// Callback when navigation item is tapped
  final ValueChanged<BottomBarItem> onItemTapped;

  /// Whether to show teacher-specific navigation items
  /// When true, shows comprehensive dashboard controls
  /// When false, shows simplified student navigation
  final bool isTeacherMode;

  /// Optional elevation for the bottom bar
  final double? elevation;

  const CustomBottomBar({
    super.key,
    required this.currentItem,
    required this.onItemTapped,
    this.isTeacherMode = false,
    this.elevation,
  });

  /// Factory constructor for teacher dashboard
  factory CustomBottomBar.teacher({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    int? activeSessionCount,
  }) {
    return CustomBottomBar(
      key: key,
      currentItem: BottomBarItemExtension.fromIndex(currentIndex),
      onItemTapped: (item) => onTap(item.index),
      isTeacherMode: true,
    );
  }

  /// Factory constructor for student view
  factory CustomBottomBar.student({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return CustomBottomBar(
      key: key,
      currentItem: BottomBarItemExtension.fromIndex(currentIndex),
      onItemTapped: (item) => onTap(item.index),
      isTeacherMode: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: elevation ?? 8.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80, // Increased from 64
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Adjusted padding
          child: Row(

            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(context),
          ),
        ),
      ),
    );
  }

  /// Build navigation items based on user role
  List<Widget> _buildNavigationItems(BuildContext context) {
    if (isTeacherMode) {
      return [
        _buildNavigationItem(
          context: context,
          item: BottomBarItem.dashboard,
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Dashboard',
          route: AppRoutes.teacherDashboard,
        ),
        _buildNavigationItem(
          context: context,
          item: BottomBarItem.history,
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
          label: 'Reports',
          route: AppRoutes.reports,
        ),
        _buildNavigationItem(
          context: context,
          item: BottomBarItem.profile,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Profile',
          route: AppRoutes.teacherProfile,
        ),


      ];
    } else {
      // Student mode - simplified navigation
      return [
        _buildNavigationItem(
          context: context,
          item: BottomBarItem.dashboard,
          icon: Icons.qr_code_scanner_outlined,
          selectedIcon: Icons.qr_code_scanner,
          label: 'Attendance',
          route: AppRoutes.studentAttendance,
        ),
        _buildNavigationItem(
          context: context,
          item: BottomBarItem.history,
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
          label: 'History',
          route: AppRoutes.studentAttendanceHistory,
        ),
        _buildNavigationItem(
          context: context,
          item: BottomBarItem.profile,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Profile',
          route: AppRoutes.studentProfile,
        ),


      ];
    }
  }

  /// Build individual navigation item with proper touch targets
  Widget _buildNavigationItem({
    required BuildContext context,
    required BottomBarItem item,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required String route,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentItem == item;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              // Provide haptic feedback for navigation
              HapticFeedback.lightImpact();
              onItemTapped(item);

              // Navigate to the corresponding route directly
              Navigator.pushReplacementNamed(context, route);
            }
          },

          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with smooth transition
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    key: ValueKey(isSelected),
                    size: 24,
                    color: isSelected
                        ? colorScheme.primary
                        : theme.bottomNavigationBarTheme.unselectedItemColor,
                  ),
                ),
                SizedBox(height: 4),
                // Label with color transition
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : theme.bottomNavigationBarTheme.unselectedItemColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to easily get navigation item from index
extension BottomBarItemExtension on BottomBarItem {
  int get index {
    switch (this) {
      case BottomBarItem.dashboard:
        return 0;
      case BottomBarItem.history:
        return 1;
      case BottomBarItem.profile:
        return 2;
    }
  }

  static BottomBarItem fromIndex(int index) {
    switch (index) {
      case 0:
        return BottomBarItem.dashboard;
      case 1:
        return BottomBarItem.history;
      case 2:
        return BottomBarItem.profile;
      default:
        return BottomBarItem.dashboard;
    }
  }
}
