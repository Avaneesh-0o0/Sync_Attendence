import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App bar variant types for different screen contexts
enum AppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// App bar with back button for navigation stack
  withBackButton,

  /// App bar with search functionality
  withSearch,

  /// Transparent app bar for overlay scenarios
  transparent,

  /// App bar with sync status indicator
  withSyncStatus,
}

/// Custom app bar for educational attendance application
/// Implements Contemporary Educational Minimalism with role-based features
/// Optimized for both student and teacher workflows
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text displayed in the app bar
  final String title;

  /// App bar variant determining layout and features
  final AppBarVariant variant;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Leading widget (overrides default back button if provided)
  final Widget? leading;

  /// Action widgets displayed on the right side
  final List<Widget>? actions;

  /// Whether to show sync status indicator
  final bool showSyncStatus;

  /// Sync status - true for synced, false for pending, null for offline
  final bool? syncStatus;

  /// Callback for search functionality
  final ValueChanged<String>? onSearch;

  /// Background color override
  final Color? backgroundColor;

  /// Whether to center the title
  final bool centerTitle;

  /// Elevation override
  final double? elevation;

  /// Whether to show bottom border
  final bool showBottomBorder;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = AppBarVariant.standard,
    this.subtitle,
    this.leading,
    this.actions,
    this.showSyncStatus = false,
    this.syncStatus,
    this.onSearch,
    this.backgroundColor,
    this.centerTitle = true,
    this.elevation,
    this.showBottomBorder = false,
  });

  /// Factory constructor for Teacher Dashboard
  factory CustomAppBar.teacherDashboard({
    required String title,
    VoidCallback? onNotificationPressed,
    VoidCallback? onSettingsPressed,
    int notificationCount = 0,
  }) {
    return CustomAppBar(
      title: title,
      centerTitle: true, // Dashboard titles are often centered
      showSyncStatus: true, // Teacher dashboard should show sync status
      actions: [
        // Notification Icon
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 24),
              onPressed: onNotificationPressed,
              tooltip: 'Notifications',
              color: Colors.white,
            ),

            if (notificationCount > 0)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '$notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),

        // Settings Icon
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 24),
          onPressed: onSettingsPressed,
          tooltip: 'Settings',
          color: Colors.white,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// Factory constructor for Student Attendance
  factory CustomAppBar.studentAttendance({
    required String title,
    VoidCallback? onHistoryPressed,
  }) {
    return CustomAppBar(
      title: title,
      centerTitle: true,
      actions: [
        if (onHistoryPressed != null)
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: onHistoryPressed,
            tooltip: 'History',
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 72.0 : 56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: _getBackgroundColor(context),
      foregroundColor: _getForegroundColor(context),
      elevation: elevation ?? (variant == AppBarVariant.transparent ? 0 : 2.0),
      centerTitle: centerTitle,
      systemOverlayStyle: _getSystemOverlayStyle(context),
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: _buildActions(context),
      bottom: showBottomBorder
          ? PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Container(
                height: 1.0,
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            )
          : null,
    );
  }

  /// Get background color based on variant and theme
  Color? _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor;

    final colorScheme = Theme.of(context).colorScheme;

    switch (variant) {
      case AppBarVariant.transparent:
        return Colors.transparent;
      case AppBarVariant.standard:
      case AppBarVariant.withBackButton:
      case AppBarVariant.withSearch:
      case AppBarVariant.withSyncStatus:
        return colorScheme.primary;
    }
  }

  /// Get foreground color based on background
  Color _getForegroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (variant == AppBarVariant.transparent) {
      return colorScheme.onSurface;
    }

    return colorScheme.onPrimary;
  }

  /// Get system overlay style for status bar
  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isTransparent = variant == AppBarVariant.transparent;

    if (isTransparent) {
      return brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light;
    }

    return SystemUiOverlayStyle.light;
  }

  /// Build leading widget based on variant
  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (variant == AppBarVariant.withBackButton) {
      return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        tooltip: 'Back',
      );
    }

    // Check if there's a route to pop
    if (Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        tooltip: 'Back',
      );
    }

    return null;
  }

  /// Build title widget with optional subtitle
  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = _getForegroundColor(context);

    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.appBarTheme.titleTextStyle?.copyWith(
              color: foregroundColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: foregroundColor.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: theme.appBarTheme.titleTextStyle?.copyWith(color: foregroundColor),
    );
  }

  /// Build action widgets including sync status
  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> actionWidgets = [];

    // Add sync status indicator if enabled
    if (showSyncStatus || variant == AppBarVariant.withSyncStatus) {
      actionWidgets.add(_buildSyncStatusIndicator(context));
    }

    // Add search button for search variant
    if (variant == AppBarVariant.withSearch) {
      actionWidgets.add(_buildSearchButton(context));
    }

    // Add custom actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isEmpty ? null : actionWidgets;
  }

  /// Build sync status indicator
  Widget _buildSyncStatusIndicator(BuildContext context) {
    final foregroundColor = _getForegroundColor(context);

    IconData icon;
    Color iconColor;
    String tooltip;

    if (syncStatus == null) {
      // Offline mode
      icon = Icons.cloud_off_outlined;
      iconColor = foregroundColor.withValues(alpha: 0.7);
      tooltip = 'Offline Mode';
    } else if (syncStatus == true) {
      // Synced
      icon = Icons.cloud_done_outlined;
      iconColor = foregroundColor;
      tooltip = 'Synced';
    } else {
      // Pending sync
      icon = Icons.cloud_sync_outlined;
      iconColor = foregroundColor.withValues(alpha: 0.9);
      tooltip = 'Syncing...';
    }

    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(icon, size: 22),
        color: iconColor,
        onPressed: () {
          // Show sync status details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tooltip), duration: Duration(seconds: 2)),
          );
        },
        tooltip: tooltip,
      ),
    );
  }

  /// Build search button
  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        HapticFeedback.lightImpact();
        _showSearchDialog(context);
      },
      tooltip: 'Search',
    );
  }

  /// Show search dialog
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(onSearch: onSearch),
    );
  }
}

/// Search dialog for app bar search functionality
class _SearchDialog extends StatefulWidget {
  final ValueChanged<String>? onSearch;

  const _SearchDialog({this.onSearch});

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.onSearch?.call(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final query = _controller.text;
                    if (query.isNotEmpty) {
                      widget.onSearch?.call(query);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Search'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
