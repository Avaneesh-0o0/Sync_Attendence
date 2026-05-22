import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import '../../../core/app_export.dart';

/// Live student list with real-time attendance updates
/// Overhauled with Cyberpunk Design System
class StudentListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final VoidCallback onRefresh;

  const StudentListWidget({
    super.key,
    required this.students,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      child: students.isEmpty
          ? _buildEmptyState(context, theme)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: students.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentCard(context, theme, student, index);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ]
            ),
            child: Icon(
              Icons.radar,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
              size: 48,
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 1.5.seconds, curve: Curves.easeInOut),
          const SizedBox(height: 24),
          Text(
            'AWAITING SIGNALS',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fadeIn(duration: 800.ms),
          const SizedBox(height: 8),
          Text(
            'NO NODES DETECTED. PULL TO SCAN.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontFamily: 'Space Grotesk',
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildStudentCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> student,
    int index,
  ) {
    final isPresent = student['isPresent'] as bool? ?? false;
    final timestamp = student['timestamp'] as String? ?? '';
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;
    final statusColor = isPresent ? primaryColor : errorColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withValues(alpha: isPresent ? 0.5 : 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: isPresent ? 0.1 : 0.0),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                  color: statusColor.withValues(alpha: 0.1),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: student['avatar'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CustomImageWidget(
                          imageUrl: student['avatar'] as String,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          semanticLabel: student['semanticLabel'] as String? ?? 'Student profile photo',
                        ),
                      )
                    : Center(
                        child: Text(
                          (student['name'] as String? ?? 'S')[0].toUpperCase(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'] as String? ?? 'UNKNOWN IDENTITY',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        fontFamily: 'Space Grotesk',
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ID: ${student['rollNumber'] ?? 'N/A'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (student['verificationMethod'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              student['verificationMethod'].toString().toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontSize: 9,
                                
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPresent ? Icons.check_circle_outline : Icons.cancel_outlined,
                          color: statusColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPresent ? 'VERIFIED' : 'PENDING',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            
                            letterSpacing: 1.0,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (timestamp.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      timestamp,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontFamily: 'Space Grotesk',
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}
