import 'package:flutter/material.dart';


import '../../../core/app_export.dart';

/// Live student list with real-time attendance updates
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
      child: students.isEmpty
          ? _buildEmptyState(context, theme)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: students.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentCard(context, theme, student);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'people_outline',
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 64,
          ),
          const SizedBox(height: 16),

          Text(
            'No students marked attendance yet',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Pull down to refresh',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> student,
  ) {
    final isPresent = student['isPresent'] as bool? ?? false;
    final timestamp = student['timestamp'] as String? ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPresent
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 4,
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
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: student['avatar'] != null
                  ? ClipOval(
                      child: CustomImageWidget(
                        imageUrl: student['avatar'] as String,
                        width: 48,
                        height: 48,

                        fit: BoxFit.cover,
                        semanticLabel:
                            student['semanticLabel'] as String? ??
                            'Student profile photo',
                      ),
                    )
                  : Center(
                      child: Text(
                        (student['name'] as String? ?? 'S')[0].toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'] as String? ?? 'Unknown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'badge',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      const SizedBox(width: 4),

                      Text(
                        'Roll: ${student['rollNumber'] ?? 'N/A'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (student['verificationMethod'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            student['verificationMethod'].toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: isPresent
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: isPresent ? 'check_circle' : 'cancel',
                        color: isPresent
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                        size: 14,
                      ),
                      const SizedBox(width: 4),

                      Text(
                        isPresent ? 'Present' : 'Absent',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isPresent
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (timestamp.isNotEmpty) ...[
                  const SizedBox(height: 4),

                  Text(
                    timestamp,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
