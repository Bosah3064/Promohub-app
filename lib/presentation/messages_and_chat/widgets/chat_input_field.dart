import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final VoidCallback onAttachFile;
  final VoidCallback onRecordVoice;
  final VoidCallback onEmojiTap;
  final bool isRecording;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSendMessage,
    required this.onAttachFile,
    required this.onRecordVoice,
    required this.onEmojiTap,
    this.isRecording = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Quick reply suggestions
            if (!_hasText && !widget.isRecording) _buildQuickReplies(),

            // Main input row
            Row(
              children: [
                // Attachment button
                if (!widget.isRecording)
                  GestureDetector(
                    onTap: widget.onAttachFile,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'attach_file',
                        size: 20,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),

                if (!widget.isRecording) SizedBox(width: 2.w),

                // Text input field
                Expanded(
                  child: widget.isRecording
                      ? _buildRecordingIndicator()
                      : _buildTextInput(),
                ),

                SizedBox(width: 2.w),

                // Send/Voice button
                GestureDetector(
                  onTap: _hasText ? widget.onSendMessage : widget.onRecordVoice,
                  onLongPress: !_hasText ? widget.onRecordVoice : null,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: _hasText
                          ? 'send'
                          : (widget.isRecording ? 'stop' : 'mic'),
                      size: 20,
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    final quickReplies = [
      'Thanks!',
      'Yes',
      'No',
      'OK',
      'When?',
      'Where?',
    ];

    return Container(
      height: 5.h,
      margin: EdgeInsets.only(bottom: 1.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: quickReplies.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              widget.controller.text = quickReplies[index];
              widget.onSendMessage();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                quickReplies[index],
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 10.w,
        maxHeight: 25.w,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Emoji button
          GestureDetector(
            onTap: widget.onEmojiTap,
            child: SizedBox(
              width: 10.w,
              height: 10.w,
              child: CustomIconWidget(
                iconName: 'emoji_emotions',
                size: 20,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // Text field
          Expanded(
            child: TextField(
              controller: widget.controller,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 2.w,
                ),
              ),
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: AppTheme.errorLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.errorLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Recording animation
          Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: AppTheme.errorLight,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),

          Text(
            'Recording... Release to send',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.errorLight,
              fontWeight: FontWeight.w500,
            ),
          ),

          Spacer(),

          // Recording duration
          Text(
            '0:15',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.errorLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
