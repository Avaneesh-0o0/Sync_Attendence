import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:ui';

/// Large attendance counter with progress ring visualization
/// Overhauled with Cyberpunk Design System
class AttendanceCounterWidget extends StatelessWidget {
  final int presentCount;
  final int totalCount;

  const AttendanceCounterWidget({
    super.key,
    required this.presentCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = totalCount > 0 ? presentCount / totalCount : 0.0;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              // Inner Grid Ring
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat()).rotate(duration: 10000.ms),
              CircularPercentIndicator(
                radius: 80,
                lineWidth: 12.0,
                percent: percentage,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$presentCount',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        
                        color: primaryColor,
                        fontSize: 36,
                        shadows: [
                          Shadow(
                            color: primaryColor.withValues(alpha: 0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'PRESENT',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'Space Grotesk',
                        letterSpacing: 1.5,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                progressColor: primaryColor,
                backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1200,
              ),
            ],
          ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          
          // Glassmorphic stats container
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'TOTAL CAPACITY',
                      '$totalCount',
                      theme.colorScheme.onSurface,
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                    _buildStatItem(
                      context,
                      'NET YIELD',
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            
            color: valueColor,
            shadows: [
              Shadow(
                color: valueColor.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontFamily: 'Space Grotesk',
            letterSpacing: 1.0,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
