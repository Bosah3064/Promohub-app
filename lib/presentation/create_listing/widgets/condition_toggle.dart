import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConditionToggle extends StatelessWidget {
  final String? selectedCondition;
  final Function(String) onConditionChanged;

  const ConditionToggle({
    super.key,
    this.selectedCondition,
    required this.onConditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final conditions = [
      {'value': 'new', 'label': 'New', 'icon': 'new_releases'},
      {'value': 'used', 'label': 'Used', 'icon': 'history'},
      {'value': 'refurbished', 'label': 'Refurbished', 'icon': 'build_circle'},
      {'value': 'open_box', 'label': 'Open Box', 'icon': 'inventory_2'},
      {'value': 'for_parts', 'label': 'For Parts', 'icon': 'construction'},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Condition',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: conditions.map((condition) {
              final isSelected = selectedCondition == condition['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onConditionChanged(condition['value'] as String),
                  child: Container(
                    margin: EdgeInsets.only(
                        right: condition != conditions.last ? 2.w : 0),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.surface
                              .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: condition['icon'] as String,
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          condition['label'] as String,
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: isSelected
                                ? AppTheme.lightTheme.primaryColor
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
