import 'package:flutter/material.dart';


import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Low attendance students display with configurable threshold
/// Highlights at-risk students with attendance below threshold
class LowAttendanceWidget extends StatelessWidget {
  final List<Map<String, dynamic>> lowAttendanceStudents;
  final int threshold;
  final Function(int) onThresholdChanged;

  const LowAttendanceWidget({
    super.key,
    required this.lowAttendanceStudents,
    required this.threshold,
    required this.onThresholdChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Low Attendance Students',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () => _showThresholdDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Threshold: $threshold%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    CustomIconWidget(
                      iconName: 'edit',
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        lowAttendanceStudents.isEmpty

            ? Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'check_circle',
                        size: 32,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(height: 8),
                      Text(

                        'No students below threshold',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lowAttendanceStudents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {

                  final student = lowAttendanceStudents[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(

                            color: theme.colorScheme.error.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'person',
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student['name'] as String,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Roll: ${student['rollNumber']} • ${student['class']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${student['attendance']}%',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${student['missedSessions']} missed',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  void _showThresholdDialog(BuildContext context) {
    final theme = Theme.of(context);
    int tempThreshold = threshold;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Set Attendance Threshold',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Students below this percentage will be highlighted',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(

                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (tempThreshold > 50) {
                        setState(() => tempThreshold -= 5);
                      }
                    },
                    icon: CustomIconWidget(
                      iconName: 'remove_circle_outline',
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),

                  ),
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(

                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '$tempThreshold%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (tempThreshold < 95) {
                        setState(() => tempThreshold += 5);
                      }
                    },
                    icon: CustomIconWidget(
                      iconName: 'add_circle_outline',
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),

                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onThresholdChanged(tempThreshold);
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
