import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PercentageDataWidget extends StatefulWidget {
  final List<Map<String, dynamic>> studentsData;

  const PercentageDataWidget({
    super.key,
    required this.studentsData,
  });

  @override
  State<PercentageDataWidget> createState() => _PercentageDataWidgetState();
}

class _PercentageDataWidgetState extends State<PercentageDataWidget> {
  String _condition = '<'; // '<', '>', '=='
  double _percentage = 50.0;

  List<Map<String, dynamic>> get filteredStudents {
    return widget.studentsData.where((student) {
      final int attendance = student['attendance'] as int;
      if (_condition == '<') return attendance < _percentage;
      if (_condition == '>') return attendance > _percentage;
      if (_condition == '==') return attendance == _percentage.toInt();
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedStudents = filteredStudents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '%Filter',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Condition',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: '<', label: Text('Less Than (<)')),
                        ButtonSegment(value: '==', label: Text('Equal (==)')),
                        ButtonSegment(value: '>', label: Text('Greater Than (>)')),
                      ],
                      selected: {_condition},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _condition = newSelection.first;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        textStyle: theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Percentage Value',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${_percentage.toInt()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _percentage,
                min: 1,
                max: 100,
                divisions: 99,
                label: '${_percentage.toInt()}%',
                onChanged: (value) {
                  setState(() {
                    _percentage = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        displayedStudents.isEmpty
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
                        iconName: 'info_outline',
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No students found matching this condition',
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
                itemCount: displayedStudents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final student = displayedStudents[index];
                  // Determine color based on attendance percentage (low is error, med is warning, high is success)
                  final att = student['attendance'] as int;
                  Color attColor = theme.colorScheme.error;
                  if (att >= 75) {
                    attColor = Colors.green;
                  } else if (att >= 50) attColor = Colors.orange;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'person',
                              size: 20,
                              color: theme.colorScheme.primary,
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
                                color: attColor,
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
}
