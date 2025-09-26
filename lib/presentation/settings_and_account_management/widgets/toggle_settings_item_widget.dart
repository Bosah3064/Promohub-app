import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ToggleSettingsItemWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String iconName;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const ToggleSettingsItemWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.iconName,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: iconName,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        subtitle!,
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.lightTheme.colorScheme.primary,
                inactiveThumbColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                inactiveTrackColor: AppTheme
                    .lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 15.w,
            color: AppTheme.lightTheme.dividerColor,
          ),
      ],
    );
  }
}
