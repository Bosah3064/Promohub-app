import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/chat_header.dart';
import './widgets/chat_input_field.dart';
import './widgets/conversation_list_item.dart';
import './widgets/message_bubble.dart';
import './widgets/message_options_sheet.dart';

class MessagesAndChat extends StatefulWidget {
  const MessagesAndChat({super.key});

  @override
  State<MessagesAndChat> createState() => _MessagesAndChatState();
}

class _MessagesAndChatState extends State<MessagesAndChat>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  bool _isRecording = false;
  final bool _isTyping = false;
  Map<String, dynamic>? _selectedConversation;
  Map<String, dynamic>? _selectedMessage;

  // Mock data for conversations (Empty State)
  final List<Map<String, dynamic>> _conversations = [];

  // Mock data for messages (Empty State)
  final Map<String, dynamic> _messages = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _openChat(Map<String, dynamic> conversation) {
    setState(() {
      _selectedConversation = conversation;
    });

    // Mark messages as read
    final conversationId = conversation['id'] as String;
    if (_messages.containsKey(conversationId)) {
      for (var message in _messages[conversationId]!) {
        if (message['senderId'] != 'current_user') {
          message['status'] = 'read';
        }
      }
    }

    // Update conversation unread count
    conversation['unreadCount'] = 0;

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty ||
        _selectedConversation == null) {
      return;
    }

    final conversationId = _selectedConversation!['id'] as String;
    final newMessage = {
      'id': 'm${DateTime.now().millisecondsSinceEpoch}',
      'type': 'text',
      'content': _messageController.text.trim(),
      'timestamp': DateTime.now(),
      'senderId': 'current_user',
      'senderAvatar':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&h=150&fit=crop&crop=face',
      'status': 'sent',
    };

    setState(() {
      if (!_messages.containsKey(conversationId)) {
        _messages[conversationId] = [];
      }
      _messages[conversationId]!.add(newMessage);

      // Update conversation last message
      _selectedConversation!['lastMessage'] = _messageController.text.trim();
      _selectedConversation!['lastMessageTime'] = DateTime.now();
      _selectedConversation!['isLastMessageSent'] = true;
      _selectedConversation!['messageStatus'] = 'sent';

      _messageController.clear();
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate message status updates
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          newMessage['status'] = 'delivered';
          _selectedConversation!['messageStatus'] = 'delivered';
        });
      }
    });

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          newMessage['status'] = 'read';
          _selectedConversation!['messageStatus'] = 'read';
        });
      }
    });
  }

  void _handleAttachFile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption('camera', 'Camera', () {
                  Navigator.pop(context);
                  _showToast('Camera opened');
                }),
                _buildAttachmentOption('photo_library', 'Gallery', () {
                  Navigator.pop(context);
                  _showToast('Gallery opened');
                }),
                _buildAttachmentOption('insert_drive_file', 'Document', () {
                  Navigator.pop(context);
                  _showToast('Document picker opened');
                }),
              ],
            ),
            SizedBox(height: 4.h + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(String icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: icon,
              size: 28,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _handleRecordVoice() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _showToast('Recording started');
      // Simulate recording duration
      Future.delayed(Duration(seconds: 3), () {
        if (mounted && _isRecording) {
          setState(() {
            _isRecording = false;
          });
          _showToast('Voice message sent');
        }
      });
    } else {
      _showToast('Recording stopped');
    }
  }

  void _handleEmojiTap() {
    _showToast('Emoji picker opened');
  }

  void _handleCall() {
    if (_selectedConversation != null) {
      _showToast('Calling ${_selectedConversation!['name']}...');
    }
  }

  void _handleVideoCall() {
    if (_selectedConversation != null) {
      _showToast(
          'Starting video call with ${_selectedConversation!['name']}...');
    }
  }

  void _handleMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            _buildMoreOption('block', 'Block User', () {
              Navigator.pop(context);
              _showToast('User blocked');
            }),
            _buildMoreOption('report', 'Report User', () {
              Navigator.pop(context);
              _showToast('User reported');
            }),
            _buildMoreOption('delete', 'Clear Chat', () {
              Navigator.pop(context);
              _showToast('Chat cleared');
            }),
            SizedBox(height: 2.h + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOption(String icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            SizedBox(width: 4.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMessageLongPress(Map<String, dynamic> message) {
    setState(() {
      _selectedMessage = message;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MessageOptionsSheet(
        message: message,
        isCurrentUser: message['senderId'] == 'current_user',
        onCopy: () => _copyMessage(message),
        onDelete: () => _deleteMessage(message),
        onReport: () => _reportMessage(message),
        onReply: () => _replyToMessage(message),
      ),
    );
  }

  void _copyMessage(Map<String, dynamic> message) {
    if (message['type'] == 'text') {
      Clipboard.setData(ClipboardData(text: message['content'] as String));
      _showToast('Message copied');
    }
  }

  void _deleteMessage(Map<String, dynamic> message) {
    final conversationId = _selectedConversation!['id'] as String;
    setState(() {
      _messages[conversationId]?.removeWhere((m) => m['id'] == message['id']);
    });
    _showToast('Message deleted');
  }

  void _reportMessage(Map<String, dynamic> message) {
    _showToast('Message reported');
  }

  void _replyToMessage(Map<String, dynamic> message) {
    _showToast('Replying to message');
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.onSurface,
      textColor: AppTheme.lightTheme.colorScheme.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedConversation != null) {
      return _buildChatScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 1,
        title: Text(
          'Messages',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showToast('Search messages'),
            icon: CustomIconWidget(
              iconName: 'search',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: () => _showToast('New message'),
            icon: CustomIconWidget(
              iconName: 'edit',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConversationsList(_conversations),
          _buildConversationsList(_conversations
              .where((c) => (c['unreadCount'] as int) > 0)
              .toList()),
        ],
      ),
    );
  }

  Widget _buildConversationsList(List<Map<String, dynamic>> conversations) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'chat_bubble_outline',
              size: 64,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 2.h),
            Text(
              'No messages yet',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Start a conversation with buyers and sellers',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ConversationListItem(
          conversation: conversation,
          onTap: () => _openChat(conversation),
        );
      },
    );
  }

  Widget _buildChatScreen() {
    final conversationId = _selectedConversation!['id'] as String;
    final messages = _messages[conversationId] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: ChatHeader(
        contact: _selectedConversation!,
        onBackPressed: () {
          setState(() {
            _selectedConversation = null;
          });
        },
        onCallPressed: _handleCall,
        onVideoCallPressed: _handleVideoCall,
        onMorePressed: _handleMoreOptions,
        isTyping: _isTyping,
      ),
      body: Column(
        children: [
          // Safety reminder
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            color: AppTheme.warningLight.withValues(alpha: 0.1),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  size: 16,
                  color: AppTheme.warningLight,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'For your safety, meet in public places for transactions',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.warningLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'chat',
                          size: 48,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Start your conversation',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _chatScrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser =
                          message['senderId'] == 'current_user';

                      return MessageBubble(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        onLongPress: () => _handleMessageLongPress(message),
                      );
                    },
                  ),
          ),

          // Input field
          ChatInputField(
            controller: _messageController,
            onSendMessage: _sendMessage,
            onAttachFile: _handleAttachFile,
            onRecordVoice: _handleRecordVoice,
            onEmojiTap: _handleEmojiTap,
            isRecording: _isRecording,
          ),
        ],
      ),
    );
  }
}
