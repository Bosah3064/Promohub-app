import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activeFilters;
  final Function(int) onRemoveFilter;
  final VoidCallback onClearAll;

  const FilterChipsWidget({
    super.key,
    required this.activeFilters,
    required this.onRemoveFilter,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Filters (${activeFilters.length})',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                child: Text(
                  'Clear All',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.sp),
          Wrap(
            spacing: 8.sp,
            runSpacing: 8.sp,
            children: activeFilters.asMap().entries.map((entry) {
              final index = entry.key;
              final filter = entry.value;
              return _buildFilterChip(
                label: filter['label'] as String,
                type: filter['type'] as String,
                onRemove: () => onRemoveFilter(index),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String type,
    required VoidCallback onRemove,
  }) {
    Color chipColor;
    IconData chipIcon;

    switch (type) {
      case 'category':
        chipColor = AppTheme.lightTheme.colorScheme.primaryContainer;
        chipIcon = Icons.category;
        break;
      case 'price':
        chipColor = AppTheme.lightTheme.colorScheme.secondaryContainer;
        chipIcon = Icons.attach_money;
        break;
      case 'location':
        chipColor = AppTheme.lightTheme.colorScheme.tertiaryContainer;
        chipIcon = Icons.location_on;
        break;
      case 'condition':
        chipColor = AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.7);
        chipIcon = Icons.info_outline;
        break;
      case 'date':
        chipColor = AppTheme.lightTheme.colorScheme.secondaryContainer
            .withValues(alpha: 0.7);
        chipIcon = Icons.calendar_today;
        break;
      default:
        chipColor = AppTheme.lightTheme.colorScheme.surfaceContainerHighest;
        chipIcon = Icons.filter_alt;
    }

    return Container(
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20.sp),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 12.sp),
              child: CustomIconWidget(
                iconName: _getIconName(chipIcon),
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16.sp,
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.sp,
                  vertical: 8.sp,
                ),
                child: Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(4.sp),
                margin: EdgeInsets.only(right: 8.sp),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIconName(IconData iconData) {
    switch (iconData) {
      case Icons.category:
        return 'category';
      case Icons.attach_money:
        return 'attach_money';
      case Icons.location_on:
        return 'location_on';
      case Icons.info_outline:
        return 'info_outline';
      case Icons.calendar_today:
        return 'calendar_today';
      default:
        return 'filter_alt';
    }
  }
}
