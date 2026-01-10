import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Large prominent button for marking attendance
/// Adapts based on attendance mode (QR/Bluetooth/Hybrid)
class MarkAttendanceButtonWidget extends StatelessWidget {
  final String mode;
  final bool isMarked;
  final VoidCallback onPressed;

  const MarkAttendanceButtonWidget({
    super.key,
    required this.mode,
    required this.isMarked,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isMarked) {
      return _buildMarkedButton(context, theme);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),

      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 24),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: _getIconForMode(mode),
              size: 28,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(width: 12),
            Text(

              _getButtonTextForMode(mode),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildMarkedButton(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24),

      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.secondary, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            size: 28,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Text(
            'Attendance Marked',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),

        ],
      ),
    );
  }

  String _getIconForMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'qr':
        return 'qr_code_scanner';
      case 'bluetooth':
        return 'bluetooth';
      case 'hybrid':
        return 'merge_type';
      default:
        return 'qr_code_scanner';
    }
  }

  String _getButtonTextForMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'qr':
        return 'Scan QR Code';
      case 'bluetooth':
        return 'Mark via Bluetooth';
      case 'hybrid':
        return 'Mark Attendance';
      default:
        return 'Mark Attendance';
    }
  }
}
