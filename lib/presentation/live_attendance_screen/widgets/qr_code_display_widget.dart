import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/app_export.dart';

/// QR code display with cyberpunk layout, neon HUD gauges, and automatic refresh scanline animations
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
    _animationController.forward(from: 1.0);
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
    final colorScheme = theme.colorScheme;
    final progress = widget.remainingSeconds / 30.0;
    
    final accentColor = progress > 0.3
        ? colorScheme.primary
        : colorScheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Widget
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.qr_code_scanner_outlined, color: colorScheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'DYNAMIC QR VECTOR',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      
                      fontSize: 13,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: accentColor.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      color: accentColor,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.qrData.isEmpty ? '...' : '${widget.remainingSeconds}S',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: accentColor,
                        
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // QR Frame with target bounds
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glowing corners
              ..._buildTargetCorners(accentColor),
              
              FadeTransition(
                opacity: _animationController,
                child: Container(
                  width: 230,
                  height: 230,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Center(
                    child: widget.qrData.isEmpty || widget.qrData == 'Loading...'
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'CREATING MATRIX...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                  
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          )
                        : QrImageView(
                            data: widget.qrData,
                            version: QrVersions.auto,
                            size: 210.0,
                            eyeStyle: const QrEyeStyle(color: Colors.black, eyeShape: QrEyeShape.square),
                            dataModuleStyle: const QrDataModuleStyle(color: Colors.black, dataModuleShape: QrDataModuleShape.square),
                            gapless: true,
                          ),
                  ),
                ),
              ),
              
              // Decorative Scanline sweep effect
              if (widget.qrData.isNotEmpty && widget.qrData != 'Loading...')
                _buildScanlineOverlay(accentColor),
            ],
          ),
          const SizedBox(height: 20),
          
          // Cyber telemetry progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOKEN ROTATION PROGRESS',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.4),
                      
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: accentColor,
                      
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: colorScheme.primary.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sync_alt_outlined,
                size: 12,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(width: 6),
              Text(
                'AUTO-REFRESH PROTOCOL IN OPERATION',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.4),
                  
                  fontSize: 8,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTargetCorners(Color color) {
    const double size = 260.0;
    const double length = 16.0;
    const double thickness = 2.0;
    
    return [
      // Top Left Corner
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: length,
          height: thickness,
          color: color,
        ),
      ),
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: thickness,
          height: length,
          color: color,
        ),
      ),
      // Top Right Corner
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: length,
          height: thickness,
          color: color,
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: thickness,
          height: length,
          color: color,
        ),
      ),
      // Bottom Left Corner
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: length,
          height: thickness,
          color: color,
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: thickness,
          height: length,
          color: color,
        ),
      ),
      // Bottom Right Corner
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: length,
          height: thickness,
          color: color,
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: thickness,
          height: length,
          color: color,
        ),
      ),
    ];
  }

  Widget _buildScanlineOverlay(Color accentColor) {
    return Positioned(
      child: Container(
        width: 220,
        height: 220,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Container().animate(onPlay: (c) => c.repeat())
              .custom(
                duration: 2000.ms,
                builder: (context, val, child) {
                  return Positioned(
                    top: val * 220,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: accentColor,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.8),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
