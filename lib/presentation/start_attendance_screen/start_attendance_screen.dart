import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/advanced_settings_widget.dart';
import './widgets/attendance_mode_selector_widget.dart';
import './widgets/session_duration_picker_widget.dart';
import '../../services/teacher_service.dart';

/// Start Attendance Screen - Teacher session configuration interface
/// Enables comprehensive attendance session setup with multiple modes
class StartAttendanceScreen extends StatefulWidget {
  const StartAttendanceScreen({super.key});

  @override
  State<StartAttendanceScreen> createState() => _StartAttendanceScreenState();
}

class _StartAttendanceScreenState extends State<StartAttendanceScreen> {
  // Form state
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _totalStudentsController = TextEditingController(
    text: '50',
  );
  String? _selectedMode;
  int _selectedDuration = 60;
  List<Map<String, dynamic>> _existingClasses = [];

  // Advanced settings
  int _gracePeriod = 5;
  double _proximitySensitivity = 0.5;
  int _qrRefreshInterval = 45;

  // State
  final TeacherService _teacherService = TeacherService();
  bool _isCreatingSession = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _classController.dispose();
    _totalStudentsController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadExistingClasses();
  }

  Future<void> _loadExistingClasses() async {
    final classes = await _teacherService.getClasses();
    if (mounted) {
      setState(() {
        _existingClasses = classes;
      });

      // Auto-fill from arguments if provided
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args['subjectCode'] != null) {
          _subjectController.text = args['subjectCode'].toString();
        }
        if (args['name'] != null) {
          // args['name'] is Class Name from dashboard
          _classController.text = args['name'].toString();
          // Trigger onClassChanged to auto-fill total students
          _onClassChanged(args['name'].toString());
        }
      }
    }
  }

  void _onClassChanged(String value) {
    setState(() {});
    // Auto-fill total students if class exists (case-insensitive)
    final existing = _existingClasses.where(
      (c) => c['name'].toString().toLowerCase() == value.toLowerCase(),
    );
    if (existing.isNotEmpty) {
      final total = existing.first['total_students'];
      if (total != null) {
        _totalStudentsController.text = total.toString();
      }
    }
  }

  // Derived getter for can start
  bool get _canStartSession {
    return _subjectController.text.trim().isNotEmpty &&
        _classController.text.trim().isNotEmpty &&
        _totalStudentsController.text.trim().isNotEmpty &&
        _selectedMode != null &&
        !_isCreatingSession;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Start Attendance Session'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _canStartSession ? _startSession : null,
            child: _isCreatingSession
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Text(
                    'Start',
                    style: TextStyle(
                      color: _canStartSession
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                          theme.colorScheme.secondary.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const CustomIconWidget(
                            iconName: 'play_circle',
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Configure Session',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Set up attendance parameters for your class',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Subject manual entry
                  TextFormField(
                    controller: _subjectController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Subject Name or Code *',
                      hintText: 'e.g. CS101 or Algorithms',
                      prefixIcon: const Icon(Icons.book, size: 20),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  // Class manual entry
                  TextFormField(
                    controller: _classController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Class / Section / Year *',
                      hintText: 'e.g. CS1 or 2nd Year Section B',
                      prefixIcon: const Icon(Icons.school, size: 20),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _onClassChanged,
                  ),

                  const SizedBox(height: 16),

                  // Total Students entry
                  TextFormField(
                    controller: _totalStudentsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Total Students in Class *',
                      hintText: 'e.g. 66',
                      prefixIcon: const Icon(Icons.groups_rounded, size: 20),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) {
                      if (_canStartSession) _startSession();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Attendance mode selector
                  AttendanceModeSelectorWidget(
                    selectedMode: _selectedMode,
                    onModeChanged: (mode) {
                      setState(() {
                        _selectedMode = mode;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Session duration picker
                  SessionDurationPickerWidget(
                    selectedDuration: _selectedDuration,
                    onDurationChanged: (duration) {
                      setState(() {
                        _selectedDuration = duration;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Advanced settings
                  AdvancedSettingsWidget(
                    gracePeriod: _gracePeriod,
                    proximitySensitivity: _proximitySensitivity,
                    qrRefreshInterval: _qrRefreshInterval,
                    onGracePeriodChanged: (value) {
                      setState(() {
                        _gracePeriod = value;
                      });
                    },
                    onProximitySensitivityChanged: (value) {
                      setState(() {
                        _proximitySensitivity = value;
                      });
                    },
                    onQrRefreshIntervalChanged: (value) {
                      setState(() {
                        _qrRefreshInterval = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Start session button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canStartSession ? _startSession : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isCreatingSession
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Start Attendance Session',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Once started, the session will be active for the selected duration. Students can mark attendance using the chosen method.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startSession() async {
    if (!_canStartSession) return;

    setState(() {
      _isCreatingSession = true;
    });

    HapticFeedback.mediumImpact();

    try {
      // Validate Bluetooth availability for Bluetooth/Hybrid modes
      if (_selectedMode == 'Bluetooth' || _selectedMode == 'Hybrid') {
        final bluetoothAvailable = await _checkBluetoothAvailability();
        if (!bluetoothAvailable) {
          throw Exception("Bluetooth is required but unavailable.");
        }
      }

      // Validate camera permissions for QR/Hybrid modes
      if (_selectedMode == 'QR Code' || _selectedMode == 'Hybrid') {
        final cameraAvailable = await _checkCameraPermissions();
        if (!cameraAvailable) {
          throw Exception("Camera permission is required.");
        }
      }

      // 1. Get or Create Class ID
      final subjectCode = _subjectController.text.trim();
      final className = _classController.text.trim();
      final totalStudents =
          int.tryParse(_totalStudentsController.text.trim()) ?? 50;

      final classId = await _teacherService.getOrCreateClass(
        subjectCode,
        className,
        totalStudents: totalStudents,
      );

      if (classId == null) {
        throw Exception("Failed to identify or create class.");
      }

      // 2. Create Session in Supabase (throws on failure)
      final mode = _selectedMode ?? 'QR';
      final sessionId = await _teacherService.createSession(
        classId,
        mode,
        subjectCode,
      );

      // 3. Navigate
      final sessionConfig = {
        'sessionId': sessionId,
        'subject': subjectCode,
        'classes': [className],
        'mode': mode,
        'duration': _selectedDuration,
        'totalStudents': totalStudents,
        'gracePeriod': _gracePeriod,
        'proximitySensitivity': _proximitySensitivity,
        'startTime': DateTime.now().toIso8601String(),
      };

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/live-attendance-screen',
          arguments: sessionConfig,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Attendance session started successfully'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error starting session', e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingSession = false;
        });
      }
    }
  }

  Future<bool> _checkBluetoothAvailability() async {
    // Simulate Bluetooth check
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Mock: Bluetooth available
  }

  Future<bool> _checkCameraPermissions() async {
    // Simulate camera permission check
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Mock: Camera permission granted
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
