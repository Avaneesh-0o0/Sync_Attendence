import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';


import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Export button with CSV generation and share functionality
/// Provides native sharing options for attendance reports
class ExportButtonWidget extends StatelessWidget {
  final Function() onExport;

  const ExportButtonWidget({super.key, required this.onExport});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: () => _handleExport(context),
      icon: CustomIconWidget(
        iconName: 'file_download',
        size: 18,
        color: theme.colorScheme.onPrimary,
      ),

      label: Text('Export CSV'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

    );
  }

  Future<void> _handleExport(BuildContext context) async {
    try {
      // Generate CSV content
      onExport();

      // Simulate CSV generation
      await Future.delayed(const Duration(milliseconds: 500));

      final csvContent = _generateMockCSV();

      // Share CSV file
      await Share.share(
        csvContent,
        subject:
            'Attendance Report - ${DateTime.now().toString().split(' ')[0]}',
      );

      Fluttertoast.showToast(
        msg: 'Report exported successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to export report',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  String _generateMockCSV() {
    return '''Student Name,Roll Number,Class,Subject,Attendance %,Sessions Attended,Total Sessions
John Doe,CS001,CS-A,Data Structures,85.5,17,20
Jane Smith,CS002,CS-A,Data Structures,92.0,18,20
Michael Johnson,CS003,CS-A,Data Structures,78.5,16,20
Emily Davis,CS004,CS-A,Data Structures,88.0,18,20
David Wilson,CS005,CS-A,Data Structures,95.5,19,20''';
  }
}
