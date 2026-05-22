import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import '../../../core/app_export.dart';

/// Bluetooth status indicator displaying broadcasting status and connected devices
class BluetoothStatusWidget extends StatelessWidget {
  final bool isBroadcasting;
  final int connectedDevices;

  const BluetoothStatusWidget({
    super.key,
    required this.isBroadcasting,
    required this.connectedDevices,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Status colors based on broadcasting state
    final statusColor = isBroadcasting 
        ? theme.colorScheme.primary 
        : theme.colorScheme.error;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: isBroadcasting ? 0.15 : 0.05),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Animated Bluetooth Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.5),
                              width: 1,
                            ),
                            boxShadow: isBroadcasting ? [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ] : [],
                          ),
                          child: Icon(
                            isBroadcasting ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                            color: statusColor,
                            size: 20,
                          )
                          .animate(target: isBroadcasting ? 1 : 0)
                          .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.5)),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BLE TRANSMISSION',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                
                                fontSize: 12,
                                letterSpacing: 1.5,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isBroadcasting ? 'ACTIVE / BROADCASTING' : 'OFFLINE',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Space Grotesk',
                                letterSpacing: 1.0,
                              ),
                            ).animate(target: isBroadcasting ? 1 : 0)
                             .fadeIn()
                             .tint(color: Colors.white, duration: 500.ms),
                          ],
                        ),
                      ],
                    ),
                    // Pulse Indicator
                    if (isBroadcasting)
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.8),
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1000.ms, curve: Curves.easeInOut)
                      .then()
                      .scale(begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8), duration: 1000.ms, curve: Curves.easeInOut)
                    else
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Connected Devices Strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.devices_other,
                        color: theme.colorScheme.primary.withValues(alpha: 0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$connectedDevices NODE(S) CONNECTED',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                )
                .animate(target: connectedDevices > 0 ? 1 : 0)
                .shimmer(duration: 2000.ms),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }
}
