import 'package:flutter/material.dart';


import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/attendance_chart_widget.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/detailed_report_widget.dart';
import './widgets/export_button_widget.dart';
import './widgets/low_attendance_widget.dart';
import './widgets/overview_metrics_widget.dart';
import './widgets/report_type_selector_widget.dart';
import '../../services/teacher_service.dart';


/// Reports Screen - Comprehensive attendance analytics and export functionality
/// Provides Overview, Detailed, and Low Attendance reports with CSV export
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  int _currentBottomIndex = 1;

  late TabController _tabController;
  String _selectedReportType = 'Overview';
  String _selectedDateRange = 'This Month';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  int _lowAttendanceThreshold = 75;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final TeacherService _teacherService = TeacherService();
  List<Map<String, dynamic>> _teacherClasses = [];
  String? _selectedClassId;


  // Mock data
  final List<Map<String, dynamic>> _chartData = [
    {'label': 'Week 1', 'percentage': 85},
    {'label': 'Week 2', 'percentage': 78},
    {'label': 'Week 3', 'percentage': 92},
    {'label': 'Week 4', 'percentage': 88},
  ];

  final List<Map<String, dynamic>> _subjectReports = [
    {
      'subject': 'Data Structures',
      'totalSessions': 20,
      'averageAttendance': 85,
      'sessions': [
        {'date': '01/02/2026', 'present': 45, 'total': 50, 'attendance': 90},
        {'date': '01/05/2026', 'present': 42, 'total': 50, 'attendance': 84},
        {'date': '01/08/2026', 'present': 48, 'total': 50, 'attendance': 96},
      ],
    },
    {
      'subject': 'Operating Systems',
      'totalSessions': 18,
      'averageAttendance': 78,
      'sessions': [
        {'date': '01/03/2026', 'present': 38, 'total': 50, 'attendance': 76},
        {'date': '01/06/2026', 'present': 40, 'total': 50, 'attendance': 80},
        {'date': '01/09/2026', 'present': 39, 'total': 50, 'attendance': 78},
      ],
    },
    {
      'subject': 'Database Management',
      'totalSessions': 22,
      'averageAttendance': 92,
      'sessions': [
        {'date': '01/04/2026', 'present': 46, 'total': 50, 'attendance': 92},
        {'date': '01/07/2026', 'present': 47, 'total': 50, 'attendance': 94},
        {'date': '01/10/2026', 'present': 45, 'total': 50, 'attendance': 90},
      ],
    },
  ];

  final List<Map<String, dynamic>> _lowAttendanceStudents = [
    {
      'name': 'Michael Johnson',
      'rollNumber': 'CS003',
      'class': 'CS-A',
      'attendance': 68,
      'missedSessions': 8,
    },
    {
      'name': 'Sarah Williams',
      'rollNumber': 'CS007',
      'class': 'CS-A',
      'attendance': 72,
      'missedSessions': 6,
    },
    {
      'name': 'Robert Brown',
      'rollNumber': 'CS012',
      'class': 'CS-B',
      'attendance': 65,
      'missedSessions': 10,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final classes = await _teacherService.getClasses();
      if (mounted) {
        setState(() {
          _teacherClasses = classes;
          if (classes.isNotEmpty) {
            _selectedClassId = classes.first['id'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar.teacherDashboard(
        title: 'Reports',
        onNotificationPressed: () {},
        onSettingsPressed: () {
          Navigator.pushNamed(context, '/student-profile-setup');
        },
        notificationCount: 3,
      ),
      body: Column(
        children: [
          Expanded(

            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Class Selector
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedClassId,
                              isExpanded: true,
                              hint: Text('Select Class'),
                              items: _teacherClasses.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c['id'],
                                  child: Text('${c['subject_code']} - ${c['name']}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedClassId = value;
                                  _isLoading = true;
                                });
                                // Simulate data fetch for specific class
                                Future.delayed(Duration(milliseconds: 300), () {
                                  setState(() => _isLoading = false);
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        ReportTypeSelectorWidget(

                          selectedType: _selectedReportType,
                          onTypeChanged: (type) {
                            setState(() {
                              _selectedReportType = type;
                              _isLoading = true;
                            });
                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                setState(() => _isLoading = false);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        DateRangeSelectorWidget(
                          selectedRange: _selectedDateRange,
                          startDate: _customStartDate,
                          endDate: _customEndDate,
                          onRangeChanged: (range) {
                            setState(() {
                              _selectedDateRange = range;
                              _customStartDate = null;
                              _customEndDate = null;
                            });
                          },
                          onCustomDateSelected: (start, end) {
                            setState(() {
                              _selectedDateRange = 'Custom';
                              _customStartDate = start;
                              _customEndDate = end;
                            });
                          },
                        ),
                        SizedBox(height: 24),
                        if (_selectedReportType == 'Overview') ...[
                          OverviewMetricsWidget(
                            totalSessions: 60,
                            averageAttendance: 85.0,
                            mostAttendedSubject: 'Database Management',
                          ),
                          const SizedBox(height: 12),

                          AttendanceChartWidget(chartData: _chartData),
                        ] else if (_selectedReportType == 'Detailed') ...[
                          DetailedReportWidget(subjectReports: _subjectReports),
                        ] else if (_selectedReportType == 'Low Attendance') ...[
                          LowAttendanceWidget(
                            lowAttendanceStudents: _lowAttendanceStudents,
                            threshold: _lowAttendanceThreshold,
                            onThresholdChanged: (newThreshold) {
                              setState(
                                () => _lowAttendanceThreshold = newThreshold,
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 12),

                        Center(child: ExportButtonWidget(onExport: () {})),
                        const SizedBox(height: 8),
                      ],

                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar.teacher(
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          setState(() => _currentBottomIndex = index);
        },
        activeSessionCount: 2,
      ),
    );
  }
}
