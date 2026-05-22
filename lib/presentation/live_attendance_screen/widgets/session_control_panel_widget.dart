import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import '../../../core/app_export.dart';

/// Session control panel with pause, end, and extend time buttons
/// Overhauled with Cyberpunk Design System
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
    final primaryColor = theme.colorScheme.primary;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.6),
            border: Border(
              top: BorderSide(
                color: primaryColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, -5),
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
                        label: isPaused ? 'RESUME SECURE LINK' : 'PAUSE SECURE LINK',
                        icon: isPaused ? Icons.play_arrow : Icons.pause,
                        backgroundColor: AppTheme.warningLight,
                        borderColor: AppTheme.warningLight.withValues(alpha: 0.5),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          onPauseSession();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildControlButton(
                        context,
                        theme,
                        label: 'EXTEND CYCLE',
                        icon: Icons.add_circle_outline,
                        backgroundColor: theme.colorScheme.primary,
                        borderColor: theme.colorScheme.primary.withValues(alpha: 0.5),
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
                  label: 'TERMINATE SESSION',
                  icon: Icons.stop_circle_outlined,
                  backgroundColor: theme.colorScheme.error,
                  borderColor: theme.colorScheme.error.withValues(alpha: 0.5),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    _showEndSessionDialog(context);
                  },
                  isFullWidth: true,
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .shimmer(duration: 2500.ms, color: Colors.white.withValues(alpha: 0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    ThemeData theme, {
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onPressed,
    bool isFullWidth = false,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          splashColor: backgroundColor.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: backgroundColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: backgroundColor,
                      fontWeight: FontWeight.w700,
                      
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: theme.colorScheme.surface.withValues(alpha: 0.8),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.error.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: theme.colorScheme.error,
                size: 28,
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 500.ms),
              const SizedBox(width: 12),
              Text(
                'SYSTEM OVERRIDE',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          content: Text(
            'WARNING: Terminating this session will finalize all captured data. This action is irreversible.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Space Grotesk',
              color: theme.colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'ABORT',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onEndSession();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'CONFIRM TERMINATION',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
