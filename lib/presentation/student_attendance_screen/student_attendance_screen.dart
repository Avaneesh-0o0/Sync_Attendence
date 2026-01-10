import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
      if (_studentProfile == null) {
        _studentProfile = await _studentService.getStudentProfile();
      }

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
    final isClassMatch = sessionClass.toLowerCase() == studentClass.toLowerCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isClassMatch ? 'Active Lecture Detected' : 'Lecture in Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A session for ${session.subjectCode} is currently active.'),
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
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This session is for ${session.className}, but your class is $studentClass.',
                        style: const TextStyle(fontSize: 12, color: Colors.orange),
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

  void _handleHybridMark() {
    // Stage 1: QR Scan
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerView(
          onScan: (rawData) async {
            // Stage 2: Bluetooth Proximity
            if (mounted) {
              Navigator.pop(context); // Close QR view
              final String? foundSessionId = await _handleBluetoothCheckOnly();
              if (foundSessionId != null) {
                final result = await _studentService.markAttendance(
                  _activeSession!.id,
                  'Hybrid',
                  token: rawData,
                );
                if (result != MarkAttendanceResult.failure) _markAttendanceSuccess(result);
              }
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
          builder: (context) => _BleCheckDialog(
            sessionId: _activeSession?.id,
          ),
        );
  }

  void _handleQRScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerView(
          onScan: (rawData) async {
            // Parse token to get Session ID (if encoded as ATTENDIX_QR:SESSION_ID:HASH)
            String qrSessionId = rawData; 
            if (rawData.startsWith('ATTENDIX_QR:')) {
               final parts = rawData.split(':');
               if (parts.length >= 2) {
                 qrSessionId = parts[1];
               }
            }

            // Verify session matches active session if strict
            if (_activeSession != null && qrSessionId != _activeSession!.id) {
               if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: const Text('QR Code does not match the active session.'),
                     backgroundColor: Theme.of(context).colorScheme.error,
                   ),
                 );
               }
               return;
            }

            // If no active session, fetch details for this session ID
            SessionModel? sessionToMark = _activeSession;
            if (sessionToMark == null) {
              if (mounted) { // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Fetching session details...')),
                );
              }
              
              // Retry logic for fetching session
              int retries = 0;
              while (retries < 3) {
                 try {
                   sessionToMark = await _studentService.getSessionById(qrSessionId);
                   if (sessionToMark != null) break;
                 } catch (e) {
                   // ignore error and retry
                 }
                 retries++;
                 if (retries < 3) await Future.delayed(const Duration(seconds: 1));
              }
              
              if (sessionToMark == null) {
                if (mounted) {
                   Navigator.pop(context); // Close any open dialogs if needed (though none open here yet)
                   // Show a more helpful dialog or snackbar
                   showDialog(
                     context: context,
                     builder: (context) => AlertDialog(
                       title: const Text('Session Not Found'),
                       content: const Text('Could not find the session details. Check your internet connection or try scanning again.'),
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
                context: context,
                builder: (context) => ConfirmAttendanceDialog(
                  sessionTitle: sessionToMark?.subjectCode ?? 'Unknown Subject',
                  sessionSubtitle: '${sessionToMark?.className} • ${sessionToMark?.teacherName ?? "Teacher"}',
                  method: 'QR',
                  onCancel: () => Navigator.pop(context),
                  onConfirm: () async {
                    Navigator.pop(context); // Close dialog
                    
                    final result = await _studentService.markAttendance(
                      sessionToMark!.id,
                      'QR',
                      token: rawData,
                    );
                    if (mounted) {
                      if (result != MarkAttendanceResult.failure) {
                        _markAttendanceSuccess(result);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to mark attendance. Try again.'),
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
      builder: (context) => _BleCheckDialog(
        sessionId: _activeSession?.id,
      ),
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
             const SnackBar(content: Text('Failed to load session details.'), backgroundColor: Colors.red),
          );
       }
       return;
    }

    // 2. Beacon Found - Show Confirmation
    if (mounted) {
       showDialog(
        context: context,
        builder: (context) => ConfirmAttendanceDialog(
          sessionTitle: sessionToMark?.subjectCode ?? 'Unknown Subject',
          sessionSubtitle: 'Verified via Bluetooth Beacon\n(${sessionToMark?.teacherName ?? "Teacher"})',
          method: 'Bluetooth',
          onCancel: () => Navigator.pop(context),
          onConfirm: () async {
            Navigator.pop(context); // Close dialog
            final result = await _studentService.markAttendance(
              sessionToMark!.id,
              'Bluetooth',
            );
            if (result != MarkAttendanceResult.failure) _markAttendanceSuccess(result);
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
                child: Text(isOffline 
                  ? 'Saved offline. Will sync when online.' 
                  : 'Attendance marked successfully!'
                ),
              ),
            ],
          ),
          backgroundColor: isOffline ? Colors.orange : Theme.of(context).colorScheme.secondary,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    Container(
                      color: theme.colorScheme.surface,
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
            const SizedBox(height: 24),
            AttendanceSummaryWidget(
              presentCount: _presentCount,
              totalCount: _totalCount,
            ),
            const SizedBox(height: 16),
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
  const _BleCheckDialog({this.sessionId});

  @override
  State<_BleCheckDialog> createState() => _BleCheckDialogState();
}

class _BleCheckDialogState extends State<_BleCheckDialog> {
  String _status = 'Initializing Bluetooth...';
  bool _isError = false;
  bool _isScanning = true;
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _startBleCheck();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
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

      // Check adapter state with a timeout
      try {
        final adapterState = await FlutterBluePlus.adapterState
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
      
      if (mounted) setState(() => _status = 'Scanning for Teacher...');

      // Target Service UUID
      final targetUuid = "bf27730d-860a-4e09-889c-2d8b6a9e0fe7";
      
      // Start Scan
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 12),
        withServices: [], // Scan for all to be safe, filtering can differ by phone
      );
      
      bool beaconFound = false;
      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        for (ScanResult r in results) {
          bool match = false;
          // Check Service UUID
          final hasServiceUuid = r.advertisementData.serviceUuids.contains(Guid(targetUuid));
          
          if (hasServiceUuid) {
             if (widget.sessionId != null) {
                // Specific check
                // Check name contains session ID OR "Attendix" if we want to be linient
                final localName = r.advertisementData.localName;
                if (localName.contains(widget.sessionId!) || localName.contains('Attendix')) {
                      match = true;
                }
             } else {
               // Generic match
               match = true;
             }
          }

          if (match) {
            beaconFound = true;
            FlutterBluePlus.stopScan();
            String? foundId = widget.sessionId;
            if (foundId == null) {
               final parts = r.advertisementData.localName.split(':');
               foundId = parts.length > 1 ? parts[1] : null; 
            }
            if (mounted) Navigator.pop(context, foundId ?? 'UNKNOWN');
            break;
          }
        }
      });

      // Wait for scan to complete (it stops automatically after timeout)
      await Future.delayed(const Duration(seconds: 13)); // slightly longer than scan timeout
      
      if (!beaconFound && mounted && _isScanning) {
         setState(() {
           _isError = true;
           _isScanning = false;
           _status = 'Teacher not found nearby.\nEnsure you are close to the teacher.';
         });
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = e.toString().replaceAll('Exception: ', '');
          _isError = true;
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bluetooth Proximity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isScanning)
            const CircularProgressIndicator()
          else if (_isError)
            const Icon(Icons.error_outline, color: Colors.orange, size: 48)
          else 
            const Icon(Icons.bluetooth_searching, size: 48, color: Colors.blue),
            
          const SizedBox(height: 16),
          Text(_status, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        if (_isError)
          ElevatedButton(
            onPressed: _startBleCheck,
            child: const Text('Retry'),
          ),
      ],
    );
  }
}
