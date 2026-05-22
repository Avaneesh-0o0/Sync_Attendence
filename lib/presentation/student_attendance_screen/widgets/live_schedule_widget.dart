import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class LiveScheduleWidget extends StatelessWidget {
  const LiveScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    // Dummy schedule data for demonstration purposes. In a real app, this comes from backend.
    final schedule = [
      {'time': '09:00 AM', 'subject': 'Data Structures', 'isPast': true, 'isActive': false},
      {'time': '10:30 AM', 'subject': 'Database Mgmt', 'isPast': false, 'isActive': true, 'room': 'Room 101'},
      {'time': '12:00 PM', 'subject': 'Operating Systems', 'isPast': false, 'isActive': false},
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Today\'s Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...schedule.map((item) {
            final isActive = item['isActive'] as bool;
            final isPast = item['isPast'] as bool;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 65,
                    child: Text(
                      item['time'] as String,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isActive ? theme.colorScheme.primary : (isPast ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface),
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: Text(
                      item['subject'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isActive ? theme.colorScheme.primary : (isPast ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface),
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Live',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
