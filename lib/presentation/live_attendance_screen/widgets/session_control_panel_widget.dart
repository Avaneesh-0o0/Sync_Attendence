import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../../core/app_export.dart';

/// Session control panel with pause, end, and extend time buttons
class SessionControlPanelWidget extends StatelessWidget {
  final VoidCallback onPauseSession;
  final VoidCallback onEndSession;
  final VoidCallback onExtendTime;
  final bool isPaused;

  const SessionControlPanelWidget({
    super.key,
    required this.onPauseSession,
    required this.onEndSession,
    required this.onExtendTime,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildControlButton(
                    context,
                    theme,
                    label: isPaused ? 'Resume' : 'Pause',
                    icon: isPaused ? 'play_arrow' : 'pause',
                    backgroundColor: AppTheme.warningLight,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onPauseSession();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(

                  child: _buildControlButton(
                    context,
                    theme,
                    label: 'Extend',
                    icon: 'add_circle_outline',
                    backgroundColor: theme.colorScheme.primary,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onExtendTime();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildControlButton(

              context,
              theme,
              label: 'End Session',
              icon: 'stop_circle',
              backgroundColor: theme.colorScheme.error,
              onPressed: () {
                HapticFeedback.heavyImpact();
                _showEndSessionDialog(context);
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    ThemeData theme, {
    required String label,
    required String icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
    bool isFullWidth = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: Size(isFullWidth ? double.infinity : 100, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(iconName: icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(

            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),

        ],
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: theme.colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(

              'End Session?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to end this attendance session? This action cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onEndSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'End Session',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
