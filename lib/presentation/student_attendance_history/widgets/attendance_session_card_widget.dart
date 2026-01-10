import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying individual attendance session card
class AttendanceSessionCardWidget extends StatelessWidget {
  final Map<String, dynamic> session;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const AttendanceSessionCardWidget({
    super.key,
    required this.session,
    required this.onTap,
    required this.onLongPress,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final status = session["status"] as String;
    final isPresent = status == "Present";

    final statusColor = isPresent ? colorScheme.secondary : colorScheme.error;
    final statusBgColor = colorScheme.surface;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'calendar_today',
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _formatDate(session["date"] as DateTime),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),

                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor,
                            statusColor.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        status,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Subject
                Text(
                  session["subject"] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),

                SizedBox(height: 1.h),

                // Teacher
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'person',
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      session["teacher"] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 1.h),

                // Duration and time
                Row(
                  children: [
                    // Duration
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          session["duration"] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),

                    if (session["timestamp"] != null)
                      SizedBox(width: 4.w),
                    if (session["timestamp"] != null)
                      // Marked time
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'check_circle',
                            size: 18,
                            color: statusColor,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            _formatTime(session["timestamp"] as DateTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                SizedBox(height: 1.h),

                // Method
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: session["method"] == "QR Code"
                          ? 'qr_code'
                          : session["method"] == "Bluetooth"
                          ? 'bluetooth'
                          : 'devices',
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      session["method"] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
