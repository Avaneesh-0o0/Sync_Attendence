import 'package:flutter/material.dart';


import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Detailed report section with expandable subject cards
/// Shows session-by-session breakdown and student-wise percentages
class DetailedReportWidget extends StatefulWidget {
  final List<Map<String, dynamic>> subjectReports;

  const DetailedReportWidget({super.key, required this.subjectReports});

  @override
  State<DetailedReportWidget> createState() => _DetailedReportWidgetState();
}

class _DetailedReportWidgetState extends State<DetailedReportWidget> {
  final Set<int> _expandedIndices = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject-wise Reports',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(

          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.subjectReports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {

            final report = widget.subjectReports[index];
            final isExpanded = _expandedIndices.contains(index);

            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        isExpanded
                            ? _expandedIndices.remove(index)
                            : _expandedIndices.add(index);
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(

                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report['subject'] as String,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(

                                  '${report['totalSessions']} sessions • ${report['averageAttendance']}% avg',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomIconWidget(
                            iconName: isExpanded
                                ? 'expand_less'
                                : 'expand_more',
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),

                        ],
                      ),
                    ),
                  ),
                  if (isExpanded) ...[
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Sessions',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...(report['sessions'] as List).map((session) {

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session['date'] as String,
                                            style: theme.textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (session['note'] != null && (session['note'] as String).isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(

                                                'Note: ${session['note']}',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  fontStyle: FontStyle.italic,
                                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.note_add_outlined, size: 18, color: theme.colorScheme.primary),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () => _showAddNoteDialog(context, index, session),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getAttendanceColor(
                                              session['attendance'] as int,
                                              theme,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${session['present']}/${session['total']} (${session['attendance']}%)',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: _getAttendanceColor(
                                                    session['attendance'] as int,
                                                    theme,
                                                  ),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),

                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getAttendanceColor(int percentage, ThemeData theme) {
    if (percentage >= 75) {
      return theme.colorScheme.secondary;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return theme.colorScheme.error;
    }
  }

  void _showAddNoteDialog(BuildContext context, int reportIndex, Map<String, dynamic> session) {
    final controller = TextEditingController(text: session['note'] ?? '');


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Session Note'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a note about this session...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                session['note'] = controller.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Note saved')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

