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

    final isDanger = percentage < 75;
    final isWarning = percentage >= 75 && percentage < 85;
    final statusColor = isDanger
        ? theme.colorScheme.error
        : (isWarning ? AppTheme.warningLight : theme.colorScheme.secondary);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Attendance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  isDanger ? 'Critical' : (isWarning ? 'At Risk' : 'Perfect'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    backgroundColor: theme.colorScheme.outline.withValues(
                      alpha: 0.1,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Attended',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Attended', presentCount.toString(), theme.colorScheme.secondary, theme),
              Container(width: 1, height: 40, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              _buildStatItem('Missed', (totalCount - presentCount).toString(), theme.colorScheme.error, theme),
              Container(width: 1, height: 40, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              _buildStatItem('Total', totalCount.toString(), theme.colorScheme.primary, theme),
            ],
          ),
          if (isDanger) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                   Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Text(
                       'Your attendance is below the mandatory 75% required to sit for finals.',
                       style: theme.textTheme.bodySmall?.copyWith(
                         color: theme.colorScheme.error,
                         fontWeight: FontWeight.w600,
                       ),
                     )
                   )
                ]
              )
            )
          ]
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
