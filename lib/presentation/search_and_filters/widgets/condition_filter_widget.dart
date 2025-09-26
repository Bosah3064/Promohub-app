import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConditionFilterWidget extends StatefulWidget {
  final List<String> selectedConditions;
  final Function(List<String>)? onConditionsChanged;

  const ConditionFilterWidget({
    super.key,
    required this.selectedConditions,
    this.onConditionsChanged,
  });

  @override
  State<ConditionFilterWidget> createState() => _ConditionFilterWidgetState();
}

class _ConditionFilterWidgetState extends State<ConditionFilterWidget> {
  final List<Map<String, dynamic>> _conditions = [
    {
      'name': 'New',
      'description': 'Brand new, unused items',
      'icon': 'new_releases',
    },
    {
      'name': 'Like New',
      'description': 'Barely used, excellent condition',
      'icon': 'star',
    },
    {
      'name': 'Good',
      'description': 'Used but in good working condition',
      'icon': 'thumb_up',
    },
    {
      'name': 'Fair',
      'description': 'Shows wear but still functional',
      'icon': 'thumbs_up_down',
    },
    {
      'name': 'Poor',
      'description': 'Heavily used, may need repairs',
      'icon': 'thumb_down',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select item conditions',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        ..._conditions.map((condition) => _buildConditionItem(condition)),
      ],
    );
  }

  Widget _buildConditionItem(Map<String, dynamic> condition) {
    final conditionName = condition['name'] as String;
    final description = condition['description'] as String;
    final icon = condition['icon'] as String;
    final isSelected = widget.selectedConditions.contains(conditionName);

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (bool? value) {
          _toggleCondition(conditionName);
        },
        title: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conditionName,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        activeColor: AppTheme.lightTheme.colorScheme.primary,
        checkColor: AppTheme.lightTheme.colorScheme.onPrimary,
      ),
    );
  }

  void _toggleCondition(String condition) {
    final updatedConditions = List<String>.from(widget.selectedConditions);

    if (updatedConditions.contains(condition)) {
      updatedConditions.remove(condition);
    } else {
      updatedConditions.add(condition);
    }

    if (widget.onConditionsChanged != null) {
      widget.onConditionsChanged!(updatedConditions);
    }
  }
}
