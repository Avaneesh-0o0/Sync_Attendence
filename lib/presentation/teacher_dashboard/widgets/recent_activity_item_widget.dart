import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Recent Activity Item Widget
/// Displays individual attendance session information with expandable details in a cyber theme
class RecentActivityItemWidget extends StatefulWidget {
  final Map<String, dynamic> activity;
  final VoidCallback? onTap;

  const RecentActivityItemWidget({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  State<RecentActivityItemWidget> createState() =>
      _RecentActivityItemWidgetState();
}

class _RecentActivityItemWidgetState extends State<RecentActivityItemWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = widget.activity["status"] == "active";
    
    final statusColor = isActive
        ? colorScheme.primary
        : colorScheme.onSurface.withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive 
              ? colorScheme.primary.withOpacity(0.3) 
              : colorScheme.primary.withOpacity(0.1),
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Indicator (Glowing Node)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor,
                          blurRadius: isActive ? 6 : 2,
                          spreadRadius: isActive ? 1 : 0,
                        )
                      ],
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .custom(duration: 1000.ms, builder: (context, val, child) {
                      return Opacity(
                        opacity: isActive ? 0.4 + (val * 0.6) : 1.0,
                        child: child,
                      );
                   }),
                  SizedBox(width: 3.w),

                  // Subject Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (widget.activity["subjectName"] as String).toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          widget.activity["subjectCode"] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Attendance Percentage Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 0.8.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${widget.activity["attendancePercentage"].toStringAsFixed(1)}%',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: statusColor,
                        
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Expand Icon
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: colorScheme.onSurface.withOpacity(0.6),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _isExpanded = !_isExpanded);
                    },
                  ),
                ],
              ),

              SizedBox(height: 1.5.h),
              
              // Session Info Row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: colorScheme.onSurface.withOpacity(0.4),
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.activity["sessionDate"] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.access_time_outlined,
                    color: colorScheme.onSurface.withOpacity(0.4),
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.activity["sessionTime"] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.4.h,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary.withOpacity(0.1)
                          : theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: statusColor.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      isActive ? 'RUNTIME ACTIVE' : 'ARCHIVED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              // Expanded Details
              if (_isExpanded) ...[
                SizedBox(height: 1.5.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        theme,
                        'Session Duration',
                        widget.activity["duration"] as String,
                        Icons.timer_outlined,
                      ),
                      SizedBox(height: 1.h),
                      _buildDetailRow(
                        context,
                        theme,
                        'Headcount Registered',
                        '${widget.activity["attendanceCount"]} / ${widget.activity["totalStudents"]}',
                        Icons.people_alt_outlined,
                      ),
                      if (isActive) ...[
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: widget.onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.hub_outlined, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'CONNECT TO RUNTIME',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05, end: 0),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 15,
        ),
        SizedBox(width: 2.w),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
            
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
