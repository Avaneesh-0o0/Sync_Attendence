import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/active_session_card_widget.dart';
import './widgets/attendance_history_list_widget.dart';
import './widgets/attendance_summary_widget.dart';
import './widgets/mark_attendance_button_widget.dart';
import './widgets/qr_scanner_view.dart';
import './widgets/confirm_attendance_dialog.dart';
import './widgets/live_schedule_widget.dart';
import '../../services/student_service.dart';
import '../../data/models/session_model.dart';
import '../../data/models/attendance_model.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StudentService _studentService = StudentService();

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSyncing = false;
  int _bottomNavIndex = 0;
  StreamSubscription? _syncSubscription;

  SessionModel? _activeSession;
  List<AttendanceModel> _attendanceHistory = [];
  Map<String, dynamic>? _studentProfile;
  Timer? _detectionTimer;

  final int _presentCount = 6;
  final int _totalCount = 8;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _setupSyncListener();
    _startDetectionTimer();
  }

  void _startDetectionTimer() {
    _detectionTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted && _activeSession == null) {
        _loadData(silent: true);
      }
    });
  }

  void _setupSyncListener() {
    _syncSubscription = _studentService.syncStatusStream.listen((status) {
      if (mounted) setState(() => _isSyncing = status);
    });
  }

  Future<void> _loadData({bool silent = false}) async {
    try {
      if (!silent && mounted) setState(() => _isLoading = true);

      final session = await _studentService.getActiveSession();
      final history = await _studentService.getAttendanceHistory();

      // Fetch profile if not already fetched
      _studentProfile ??= await _studentService.getStudentProfile();

      if (mounted) {
        setState(() {
          _activeSession = session;
          _attendanceHistory = history;
          _isLoading = false;
        });

        // Auto-show confirmation if new session detected
        if (session != null && !silent) {
          _showAutoDetectionDialog(session);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAutoDetectionDialog(SessionModel session) {
    // Check if class matches
    final studentClass = _studentProfile?['student']?['class_name'] ?? '';
    final sessionClass = session.className ?? '';
    final isClassMatch =
        sessionClass.toLowerCase() == studentClass.toLowerCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isClassMatch ? 'Active Lecture Detected' : 'Lecture in Progress',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A session for ${session.subject} is currently active.'),
            if (!isClassMatch) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This session is for ${session.className}, but your class is $studentClass.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Would you like to mark your attendance now?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleMarkAttendance();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _syncSubscription?.cancel();
    _detectionTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await _loadData();
    setState(() => _isRefreshing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance data refreshed'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleMarkAttendance() {
    if (_activeSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No active session available'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Class restriction check
    final studentClass = _studentProfile?['student']?['class_name'];
    // Fallback to 'class' if 'class_name' isn't available, or check local hive mapping
    final studentClassFallback = _studentProfile?['student']?['class']; 
    final currentStudentClass = studentClass ?? studentClassFallback ?? '';
    
    final sessionClass = _activeSession!.className ?? '';
    
    // Check if both are defined and they mismatch
    if (currentStudentClass.isNotEmpty && sessionClass.isNotEmpty && 
        currentStudentClass.toLowerCase() != sessionClass.toLowerCase()) {
          
      // Special override for admins/testers, you can remove this later
      // But for normal students, strictly enforce this
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.block, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              const Text('Class Mismatch'),
            ],
          ),
          content: Text(
            'This session is for $sessionClass, but you are enrolled in $currentStudentClass. You cannot mark attendance for this class.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final mode = _activeSession!.mode.toLowerCase();
    if (mode == 'qr' || mode == 'qr code') {
      _handleQRScan();
    } else if (mode == 'bluetooth') {
      _handleBluetoothMark();
    } else if (mode == 'hybrid') {
      _handleHybridMark();
    } else {
      _showModeSelectionDialog();
    }
  }

  Future<void> _handleHybridMark() async {
    // Stage 1: Bluetooth Proximity Check First
    final String? foundSessionId = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BleCheckDialog(
        sessionId: _activeSession?.id,
        isHybrid: true,
      ),
    );

    if (foundSessionId == null) {
      // User aborted the check
      return;
    }

    if (foundSessionId == 'HYBRID_QR_FALLBACK') {
      // Bluetooth check failed or was bypassed. Fall back to QR scanning.
      debugPrint('HYBRID_MARK: Bluetooth verification failed/skipped. Proceeding to QR scan.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bluetooth unavailable. Proceeding with QR scan.'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _proceedToHybridQrScan(isBleVerified: false);
    } else {
      // Bluetooth verified successfully! Proceed to QR scanning.
      debugPrint('HYBRID_MARK: Bluetooth verified successfully. Proceeding to QR scan.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bluetooth verified! Scanning QR Code to complete.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _proceedToHybridQrScan(isBleVerified: true);
    }
  }

  void _proceedToHybridQrScan({required bool isBleVerified}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerView(
          onScan: (rawData) async {
            if (mounted) Navigator.pop(context); // Close QR Scanner

            debugPrint('HYBRID_QR_SCAN: Raw data = $rawData');

            // Parse token to get Session ID
            String qrSessionId = rawData;
            if (rawData.startsWith('ATTENDIX_QR:')) {
              final parts = rawData.split(':');
              if (parts.length >= 2) {
                qrSessionId = parts[1];
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Invalid QR code. This is not an attendance QR code.',
                    ),
                    backgroundColor: Theme.of(this.context).colorScheme.error,
                  ),
                );
              }
              return;
            }

            if (_activeSession != null && qrSessionId != _activeSession!.id) {
              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'QR Code does not match the active session.',
                    ),
                    backgroundColor: Theme.of(this.context).colorScheme.error,
                  ),
                );
              }
              return;
            }

            // Bluetooth successfully verified or gracefully bypassed. Show confirmation prompt.
            if (mounted) {
              showDialog(
                context: this.context,
                builder: (dialogContext) => ConfirmAttendanceDialog(
                  sessionTitle: _activeSession?.subject ?? 'Unknown Subject',
                  sessionSubtitle: '${_activeSession?.className ?? "Class"} • ${_activeSession?.teacherName ?? "Teacher"}'
                      '\n(${isBleVerified ? "✓ BLE Proximity Verified" : "✗ BLE Bypassed (QR-Only)"})',
                  method: 'Hybrid',
                  onConfirm: () async {
                    Navigator.pop(dialogContext); // Close dialog

                    final result = await _studentService.markAttendance(
                      _activeSession!.id,
                      'Hybrid',
                      token: rawData,
                    );
                    if (mounted) {
                      if (result != MarkAttendanceResult.failure) {
                        _markAttendanceSuccess(result);
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to mark hybrid attendance.'),
                          ),
                        );
                      }
                    }
                  },
                  onCancel: () => Navigator.pop(dialogContext),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<String?> _handleBluetoothCheckOnly() async {
    // Show a small overlay/dialog for BLE check
    return await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BleCheckDialog(sessionId: _activeSession?.id),
    );
  }

  void _handleQRScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerView(
          onScan: (rawData) async {
            // Pop the scanner view first — the scanner no longer pops itself
            if (mounted) Navigator.pop(context);

            debugPrint('QR_SCAN: Raw data = $rawData');

            // Parse token to get Session ID
            String qrSessionId = rawData;
            if (rawData.startsWith('ATTENDIX_QR:')) {
              final parts = rawData.split(':');
              if (parts.length >= 2) {
                qrSessionId = parts[1]; // The session ID is the second part
              }
            } else {
              // Not an ATTENDIX_QR token at all
              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Invalid QR code. This is not an attendance QR code.',
                    ),
                    backgroundColor: Theme.of(this.context).colorScheme.error,
                  ),
                );
              }
              return;
            }

            // Verify session matches active session
            if (_activeSession != null && qrSessionId != _activeSession!.id) {
              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'QR Code does not match the active session.',
                    ),
                    backgroundColor: Theme.of(this.context).colorScheme.error,
                  ),
                );
              }
              return;
            }

            // If no active session, fetch details for this session ID
            SessionModel? sessionToMark = _activeSession;
            if (sessionToMark == null) {
              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Fetching session details...')),
                );
              }

              int retries = 0;
              while (retries < 3) {
                try {
                  sessionToMark = await _studentService.getSessionById(
                    qrSessionId,
                  );
                  if (sessionToMark != null) break;
                } catch (e) {
                  // ignore error and retry
                }
                retries++;
                if (retries < 3) {
                  await Future.delayed(const Duration(seconds: 1));
                }
              }

              if (sessionToMark == null) {
                if (mounted) {
                  showDialog(
                    context: this.context,
                    builder: (context) => AlertDialog(
                      title: const Text('Session Not Found'),
                      content: const Text(
                        'Could not find the session details. Check your internet connection or try scanning again.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
                return;
              }
            }

            if (mounted) {
              showDialog(
                context: this.context,
                builder: (dialogContext) => ConfirmAttendanceDialog(
                  sessionTitle: sessionToMark?.subject ?? 'Unknown Subject',
                  sessionSubtitle:
                      '${sessionToMark?.className} • ${sessionToMark?.teacherName ?? "Teacher"}',
                  method: 'QR',
                  onCancel: () => Navigator.pop(dialogContext),
                  onConfirm: () async {
                    Navigator.pop(dialogContext); // Close dialog

                    final result = await _studentService.markAttendance(
                      sessionToMark!.id,
                      'QR',
                      token: rawData,
                    );
                    if (mounted) {
                      if (result != MarkAttendanceResult.failure) {
                        _markAttendanceSuccess(result);
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to mark attendance. The QR code may have expired. Try scanning the latest QR.',
                            ),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _handleBluetoothMark() async {
    // 1. Show Scanning Dialog & Scan
    final String? foundSessionId = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BleCheckDialog(sessionId: _activeSession?.id),
    );

    if (foundSessionId == null) return;

    // Determine which session to mark
    // If active session exists, use it. If not, use found session (manual mode).
    SessionModel? sessionToMark = _activeSession;

    if (sessionToMark == null) {
      // Manual mode: Fetch session details
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Found Session! Fetching details...')),
        );
      }
      sessionToMark = await _studentService.getSessionById(foundSessionId);
    }

    if (sessionToMark == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load session details.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 2. Beacon Found - Show Confirmation
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => ConfirmAttendanceDialog(
          sessionTitle: sessionToMark?.subject ?? 'Unknown Subject',
          sessionSubtitle:
              'Verified via Bluetooth Beacon\n(${sessionToMark?.teacherName ?? "Teacher"})',
          method: 'Bluetooth',
          onCancel: () => Navigator.pop(context),
          onConfirm: () async {
            Navigator.pop(context); // Close dialog
            final result = await _studentService.markAttendance(
              sessionToMark!.id,
              'Bluetooth',
            );
            if (result != MarkAttendanceResult.failure) {
              _markAttendanceSuccess(result);
            }
          },
        ),
      );
    }
  }

  void _showModeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Attendance Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'qr_code_scanner',
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Scan QR Code'),
              subtitle: const Text('Use camera to scan'),
              onTap: () {
                Navigator.pop(context);
                _handleQRScan();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'bluetooth',
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Bluetooth Proximity'),
              subtitle: const Text('Auto-detect location'),
              onTap: () {
                Navigator.pop(context);
                _handleBluetoothMark();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _markAttendanceSuccess(MarkAttendanceResult result) {
    HapticFeedback.heavyImpact();
    _loadData();

    if (mounted) {
      final isOffline = result == MarkAttendanceResult.successOffline;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: isOffline ? 'cloud_off' : 'check_circle',
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isOffline
                      ? 'Saved offline. Will sync when online.'
                      : 'Attendance marked successfully!',
                ),
              ),
            ],
          ),
          backgroundColor: isOffline
              ? Colors.orange
              : Theme.of(context).colorScheme.secondary,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar.studentAttendance(
        title: 'Attendance',
        onHistoryPressed: () {
          _tabController.animateTo(1);
        },
      ),
      body: CyberGridBackground(
        type: CyberBackgroundType.clean,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      Container(
                        color: theme.colorScheme.surface.withValues(alpha: 0.65),
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Attendance'),
                            Tab(text: 'History'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAttendanceTab(theme),
                            _buildHistoryTab(theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomBar.student(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
        },
      ),
    );
  }

  Widget _buildAttendanceTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            if (_isSyncing)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Syncing offline records...',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            AttendanceSummaryWidget(
              presentCount: _presentCount,
              totalCount: _totalCount,
            ),
            const SizedBox(height: 16),
            const LiveScheduleWidget(),
            const SizedBox(height: 24),
            ActiveSessionCardWidget(
              activeSession: _activeSession,
              onMarkAttendance: _handleMarkAttendance,
              onManualQR: _handleQRScan,
              onManualBle: _handleBluetoothMark,
            ),
            const SizedBox(height: 16),
            if (_activeSession != null)
              MarkAttendanceButtonWidget(
                mode: _activeSession!.mode,
                isMarked: false,
                onPressed: _handleMarkAttendance,
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Leave Management coming soon. Phase 3 in progress.')),
                    );
                  },
                  icon: const Icon(Icons.event_busy),
                  label: const Text('Request Academic Leave'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: AttendanceHistoryListWidget(historyData: _attendanceHistory),
    );
  }
}

class _BleCheckDialog extends StatefulWidget {
  final String? sessionId;
  final bool isHybrid;
  const _BleCheckDialog({this.sessionId, this.isHybrid = false});

  @override
  State<_BleCheckDialog> createState() => _BleCheckDialogState();
}

class _BleCheckDialogState extends State<_BleCheckDialog> with SingleTickerProviderStateMixin {
  String _status = 'Initializing Bluetooth...';
  bool _isError = false;
  bool _isScanning = true;
  StreamSubscription? _scanSubscription;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _startBleCheck();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _radarController.dispose();
    super.dispose();
  }

  Future<void> _startBleCheck() async {
    setState(() {
      _status = 'Checking Bluetooth State...';
      _isError = false;
      _isScanning = true;
    });

    try {
      if (!(await FlutterBluePlus.isSupported)) {
        throw Exception('Bluetooth not supported on this device');
      }

      // Request runtime permissions (Android 12+)
      if (Platform.isAndroid) {
        final statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();

        final denied = statuses.entries
            .where((e) => !e.value.isGranted)
            .map((e) => e.key.toString())
            .toList();

        if (denied.isNotEmpty) {
          throw Exception(
            'Bluetooth permissions required. Please grant: ${denied.join(", ")} in Settings.',
          );
        }
      }

      // Check adapter state with a timeout
      try {
        await FlutterBluePlus.adapterState
            .firstWhere((s) => s == BluetoothAdapterState.on)
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        // If we timed out waiting for ON, try to turn it on (Android) or show error
        if (Platform.isAndroid) {
          try {
            await FlutterBluePlus.turnOn();
          } catch (_) {}
        }

        // Check again briefly
        final state = await FlutterBluePlus.adapterState.first;
        if (state != BluetoothAdapterState.on) {
          throw Exception('Bluetooth is off. Please turn it on and retry.');
        }
      }

      if (mounted) setState(() => _status = 'Scanning for teacher device...');

      final String shortSessionId = widget.sessionId?.substring(0, 8) ?? '';
      debugPrint('BLE_SCAN: Looking for ATX:$shortSessionId (sessionId=${widget.sessionId})');

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidScanMode: AndroidScanMode.lowLatency,
      );

      bool beaconFound = false;
      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        for (ScanResult r in results) {
          // Check both advName and platformName for the ATX: prefix
          final advName = r.advertisementData.advName;
          final platformName = r.device.platformName;
          final String detectedName = advName.isNotEmpty ? advName : platformName;
          
          // Log all discovered devices for debugging
          if (detectedName.isNotEmpty) {
            debugPrint('BLE_SCAN: Found device: name="$detectedName" rssi=${r.rssi} '
                'serviceUuids=${r.advertisementData.serviceUuids}');
          }

          bool match = false;

          if (shortSessionId.isNotEmpty && detectedName.contains('ATX:$shortSessionId')) {
            match = true;
          } else if (shortSessionId.isEmpty && detectedName.contains('ATX:')) {
            match = true;
          }

          if (match) {
            debugPrint('BLE_SCAN: ✅ MATCH FOUND! name=$detectedName rssi=${r.rssi}');
            // Proximity check is relaxed for zero-resistance marking as requested by the user
            beaconFound = true;
            FlutterBluePlus.stopScan();
            String? foundId = widget.sessionId;
            foundId ??= detectedName;
            if (mounted) Navigator.pop(context, foundId);
            break;
          }
        }
      });

      // Wait for scan to complete (it stops automatically after timeout)
      await Future.delayed(
        const Duration(seconds: 16),
      ); // slightly longer than scan timeout

      if (!beaconFound && mounted && _isScanning) {
        debugPrint('BLE_SCAN: ❌ No matching teacher device found');
        setState(() {
          _isError = true;
          _isScanning = false;
          _status =
              'Teacher not found nearby.\n\nMake sure:\n• Teacher has Bluetooth session active\n• You are close to the teacher\n• Location/GPS is enabled';
        });
      }
    } catch (e) {
      debugPrint('BLE_SCAN: Error: $e');
      if (mounted) {
        setState(() {
          String errorMsg = e.toString();
          if (errorMsg.contains('Location services are required') ||
              errorMsg.contains('location')) {
            errorMsg = 'Location services (GPS) are required to scan for Bluetooth signals on Android.\n\nPlease enable Location in your device settings and retry.';
          } else {
            errorMsg = errorMsg.replaceAll('Exception: ', '').replaceAll('PlatformException', 'Error');
          }
          _status = errorMsg;
          _isError = true;
          _isScanning = false;
        });
      }
    }
  }

  Widget _buildRadarAnimation(ThemeData theme) {
    return AnimatedBuilder(
      animation: _radarController,
      builder: (context, child) {
        return SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple 1
              Opacity(
                opacity: (1.0 - _radarController.value),
                child: Transform.scale(
                  scale: 0.5 + 0.8 * _radarController.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Ripple 2
              Opacity(
                opacity: (1.0 - ((_radarController.value + 0.5) % 1.0)),
                child: Transform.scale(
                  scale: 0.5 + 0.8 * ((_radarController.value + 0.5) % 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Center Core
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.bluetooth_searching,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorIndicator(ThemeData theme) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              border: Border.all(
                color: theme.colorScheme.error,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.error.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = _isError ? theme.colorScheme.error : theme.colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 380,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: indicatorColor.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BLE PROXIMITY SCAN',
                  style: GoogleFonts.orbitron(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: indicatorColor,
                  ),
                ),
                const SizedBox(height: 24),
                if (_isScanning)
                  _buildRadarAnimation(theme)
                else if (_isError)
                  _buildErrorIndicator(theme)
                else
                  const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('CANCEL'),
                    ),
                    if (widget.isHybrid) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, 'HYBRID_QR_FALLBACK');
                        },
                        icon: const Icon(Icons.qr_code, size: 16, color: Colors.white),
                        label: const Text('USE QR CODE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                    if (_isError) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _startBleCheck,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('RETRY'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
