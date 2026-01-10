import 'package:flutter/material.dart';


import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Advanced settings section with collapsible options
/// Includes grace period, proximity sensitivity, and QR refresh interval
class AdvancedSettingsWidget extends StatefulWidget {
  final int gracePeriod;
  final double proximitySensitivity;
  final int qrRefreshInterval;
  final Function(int) onGracePeriodChanged;
  final Function(double) onProximitySensitivityChanged;
  final Function(int) onQrRefreshIntervalChanged;

  const AdvancedSettingsWidget({
    super.key,
    required this.gracePeriod,
    required this.proximitySensitivity,
    required this.qrRefreshInterval,
    required this.onGracePeriodChanged,
    required this.onProximitySensitivityChanged,
    required this.onQrRefreshIntervalChanged,
  });

  @override
  State<AdvancedSettingsWidget> createState() => _AdvancedSettingsWidgetState();
}

class _AdvancedSettingsWidgetState extends State<AdvancedSettingsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(

                children: [
                  CustomIconWidget(
                    iconName: 'tune',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(

                    child: Text(
                      'Advanced Settings',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grace period setting
                  _buildSettingItem(
                    context: context,
                    label: 'Late Arrival Grace Period',
                    value: '${widget.gracePeriod} minutes',
                    icon: 'timer',
                    onTap: () => _showGracePeriodPicker(context),
                  ),

                  const SizedBox(height: 16),


                  // Proximity sensitivity setting
                  _buildSettingItem(
                    context: context,
                    label: 'Bluetooth Proximity Sensitivity',
                    value: _getSensitivityLabel(widget.proximitySensitivity),
                    icon: 'signal_cellular_alt',
                    onTap: () => _showProximitySensitivityPicker(context),
                  ),

                  const SizedBox(height: 16),


                  // QR refresh interval setting
                  _buildSettingItem(
                    context: context,
                    label: 'QR Code Refresh Interval',
                    value: '${widget.qrRefreshInterval} seconds',
                    icon: 'refresh',
                    onTap: () => _showQrRefreshIntervalPicker(context),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required String label,
    required String value,
    required String icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(

                    value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _getSensitivityLabel(double value) {
    if (value <= 0.3) return 'Low (Far range)';
    if (value <= 0.6) return 'Medium (Normal range)';
    return 'High (Close range)';
  }

  void _showGracePeriodPicker(BuildContext context) {
    final theme = Theme.of(context);
    int tempGracePeriod = widget.gracePeriod;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Grace Period'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tempGracePeriod minutes',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Slider(
                    value: tempGracePeriod.toDouble(),
                    min: 0,
                    max: 30,
                    divisions: 6,
                    label: '$tempGracePeriod min',
                    onChanged: (value) {
                      setState(() {
                        tempGracePeriod = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onGracePeriodChanged(tempGracePeriod);
                    Navigator.pop(context);
                  },
                  child: Text('Set'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showProximitySensitivityPicker(BuildContext context) {
    final theme = Theme.of(context);
    double tempSensitivity = widget.proximitySensitivity;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Proximity Sensitivity'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getSensitivityLabel(tempSensitivity),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(

                    value: tempSensitivity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    onChanged: (value) {
                      setState(() {
                        tempSensitivity = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Low',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'High',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onProximitySensitivityChanged(tempSensitivity);
                    Navigator.pop(context);
                  },
                  child: Text('Set'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQrRefreshIntervalPicker(BuildContext context) {
    final theme = Theme.of(context);
    int tempInterval = widget.qrRefreshInterval;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('QR Refresh Interval'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tempInterval seconds',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Slider(
                    value: tempInterval.toDouble(),
                    min: 30,
                    max: 90,
                    divisions: 12,
                    label: '$tempInterval sec',
                    onChanged: (value) {
                      setState(() {
                        tempInterval = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onQrRefreshIntervalChanged(tempInterval);
                    Navigator.pop(context);
                  },
                  child: Text('Set'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
