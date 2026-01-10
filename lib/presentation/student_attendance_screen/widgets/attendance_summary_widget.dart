import 'package:flutter/material.dart';


import '../../../core/app_export.dart';

/// Today's attendance summary card
/// Shows present/total count visualization
class AttendanceSummaryWidget extends StatelessWidget {
  final int presentCount;
  final int totalCount;

  const AttendanceSummaryWidget({
    super.key,
    required this.presentCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = totalCount > 0
        ? (presentCount / totalCount * 100).toInt()
        : 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'calendar_today',
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(

                'Today\'s Attendance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(

            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Classes Attended',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(

                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$presentCount',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' / $totalCount',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 8,
                        backgroundColor: theme.colorScheme.outline.withValues(
                          alpha: 0.2,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage >= 75
                              ? theme.colorScheme.secondary
                              : percentage >= 50
                              ? AppTheme.warningLight
                              : theme.colorScheme.error,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

            decoration: BoxDecoration(
              color: percentage >= 75
                  ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                  : percentage >= 50
                  ? AppTheme.warningLight.withValues(alpha: 0.1)
                  : theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: percentage >= 75
                      ? 'trending_up'
                      : percentage >= 50
                      ? 'remove'
                      : 'trending_down',
                  size: 16,
                  color: percentage >= 75
                      ? theme.colorScheme.secondary
                      : percentage >= 50
                      ? AppTheme.warningLight
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(

                  child: Text(
                    percentage >= 75
                        ? 'Great attendance! Keep it up'
                        : percentage >= 50
                        ? 'Good attendance, maintain consistency'
                        : 'Low attendance, attend more classes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: percentage >= 75
                          ? theme.colorScheme.secondary
                          : percentage >= 50
                          ? AppTheme.warningLight
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
