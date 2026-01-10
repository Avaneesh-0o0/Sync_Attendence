import 'package:flutter/material.dart';


import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Date range selector with preset chips and custom date picker
/// Provides quick access to common date ranges and custom selection
class DateRangeSelectorWidget extends StatelessWidget {
  final String selectedRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String) onRangeChanged;
  final Function(DateTime, DateTime) onCustomDateSelected;

  const DateRangeSelectorWidget({
    super.key,
    required this.selectedRange,
    this.startDate,
    this.endDate,
    required this.onRangeChanged,
    required this.onCustomDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presetRanges = ['This Week', 'This Month', 'This Semester', 'Custom'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: presetRanges.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),

            itemBuilder: (context, index) {
              final range = presetRanges[index];
              final isSelected = selectedRange == range;
              return GestureDetector(
                onTap: () {
                  if (range == 'Custom') {
                    _showCustomDatePicker(context);
                  } else {
                    onRangeChanged(range);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (range == 'Custom')
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: CustomIconWidget(
                            iconName: 'calendar_today',
                            size: 14,
                            color: null, // theme primary/onSurface handled by isSelected
                          ),
                        ),

                      Text(
                        range,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (selectedRange == 'Custom' &&
            startDate != null &&
            endDate != null) ...[
          const SizedBox(height: 8),
          Text(

            '${_formatDate(startDate!)} - ${_formatDate(endDate!)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showCustomDatePicker(BuildContext context) async {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onCustomDateSelected(picked.start, picked.end);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
