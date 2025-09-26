import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isCurrentUser;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final messageType = message['type'] as String;
    final timestamp = message['timestamp'] as DateTime;
    final timeString =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) ...[
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 0.5,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: message['senderAvatar'] as String,
                    width: 8.w,
                    height: 8.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: 70.w),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                    bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                  ),
                  border: !isCurrentUser
                      ? Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                          width: 0.5,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (messageType == 'text')
                      _buildTextMessage()
                    else if (messageType == 'image')
                      _buildImageMessage()
                    else if (messageType == 'voice')
                      _buildVoiceMessage()
                    else if (messageType == 'file')
                      _buildFileMessage(),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeString,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: isCurrentUser
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                    .withValues(alpha: 0.7)
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          SizedBox(width: 1.w),
                          CustomIconWidget(
                            iconName: message['status'] == 'read'
                                ? 'done_all'
                                : message['status'] == 'delivered'
                                    ? 'done_all'
                                    : 'done',
                            size: 12,
                            color: message['status'] == 'read'
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                : AppTheme.lightTheme.colorScheme.onPrimary
                                    .withValues(alpha: 0.7),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isCurrentUser) SizedBox(width: 2.w),
          ],
        ),
      ),
    );
  }

  Widget _buildTextMessage() {
    return Text(
      message['content'] as String,
      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
        color: isCurrentUser
            ? AppTheme.lightTheme.colorScheme.onPrimary
            : AppTheme.lightTheme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: 60.w,
            maxHeight: 30.h,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImageWidget(
              imageUrl: message['imageUrl'] as String,
              width: double.infinity,
              height: 25.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (message['caption'] != null &&
            (message['caption'] as String).isNotEmpty) ...[
          SizedBox(height: 1.h),
          Text(
            message['caption'] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: isCurrentUser
                  ? AppTheme.lightTheme.colorScheme.onPrimary
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVoiceMessage() {
    final duration = message['duration'] as int; // in seconds
    final isPlaying = message['isPlaying'] as bool? ?? false;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppTheme.lightTheme.colorScheme.onPrimary
                    .withValues(alpha: 0.2)
                : AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: isPlaying ? 'pause' : 'play_arrow',
            size: 20,
            color: isCurrentUser
                ? AppTheme.lightTheme.colorScheme.onPrimary
                : AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 2.w),

        // Waveform visualization (simplified)
        Expanded(
          child: SizedBox(
            height: 4.h,
            child: Row(
              children: List.generate(20, (index) {
                return Container(
                  width: 0.5.w,
                  height: (index % 3 + 1) * 1.h,
                  margin: EdgeInsets.symmetric(horizontal: 0.2.w),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                            .withValues(alpha: 0.6)
                        : AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
            ),
          ),
        ),

        SizedBox(width: 2.w),
        Text(
          '${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}',
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: isCurrentUser
                ? AppTheme.lightTheme.colorScheme.onPrimary
                    .withValues(alpha: 0.8)
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFileMessage() {
    final fileName = message['fileName'] as String;
    final fileSize = message['fileSize'] as String;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppTheme.lightTheme.colorScheme.onPrimary
                    .withValues(alpha: 0.2)
                : AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'insert_drive_file',
            size: 24,
            color: isCurrentUser
                ? AppTheme.lightTheme.colorScheme.onPrimary
                : AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: isCurrentUser
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                fileSize,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: isCurrentUser
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                          .withValues(alpha: 0.7)
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
