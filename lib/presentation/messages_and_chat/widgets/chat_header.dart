import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final Map<String, dynamic> contact;
  final VoidCallback onBackPressed;
  final VoidCallback onCallPressed;
  final VoidCallback onVideoCallPressed;
  final VoidCallback onMorePressed;
  final bool isTyping;

  const ChatHeader({
    super.key,
    required this.contact,
    required this.onBackPressed,
    required this.onCallPressed,
    required this.onVideoCallPressed,
    required this.onMorePressed,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 1,
      leading: IconButton(
        onPressed: onBackPressed,
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          size: 24,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      title: Row(
        children: [
          // Contact avatar
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: contact['avatar'] as String,
                width: 10.w,
                height: 10.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 3.w),

          // Contact info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.2.h),

                // Status indicator
                Row(
                  children: [
                    if (isTyping) ...[
                      Container(
                        width: 2.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'typing...',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: 2.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                          color: (contact['isOnline'] as bool)
                              ? AppTheme.successLight
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        (contact['isOnline'] as bool)
                            ? 'online'
                            : 'last seen ${_formatLastSeen(contact['lastSeen'] as DateTime)}',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Call button
        IconButton(
          onPressed: onCallPressed,
          icon: CustomIconWidget(
            iconName: 'call',
            size: 22,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),

        // Video call button
        IconButton(
          onPressed: onVideoCallPressed,
          icon: CustomIconWidget(
            iconName: 'videocam',
            size: 22,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),

        // More options button
        IconButton(
          onPressed: onMorePressed,
          icon: CustomIconWidget(
            iconName: 'more_vert',
            size: 22,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
