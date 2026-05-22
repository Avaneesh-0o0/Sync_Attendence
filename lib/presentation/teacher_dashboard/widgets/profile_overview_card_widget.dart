import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/profile_avatar_widget.dart';

/// Profile Overview Card Widget
/// Displays teacher profile information and current semester statistics with Cyberpunk SaaS layout
class ProfileOverviewCardWidget extends StatelessWidget {
  final Map<String, dynamic> teacherProfile;

  const ProfileOverviewCardWidget({super.key, required this.teacherProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Profile Header
            Row(
              children: [
                // Avatar with neon outer glow ring
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ProfileAvatarWidget(
                    initialImageUrl: teacherProfile["avatar"] as String?,
                    radius: 7.5.w,
                    canEdit: false,
                  ),
                ),
                SizedBox(width: 4.w),
                
                // Name and Department
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (teacherProfile["name"] as String).toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        teacherProfile["department"] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.terminal_outlined,
                              size: 11,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (teacherProfile["currentSemester"] as String).toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Statistics Row - Cyber Telemetry Readouts
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    theme,
                    'TOTAL CLASSES',
                    '${teacherProfile["totalClasses"]}',
                    Icons.dashboard_outlined,
                    colorScheme.primary,
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
                ),
                SizedBox(width: 2.5.w),
                Expanded(
                  child: _buildStatItem(
                    context,
                    theme,
                    'AVG ATTENDANCE',
                    '${teacherProfile["averageAttendance"]}%',
                    Icons.analytics_outlined,
                    colorScheme.secondary,
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
                ),
                SizedBox(width: 2.5.w),
                Expanded(
                  child: _buildStatItem(
                    context,
                    theme,
                    'ACTIVE RUNTIMES',
                    '${teacherProfile["activeSessions"]}',
                    Icons.sensors_outlined,
                    colorScheme.secondary,
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildStatItem(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 16),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color,
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ]
                ),
              )
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
              
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
