import 'package:flutter/material.dart';


import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Attendance mode selection widget
/// Displays three mode options: QR Code, Bluetooth, and Hybrid
class AttendanceModeSelectorWidget extends StatelessWidget {
  final String? selectedMode;
  final Function(String) onModeChanged;

  const AttendanceModeSelectorWidget({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),

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
                iconName: 'settings',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(

                'Attendance Mode',
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
          const SizedBox(height: 16),


          // QR Code Mode
          _buildModeCard(
            context: context,
            mode: 'QR Code',
            icon: 'qr_code_scanner',
            description: 'Students scan QR code to mark attendance',
            isSelected: selectedMode == 'QR Code',
            onTap: () => onModeChanged('QR Code'),
          ),

          const SizedBox(height: 12),


          // Bluetooth Mode
          _buildModeCard(
            context: context,
            mode: 'Bluetooth',
            icon: 'bluetooth',
            description: 'Proximity-based attendance via Bluetooth',
            isSelected: selectedMode == 'Bluetooth',
            onTap: () => onModeChanged('Bluetooth'),
          ),

          const SizedBox(height: 12),


          // Hybrid Mode
          _buildModeCard(
            context: context,
            mode: 'Hybrid',
            icon: 'merge_type',
            description: 'Combines QR code and Bluetooth verification',
            isSelected: selectedMode == 'Hybrid',
            onTap: () => onModeChanged('Hybrid'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String mode,
    required String icon,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(

                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
