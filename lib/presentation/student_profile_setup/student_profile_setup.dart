import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/profile_form_widget.dart';
import './widgets/progress_indicator_widget.dart';

/// Student Profile Setup Screen
/// Enables first-time students to complete required academic information
/// Uses mobile-optimized form design with validation and keyboard avoidance
class StudentProfileSetup extends StatefulWidget {
  const StudentProfileSetup({super.key});

  @override
  State<StudentProfileSetup> createState() => _StudentProfileSetupState();
}

class _StudentProfileSetupState extends State<StudentProfileSetup> {
  final _formKey = GlobalKey<FormState>();
  final _rollNumberController = TextEditingController();

  String? _selectedClass;
  String? _selectedSection;
  String? _selectedDepartment;

  bool _isLoading = false;
  bool _isFormValid = false;

  // Mock data for dropdowns
  final List<String> _classes = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year',
  ];

  final List<String> _sections = [
    'Section A',
    'Section B',
    'Section C',
    'Section D',
  ];

  final List<String> _departments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
  ];

  @override
  void dispose() {
    _rollNumberController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
      _isFormValid =
          _isFormValid &&
          _selectedClass != null &&
          _selectedSection != null &&
          _selectedDepartment != null;
    });
  }

  Future<void> _submitProfile() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // First check if a student record exists, if not create one
      final studentResponse = await supabase
          .from('students')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (studentResponse == null) {
        // Find class ID matching selected class (simple mock matching for now since we don't have the full class dropdown with IDs)
        // In a real app we'd query the classes table to get the correct UUID
        
        await supabase.from('students').insert({
          'user_id': userId,
          'roll_no': _rollNumberController.text.trim(),
          // class_id would go here if we had it mapped properly
        });
      } else {
        await supabase.from('students').update({
          'roll_no': _rollNumberController.text.trim(),
        }).eq('user_id', userId);
      }

      // Update user department
      await supabase.from('users').update({
        'department': _selectedDepartment,
      }).eq('id', userId);

      // Save to local Hive cache for offline use
      final box = await Hive.openBox('student_profile');
      await box.put('roll_number', _rollNumberController.text.trim());
      await box.put('class_name', _selectedClass); // Stored locally for matching
      await box.put('section', _selectedSection);
      await box.put('department', _selectedDepartment);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Show success animation
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Theme.of(context).colorScheme.secondary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'Profile Completed!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Your profile has been successfully created.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(
                  context,
                  '/student-attendance-screen',
                );
              },
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_rollNumberController.text.isEmpty &&
        _selectedClass == null &&
        _selectedSection == null &&
        _selectedDepartment == null) {
      return true;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'Your profile information will be lost if you go back.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Complete Your Profile'),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              ProgressIndicatorWidget(
                currentStep: _isFormValid ? 4 : _getCompletedSteps(),
                totalSteps: 4,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  child: Form(
                    key: _formKey,
                    onChanged: _validateForm,
                    child: ProfileFormWidget(
                      rollNumberController: _rollNumberController,
                      selectedClass: _selectedClass,
                      selectedSection: _selectedSection,
                      selectedDepartment: _selectedDepartment,
                      classes: _classes,
                      sections: _sections,
                      departments: _departments,
                      onClassChanged: (value) {
                        setState(() => _selectedClass = value);
                        _validateForm();
                      },
                      onSectionChanged: (value) {
                        setState(() => _selectedSection = value);
                        _validateForm();
                      },
                      onDepartmentChanged: (value) {
                        setState(() => _selectedDepartment = value);
                        _validateForm();
                      },
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isFormValid && !_isLoading
                        ? _submitProfile
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      disabledBackgroundColor: theme
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            'Complete Profile',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 14.sp,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCompletedSteps() {
    int steps = 0;
    if (_rollNumberController.text.isNotEmpty) steps++;
    if (_selectedClass != null) steps++;
    if (_selectedSection != null) steps++;
    if (_selectedDepartment != null) steps++;
    return steps;
  }
}
