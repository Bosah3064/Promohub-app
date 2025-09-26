import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BulkActionsBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onCancel;
  final bool isAllSelected;

  const BulkActionsBar({
    super.key,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onDelete,
    required this.onShare,
    required this.onCancel,
    required this.isAllSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Cancel button
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(width: 4.w),

            // Selected count
            Text(
              '$selectedCount selected',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            // Select all/deselect all
            TextButton(
              onPressed: isAllSelected ? onDeselectAll : onSelectAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isAllSelected ? 'Deselect All' : 'Select All',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(width: 2.w),

            // Share button
            IconButton(
              onPressed: selectedCount > 0 ? onShare : null,
              icon: CustomIconWidget(
                iconName: 'share',
                color: selectedCount > 0
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
                size: 6.w,
              ),
              padding: EdgeInsets.all(2.w),
              constraints: BoxConstraints(
                minWidth: 10.w,
                minHeight: 10.w,
              ),
            ),

            // Delete button
            IconButton(
              onPressed: selectedCount > 0 ? onDelete : null,
              icon: CustomIconWidget(
                iconName: 'delete',
                color: selectedCount > 0
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
                size: 6.w,
              ),
              padding: EdgeInsets.all(2.w),
              constraints: BoxConstraints(
                minWidth: 10.w,
                minHeight: 10.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
