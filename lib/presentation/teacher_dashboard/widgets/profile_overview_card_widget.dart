import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/profile_avatar_widget.dart';

/// Profile Overview Card Widget
/// Displays teacher profile information and current semester statistics
class ProfileOverviewCardWidget extends StatelessWidget {
  final Map<String, dynamic> teacherProfile;

  const ProfileOverviewCardWidget({super.key, required this.teacherProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Profile Header
            Row(
              children: [
                // Avatar
                ProfileAvatarWidget(
                  initialImageUrl: teacherProfile["avatar"] as String?,
                  radius: 8.w, // Match the original 16.w width
                  canEdit: false, // Overview card shouldn't trigger edit
                ),
                SizedBox(width: 4.w),
                // Name and Department
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacherProfile["name"] as String,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        teacherProfile["department"] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          teacherProfile["currentSemester"] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Statistics Row - Use Flexible to allow items to shrink
            Row(
              children: [
                Flexible(
                  child: _buildStatItem(
                    context,
                    theme,
                    'Total Classes',
                    '${teacherProfile["totalClasses"]}',
                    'class',
                    theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: _buildStatItem(
                    context,
                    theme,
                    'Avg Attendance',
                    '${teacherProfile["averageAttendance"]}%',
                    'trending_up',
                    theme.colorScheme.secondary,
                  ),
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: _buildStatItem(
                    context,
                    theme,
                    'Active Sessions',
                    '${teacherProfile["activeSessions"]}',
                    'play_circle',
                    const Color(0xFFF57C00),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    String iconName,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CustomIconWidget(iconName: iconName, color: color, size: 24),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
