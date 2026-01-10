import 'package:flutter/material.dart';


import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Overview metrics display with key attendance statistics
/// Shows total sessions, average attendance, most attended subject
class OverviewMetricsWidget extends StatelessWidget {
  final int totalSessions;
  final double averageAttendance;
  final String mostAttendedSubject;

  const OverviewMetricsWidget({
    super.key,
    required this.totalSessions,
    required this.averageAttendance,
    required this.mostAttendedSubject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total Sessions',
                totalSessions.toString(),
                CustomIconWidget(
                  iconName: 'event_note',
                  size: 20,
                  color: theme.colorScheme.primary,

                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(

              child: _buildMetricCard(
                context,
                'Avg Attendance',
                '${averageAttendance.toStringAsFixed(1)}%',
                CustomIconWidget(
                  iconName: 'trending_up',
                  size: 20,
                  color: theme.colorScheme.secondary,

                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMetricCard(

          context,
          'Most Attended Subject',
          mostAttendedSubject,
          CustomIconWidget(iconName: 'star', size: 20, color: Colors.amber),
          isFullWidth: true,

        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    Widget icon, {
    bool isFullWidth = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(

        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Expanded(

                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(

            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
