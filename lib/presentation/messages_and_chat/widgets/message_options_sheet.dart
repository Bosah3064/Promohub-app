import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MessageOptionsSheet extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isCurrentUser;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final VoidCallback onReply;

  const MessageOptionsSheet({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.onCopy,
    required this.onDelete,
    required this.onReport,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),

          // Message preview
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: Text(
              message['type'] == 'text'
                  ? (message['content'] as String)
                  : message['type'] == 'image'
                      ? '📷 Photo'
                      : message['type'] == 'voice'
                          ? '🎵 Voice message'
                          : '📎 File',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 3.h),

          // Options
          Column(
            children: [
              _buildOption(
                icon: 'reply',
                title: 'Reply',
                onTap: () {
                  Navigator.pop(context);
                  onReply();
                },
              ),
              if (message['type'] == 'text')
                _buildOption(
                  icon: 'content_copy',
                  title: 'Copy',
                  onTap: () {
                    Navigator.pop(context);
                    onCopy();
                  },
                ),
              if (isCurrentUser)
                _buildOption(
                  icon: 'delete',
                  title: 'Delete',
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                  isDestructive: true,
                ),
              if (!isCurrentUser)
                _buildOption(
                  icon: 'report',
                  title: 'Report',
                  onTap: () {
                    Navigator.pop(context);
                    onReport();
                  },
                  isDestructive: true,
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppTheme.errorLight.withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: icon,
                size: 20,
                color: isDestructive
                    ? AppTheme.errorLight
                    : AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: isDestructive
                    ? AppTheme.errorLight
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
