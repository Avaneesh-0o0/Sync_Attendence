import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/session_header_widget.dart';
import './widgets/attendance_counter_widget.dart';
import './widgets/qr_code_display_widget.dart';
import './widgets/bluetooth_status_widget.dart';
import './widgets/student_list_widget.dart';
import './widgets/session_control_panel_widget.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart'; // BLE Advertising
import '../../services/teacher_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io'; // For Platform check
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // For Adapter State

class LiveAttendanceScreen extends StatefulWidget {
  const LiveAttendanceScreen({super.key});

  @override
  State<LiveAttendanceScreen> createState() => _LiveAttendanceScreenState();
}

class _LiveAttendanceScreenState extends State<LiveAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _timer;
  int _elapsedSeconds = 0;
  // Use a stream or periodic timer to update UI, but rely on Wall Clock time for logic
  int _qrRemainingSeconds = 45;
  String _qrToken = '';
  // Track the current window ID to avoid regenerating token for the same window repeatedly if not needed
  int _lastWindowId = -1;
  final TeacherService _teacherService = TeacherService();
  Stream<List<Map<String, dynamic>>>? _attendanceStream;
  
  // Bluetooth
  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();
  bool _isBroadcasting = false;
  bool _isPaused = false;
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startTimer();
    
    // Initialize attendance stream once context is available (in didChangeDependencies)
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_attendanceStream == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final sessionId = args?['sessionId'];
      if (sessionId != null) {
        _attendanceStream = _teacherService.getAttendanceStream(sessionId);
        _generateQrToken(sessionId);
        if (_shouldBroadcast(args)) {
           _startBluetoothAdvertising(sessionId);
        }
      }
    }
  }

  bool _shouldBroadcast(Map<String, dynamic>? args) {
     final mode = args?['mode'];
     return mode == 'Bluetooth' || mode == 'Hybrid';
  }

  Future<void> _startBluetoothAdvertising(String sessionId) async {
    if (kIsWeb) {
      debugPrint("Bluetooth Advertising is not supported on Web.");
      return; 
    }

    // 1. Ensure Bluetooth is ON
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
      if (Platform.isAndroid) {
        try {
          await FlutterBluePlus.turnOn();
        } catch (e) {
          debugPrint("Failed to turn on Bluetooth: $e");
           if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please turn on Bluetooth to broadcast attendance.')),
            );
          }
          return;
        }
      } else {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please turn on Bluetooth to broadcast attendance.')),
            );
        }
        return;
      }
    }

    // Wait for it to be on
    try {
      await FlutterBluePlus.adapterState
          .where((s) => s == BluetoothAdapterState.on)
          .first
          .timeout(const Duration(seconds: 5));
    } catch (e) {
       // Timeout waiting for BT
       return;
    }

    // Basic formatting for UUID (ensure it fits BLE specs, usually 128-bit or 16-bit)
    // For simplicity, we are using a fixed Service UUID for the app and putting sessionId in data if possible,
    // or just advertising the presence. 
    // REAL WORLD: You'd want a proper 128-bit UUID generation strategy.
    // For now, let's use a hashed version of sessionId or a fixed app UUID.
    
    // Using a fixed UUID for Attendix Service
    const String serviceUuid = "bf27730d-860a-4e09-889c-2d8b6a9e0fe7"; 
    
    // We can also include part of the session ID in manufacturer data or local name
    
    final AdvertiseData advertiseData = AdvertiseData(
      serviceUuid: serviceUuid,
      localName: "Attendix-$sessionId", 
      includeDeviceName: false,
    );

    final AdvertiseSettings advertiseSettings = AdvertiseSettings(
      advertiseMode: AdvertiseMode.advertiseModeBalanced,
      txPowerLevel: AdvertiseTxPower.advertiseTxPowerMedium,
      connectable: false, 
      timeout: 0, 
    );

    try {
      await _blePeripheral.start(advertiseData: advertiseData, advertiseSettings: advertiseSettings);
       if (mounted) {
        setState(() {
          _isBroadcasting = true;
        });
      }
    } catch (e) {
      debugPrint("Bluetooth Advertising Error: $e");
    }
  }



  void _generateQrToken(String sessionId) {
    if (sessionId.isEmpty) return;
    
    // Time-based windowing (45 seconds)
    final now = DateTime.now();
    final windowSize = 45; // seconds
    final currentWindowId = now.millisecondsSinceEpoch ~/ (windowSize * 1000);

    // Only regenerate if we entered a new window
    if (currentWindowId != _lastWindowId) {
       _lastWindowId = currentWindowId;
       
       final bytes = utf8.encode('$sessionId:$currentWindowId');
       final digest = sha256.convert(bytes);
       
       // Calculate remaining time in this window
       final secondsInCurrentWindow = (now.millisecondsSinceEpoch ~/ 1000) % windowSize;
       final remaining = windowSize - secondsInCurrentWindow;

       if (mounted) {
        setState(() {
          _qrToken = 'ATTENDIX_QR:$sessionId:${digest.toString().substring(0, 8)}';
          _qrRemainingSeconds = remaining;
        });
       }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isPaused) {
        setState(() {
          _elapsedSeconds++;
          
          // Update QR Timer based on System Clock to prevent drift
          final windowSize = 45;
          final now = DateTime.now();
          final secondsInCurrentWindow = (now.millisecondsSinceEpoch ~/ 1000) % windowSize;
          _qrRemainingSeconds = windowSize - secondsInCurrentWindow;
          
          // Regenerate token if we just flipped to a new window (remaining == 45 or close to it)
          // Or if we haven't generated one yet
          if (_qrRemainingSeconds == windowSize || _qrRemainingSeconds <= 1 || _qrToken.isEmpty) {
             final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
             if (args?['sessionId'] != null) {
               _generateQrToken(args!['sessionId']);
             }
          }
        });
      }
    });

    // Monitor Bluetooth State Changes
    if (!kIsWeb) {
      FlutterBluePlus.adapterState.listen((state) {
        if (state == BluetoothAdapterState.on && !_isBroadcasting && !_isPaused) {
             final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
             if (_shouldBroadcast(args)) {
                _startBluetoothAdvertising(args!['sessionId']);
             }
        } else if (state == BluetoothAdapterState.off) {
           setState(() => _isBroadcasting = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _blePeripheral.stop();
    super.dispose();
  }

  String _formatElapsedTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    final subject = args?['subject'] ?? 'Subject Not Found';
    final className = (args?['classes'] as List?)?.first ?? 'Class Not Found';
    final mode = args?['mode'] ?? 'QR';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Live Attendance',
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _attendanceStream,
        builder: (context, snapshot) {
          final attendanceList = snapshot.data ?? [];
          
          final List<Map<String, dynamic>> students = attendanceList.map((a) {
            return {
              'name': a['student_name'] ?? 'Student',
              'rollNumber': a['roll_number'] ?? 'N/A',
              'isPresent': true,
              'timestamp': _formatMarkedAt(a['marked_at']),
              'verificationMethod': a['verification_method'],
            };
          }).toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                 SliverToBoxAdapter(
                  child: SessionHeaderWidget(
                    subject: subject,
                    className: className,
                    section: 'A',
                    elapsedTime: _formatElapsedTime(_elapsedSeconds),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                     child: Hero(
                      tag: 'attendance_counter',
                      child: AttendanceCounterWidget(
                        presentCount: students.length,
                        totalCount: args?['totalStudents'] ?? 50,
                      ),
                    ),
                  ),
                ),
                 SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      indicatorColor: theme.colorScheme.primary,
                      tabs: const [
                        Tab(text: 'Session Status'),
                        Tab(text: 'Student List'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Session Status Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      // QR Code Card
                      if (mode == 'QR' || mode == 'Hybrid' || mode == 'QR Code')
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: QrCodeDisplayWidget(
                            qrData: _isPaused ? 'SESSION PAUSED' : (_qrToken.isEmpty ? 'Loading...' : _qrToken),
                            remainingSeconds: _qrRemainingSeconds,
                            onRefresh: () {
                              if (!_isPaused && args?['sessionId'] != null) {
                                _generateQrToken(args!['sessionId']);
                                setState(() => _qrRemainingSeconds = 45);
                              }
                            },
                          ),
                        ),

                      // Bluetooth Status Card
                      // Show if mode matches, regardless of platform (show warning if web/desktop)
                      if (mode == 'Bluetooth' || mode == 'Hybrid')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                               if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS))
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                       const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                       const SizedBox(width: 12),
                                       Expanded(
                                         child: Text(
                                           'Bluetooth broadcasting is optimized for Mobile (Android/iOS). It may not work on this device.',
                                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange[800]),
                                         ),
                                       )
                                    ],
                                  ),
                                ),
                                BluetoothStatusWidget(
                                  isBroadcasting: _isBroadcasting,
                                  connectedDevices: students.where((s) => s['verificationMethod'] == 'Bluetooth').length,
                                ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
                      
                      // Session Controls
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SessionControlPanelWidget(
                          isPaused: _isPaused,
                          onPauseSession: _togglePauseSession,
                          onEndSession: () {
                            _showEndSessionDialog(args?['sessionId']);
                          },
                          onExtendTime: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Session time extended!')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Student List Tab
                StudentListWidget(
                  students: students,
                  onRefresh: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatMarkedAt(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  void _togglePauseSession() async {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      // Pause Bluetooth if active
       if (_isBroadcasting) {
         await _blePeripheral.stop();
         setState(() => _isBroadcasting = false);
       }
    } else {
      // Resume - restart Bluetooth if needed
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (_shouldBroadcast(args)) {
         _startBluetoothAdvertising(args!['sessionId']);
      }
      // Force QR refresh
      if (args?['sessionId'] != null) {
        _generateQrToken(args!['sessionId']);
      }
    }
  }

  void _showEndSessionDialog(String? sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Attendance Session?'),
        content: const Text('This will finalize the attendance for all students and save the report.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Stop bluetooth if running
                if (!kIsWeb) {
                  await _blePeripheral.stop();
                }
                
                if (sessionId != null) {
                  await _teacherService.endSession(sessionId);
                }
                
                if (context.mounted) {
                  // Pop the dialog
                  Navigator.of(context).pop(); 
                  // Navigate back to success/dashboard
                  Navigator.of(context).pushNamedAndRemoveUntil('/teacher-dashboard', (route) => false);
                }
              } catch (e) {
                print("Error ending session: $e");
                if (context.mounted) {
                   Navigator.of(context).pop(); // Close dialog on error too? Or show error
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Error ending session: $e'))
                   );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Ensure background opacity
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
