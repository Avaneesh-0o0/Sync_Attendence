import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tab item configuration for custom tab bar
class TabItem {
  /// Display label for the tab
  final String label;

  /// Optional icon for the tab
  final IconData? icon;

  /// Optional badge count for notifications
  final int? badgeCount;

  const TabItem({required this.label, this.icon, this.badgeCount});
}

/// Tab bar variant types for different contexts
enum TabBarVariant {
  /// Standard horizontal tabs with text labels
  standard,

  /// Tabs with icons and text labels
  withIcons,

  /// Scrollable tabs for many items
  scrollable,

  /// Fixed tabs with equal width
  fixed,

  /// Tabs with badges for notifications
  withBadges,
}

/// Custom tab bar for educational attendance application
/// Implements teacher dashboard multi-session workflow with clear visual hierarchy
/// Optimized for tablet usage with large touch targets
class CustomTabBar extends StatelessWidget {
  /// List of tab items to display
  final List<TabItem> tabs;

  /// Currently selected tab index
  final int currentIndex;

  /// Callback when tab is tapped
  final ValueChanged<int> onTabChanged;

  /// Tab bar variant determining layout and features
  final TabBarVariant variant;

  /// Background color override
  final Color? backgroundColor;

  /// Indicator color override
  final Color? indicatorColor;

  /// Label color override
  final Color? labelColor;

  /// Unselected label color override
  final Color? unselectedLabelColor;

  /// Whether to show divider below tabs
  final bool showDivider;

  /// Custom indicator weight
  final double? indicatorWeight;

  /// Custom padding for tabs
  final EdgeInsetsGeometry? padding;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabChanged,
    this.variant = TabBarVariant.standard,
    this.backgroundColor,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.showDivider = true,
    this.indicatorWeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 8),
          child: _buildTabBar(context),
        ),
      ),
    );
  }

  /// Build tab bar based on variant
  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isScrollable = variant == TabBarVariant.scrollable || tabs.length > 4;

    return TabBar(
      tabs: _buildTabs(context),
      isScrollable: isScrollable,
      indicatorColor: indicatorColor ?? colorScheme.primary,
      indicatorWeight: indicatorWeight ?? 3.0,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: labelColor ?? colorScheme.primary,
      unselectedLabelColor:
          unselectedLabelColor ?? colorScheme.onSurface.withValues(alpha: 0.6),
      labelStyle: theme.tabBarTheme.labelStyle,
      unselectedLabelStyle: theme.tabBarTheme.unselectedLabelStyle,
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.primary.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.primary.withValues(alpha: 0.05);
        }
        return null;
      }),
      splashFactory: InkRipple.splashFactory,
      onTap: (index) {
        if (index != currentIndex) {
          HapticFeedback.lightImpact();
          onTabChanged(index);
        }
      },
    );
  }

  /// Build individual tab widgets
  List<Widget> _buildTabs(BuildContext context) {
    return tabs.asMap().entries.map((entry) {
      final index = entry.key;
      final tab = entry.value;
      final isSelected = index == currentIndex;

      return Tab(
        height: 56,
        child: _buildTabContent(
          context: context,
          tab: tab,
          isSelected: isSelected,
        ),
      );
    }).toList();
  }

  /// Build tab content based on variant
  Widget _buildTabContent({
    required BuildContext context,
    required TabItem tab,
    required bool isSelected,
  }) {

    // Standard tab with text only
    if (variant == TabBarVariant.standard ||
        (variant == TabBarVariant.fixed && tab.icon == null)) {
      return _buildTextTab(
        context: context,
        label: tab.label,
        isSelected: isSelected,
      );
    }

    // Tab with icon and text
    if (variant == TabBarVariant.withIcons ||
        (tab.icon != null && variant != TabBarVariant.withBadges)) {
      return _buildIconTextTab(
        context: context,
        label: tab.label,
        icon: tab.icon!,
        isSelected: isSelected,
      );
    }

    // Tab with badge
    if (variant == TabBarVariant.withBadges || tab.badgeCount != null) {
      return _buildBadgeTab(
        context: context,
        label: tab.label,
        icon: tab.icon,
        badgeCount: tab.badgeCount,
        isSelected: isSelected,
      );
    }

    // Default to text tab
    return _buildTextTab(
      context: context,
      label: tab.label,
      isSelected: isSelected,
    );
  }

  /// Build text-only tab
  Widget _buildTextTab({
    required BuildContext context,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  /// Build tab with icon and text
  Widget _buildIconTextTab({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isSelected
        ? (labelColor ?? colorScheme.primary)
        : (unselectedLabelColor ??
              colorScheme.onSurface.withValues(alpha: 0.6));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(width: 8),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  /// Build tab with badge
  Widget _buildBadgeTab({
    required BuildContext context,
    required String label,
    required IconData? icon,
    required int? badgeCount,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isSelected
        ? (labelColor ?? colorScheme.primary)
        : (unselectedLabelColor ??
              colorScheme.onSurface.withValues(alpha: 0.6));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 20, color: color),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: _buildBadge(context, badgeCount),
                  ),
              ],
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (icon == null && badgeCount != null && badgeCount > 0) ...[
            SizedBox(width: 8),
            _buildBadge(context, badgeCount),
          ],
        ],
      ),
    );
  }

  /// Build badge indicator
  Widget _buildBadge(BuildContext context, int count) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: count > 9 ? 6 : 5, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints(minWidth: 18, minHeight: 18),
      child: Center(
        child: Text(
          displayCount,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onError,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Tab bar controller wrapper for managing tab state
class CustomTabBarController extends StatefulWidget {
  /// List of tab items
  final List<TabItem> tabs;

  /// Initial selected index
  final int initialIndex;

  /// Tab bar variant
  final TabBarVariant variant;

  /// Builder for tab content
  final Widget Function(BuildContext context, int index) builder;

  /// Optional callback when tab changes
  final ValueChanged<int>? onTabChanged;

  /// Custom tab bar styling
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final bool showDivider;

  const CustomTabBarController({
    super.key,
    required this.tabs,
    required this.builder,
    this.initialIndex = 0,
    this.variant = TabBarVariant.standard,
    this.onTabChanged,
    this.backgroundColor,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.showDivider = true,
  });

  @override
  State<CustomTabBarController> createState() => _CustomTabBarControllerState();
}

class _CustomTabBarControllerState extends State<CustomTabBarController>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      widget.onTabChanged?.call(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTabBar(
          tabs: widget.tabs,
          currentIndex: _tabController.index,
          onTabChanged: (index) {
            _tabController.animateTo(index);
          },
          variant: widget.variant,
          backgroundColor: widget.backgroundColor,
          indicatorColor: widget.indicatorColor,
          labelColor: widget.labelColor,
          unselectedLabelColor: widget.unselectedLabelColor,
          showDivider: widget.showDivider,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(
              widget.tabs.length,
              (index) => widget.builder(context, index),
            ),
          ),
        ),
      ],
    );
  }
}
