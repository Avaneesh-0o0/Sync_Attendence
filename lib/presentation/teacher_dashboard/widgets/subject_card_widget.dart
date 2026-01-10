import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Subject Card Widget
/// Displays subject information with quick action buttons
class SubjectCardWidget extends StatelessWidget {
  final Map<String, dynamic> subject;
  final VoidCallback onStartSession;
  final VoidCallback onViewReports;
  final VoidCallback onManageStudents;

  const SubjectCardWidget({
    super.key,
    required this.subject,
    required this.onStartSession,
    required this.onViewReports,
    required this.onManageStudents,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectColor = Color(subject["color"] as int);

    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              subjectColor.withValues(alpha: 0.1),
              subjectColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Icon and Code
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: subject["icon"] as String,
                      color: subjectColor,
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      subject["id"] as String,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: subjectColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Subject Name
              Text(
                subject["name"] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),

              // Enrolled Students
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'people',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${subject["enrolledStudents"]} students',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),

              // Recent Attendance
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: theme.colorScheme.secondary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${subject["recentAttendance"]}% attendance',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStartSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subjectColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'play_circle',
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Flexible(
                            child: Text(
                              'Start Session',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onViewReports,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: subjectColor),
                            foregroundColor: subjectColor,
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                          ),
                          child: Text(
                            'Reports',
                            style: theme.textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onManageStudents,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: subjectColor),
                            foregroundColor: subjectColor,
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                          ),
                          child: Text(
                            'Students',
                            style: theme.textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
