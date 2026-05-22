import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

/// Session header widget displaying subject, class details, and elapsed time
/// Overhauled with Cyberpunk Design System
class SessionHeaderWidget extends StatelessWidget {
  final String subject;
  final String className;
  final String section;
  final String elapsedTime;

  const SessionHeaderWidget({
    super.key,
    required this.subject,
    required this.className,
    required this.section,
    required this.elapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(
                color: primaryColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(
                      Icons.radar,
                      color: primaryColor,
                      size: 16,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 2000.ms),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      subject.toUpperCase(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.memory,
                        color: theme.colorScheme.secondary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SYS: $className - SEC: $section',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'Space Grotesk',
                          letterSpacing: 1.2,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: primaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          elapsedTime,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(begin: const Offset(1.0, 1.0), end: const Offset(1.02, 1.02), duration: 1.seconds, curve: Curves.easeInOut),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
