import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Class and section selection widget with multi-select capability
/// Uses platform-native pickers for optimal UX
class ClassSectionSelectorWidget extends StatelessWidget {
  final List<String> selectedClasses;
  final List<String> selectedSections;
  final Function(List<String>) onClassesChanged;
  final Function(List<String>) onSectionsChanged;
  final List<String> availableClasses;
  final List<String> availableSections;

  const ClassSectionSelectorWidget({
    super.key,
    required this.selectedClasses,
    required this.selectedSections,
    required this.onClassesChanged,
    required this.onSectionsChanged,
    required this.availableClasses,
    required this.availableSections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
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
          Row(
            children: [
              CustomIconWidget(
                iconName: 'school',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 8.w),
              Text(
                'Class & Section',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' *',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Class selector
          _buildMultiSelectField(
            context: context,
            label: 'Classes',
            selectedItems: selectedClasses,
            availableItems: availableClasses,
            onChanged: onClassesChanged,
            icon: 'class',
          ),

          SizedBox(height: 12.h),

          // Section selector
          _buildMultiSelectField(
            context: context,
            label: 'Sections',
            selectedItems: selectedSections,
            availableItems: availableSections,
            onChanged: onSectionsChanged,
            icon: 'group',
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectField({
    required BuildContext context,
    required String label,
    required List<String> selectedItems,
    required List<String> availableItems,
    required Function(List<String>) onChanged,
    required String icon,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => _showMultiSelectDialog(
            context: context,
            title: 'Select $label',
            selectedItems: selectedItems,
            availableItems: availableItems,
            onChanged: onChanged,
          ),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: selectedItems.isEmpty
                      ? Text(
                          'Select $label',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        )
                      : Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: selectedItems.map((item) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                item,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMultiSelectDialog({
    required BuildContext context,
    required String title,
    required List<String> selectedItems,
    required List<String> availableItems,
    required Function(List<String>) onChanged,
  }) {
    final theme = Theme.of(context);
    List<String> tempSelected = List.from(selectedItems);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableItems.length,
                  itemBuilder: (context, index) {
                    final item = availableItems[index];
                    final isSelected = tempSelected.contains(item);

                    return CheckboxListTile(
                      title: Text(item),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelected.add(item);
                          } else {
                            tempSelected.remove(item);
                          }
                        });
                      },
                      activeColor: theme.colorScheme.primary,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onChanged(tempSelected);
                    Navigator.pop(context);
                  },
                  child: Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
