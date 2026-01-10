import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';


import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// QR code display with countdown timer and auto-refresh animation
class QrCodeDisplayWidget extends StatefulWidget {
  final String qrData;
  final int remainingSeconds;
  final VoidCallback onRefresh;

  const QrCodeDisplayWidget({
    super.key,
    required this.qrData,
    required this.remainingSeconds,
    required this.onRefresh,
  });

  @override
  State<QrCodeDisplayWidget> createState() => _QrCodeDisplayWidgetState();
}

class _QrCodeDisplayWidgetState extends State<QrCodeDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(QrCodeDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qrData != widget.qrData) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.remainingSeconds / 45.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scan QR Code',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                decoration: BoxDecoration(
                  color: progress > 0.3
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'timer',
                      color: progress > 0.3
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 4),

                      Text(
                        widget.qrData.isEmpty ? '...' : '${widget.remainingSeconds}s',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: progress > 0.3
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _animationController,
            child: Container(
              width: 250,
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: widget.qrData.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Generating QR...',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      )
                    : QrImageView(
                        data: widget.qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                        foregroundColor: Colors.black,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.3
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),

          Text(
            'Code refreshes automatically',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
