import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/profile_avatar_widget.dart';

/// Profile form widget containing all input fields
/// Implements mobile-optimized form design with validation
class ProfileFormWidget extends StatelessWidget {
  final TextEditingController rollNumberController;
  final String? selectedClass;
  final String? selectedSection;
  final String? selectedDepartment;
  final List<String> classes;
  final List<String> sections;
  final List<String> departments;
  final ValueChanged<String?> onClassChanged;
  final ValueChanged<String?> onSectionChanged;
  final ValueChanged<String?> onDepartmentChanged;

  const ProfileFormWidget({
    super.key,
    required this.rollNumberController,
    required this.selectedClass,
    required this.selectedSection,
    required this.selectedDepartment,
    required this.classes,
    required this.sections,
    required this.departments,
    required this.onClassChanged,
    required this.onSectionChanged,
    required this.onDepartmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              ProfileAvatarWidget(
                radius: 12.w,
                onUploadComplete: (url) {
                  // The service already updates Supabase and local cache
                },
              ),
              SizedBox(height: 1.h),
              Text(
                'Add Profile Photo',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Academic Information',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Please provide your academic details to complete your profile.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 3.h),

        // Roll Number Field
        Text(
          'Roll Number',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: rollNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            hintText: 'Enter your roll number',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'badge',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Roll number is required';
            }
            if (value.length < 4) {
              return 'Roll number must be at least 4 digits';
            }
            return null;
          },
        ),
        SizedBox(height: 3.h),

        // Class Dropdown
        Text(
          'Class',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          initialValue: selectedClass,
          decoration: InputDecoration(
            hintText: 'Select your class',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'school',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          items: classes.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onClassChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Class is required';
            }
            return null;
          },
        ),
        SizedBox(height: 3.h),

        // Section Dropdown
        Text(
          'Section',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          initialValue: selectedSection,
          decoration: InputDecoration(
            hintText: 'Select your section',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'group',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          items: sections.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onSectionChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Section is required';
            }
            return null;
          },
        ),
        SizedBox(height: 3.h),

        // Department Dropdown
        Text(
          'Department',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          initialValue: selectedDepartment,
          decoration: InputDecoration(
            hintText: 'Select your department',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'business',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          items: departments.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onDepartmentChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Department is required';
            }
            return null;
          },
        ),
        SizedBox(height: 3.h),

        // Information Card
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Make sure all information is correct. You won\'t be able to change these details later.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
