import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  ChatProvider? _chatProvider;
  int _messageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final myEmail = auth.userProfile['email'] ?? 'guest';
      final isManager = myEmail == 'admin@chrono.com';
      _chatProvider = context.read<ChatProvider>();
      _chatProvider!.setCurrentUserEmail(myEmail);
      if (!isManager) {
        _chatProvider!.isChatOpen = true;
        _chatProvider!.activeChatEmail = 'admin@chrono.com';
      }
      _chatProvider!.loadAllMessages();
      _chatProvider!.markCustomerChatAsRead();
      _scrollToBottom(isDelayed: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    if (_chatProvider != null) {
      _chatProvider!.isChatOpen = false;
      _chatProvider!.activeChatEmail = null;
    }
    super.dispose();
  }

  void _scrollToBottom({bool isDelayed = false}) {
    final delay = isDelayed ? 150 : 0;
    Future.delayed(Duration(milliseconds: delay), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    _controller.clear();
    final auth = context.read<AuthProvider>();
    final email = auth.userProfile['email'] ?? 'guest';
    final provider = context.read<ChatProvider>();
    
    await provider.sendMessageFromCustomer(email, text);
    _scrollToBottom(isDelayed: true);
  }

  List<Widget> _buildMessageListItems(List<dynamic> conversation, String myEmail) {
    final List<Widget> items = [];
    DateTime? lastDate;

    for (final msg in conversation) {
      final msgDate = DateTime(msg.timestamp.year, msg.timestamp.month, msg.timestamp.day);
      if (lastDate == null || msgDate != lastDate) {
        lastDate = msgDate;
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade200, thickness: 0.5)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(msg.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade200, thickness: 0.5)),
              ],
            ),
          ),
        );
      }

      final isBubbleFromMe = msg.senderEmail == myEmail;
      items.add(
        ChatBubble(
          key: ValueKey(msg.id),
          message: msg.content,
          isFromUser: isBubbleFromMe,
          timestamp: msg.timestamp,
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ChatProvider>();
    
    final myEmail = auth.userProfile['email'] ?? 'guest';
    final isManager = myEmail == 'admin@chrono.com';

    if (isManager) {
      final activeChats = provider.getActiveChats();

      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Icon(Icons.dashboard_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Danh sách hội thoại của khách hàng nhắn tới showroom.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: activeChats.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'Không có hội thoại nào',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Các tin nhắn từ khách hàng sẽ xuất hiện tại đây.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: activeChats.length,
                      itemBuilder: (context, index) {
                        final email = activeChats[index];
                        final conversation = provider.getConversation(email);
                        final lastMsg = conversation.isNotEmpty ? conversation.last : null;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.08),
                              child: Text(
                                email.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                            title: Text(
                              email,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            subtitle: Text(
                              lastMsg?.content ?? 'Không có nội dung tin nhắn',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (provider.unreadChatsForManager.contains(email))
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (provider.unreadChatsForManager.contains(email))
                                  const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                              ],
                            ),
                            onTap: () {
                              provider.markManagerChatAsRead(email);
                              context.push(AppRoutes.managerChatDetail, extra: email);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    }

    // Customer direct chat view
    final conversation = provider.getConversation(myEmail);

    if (conversation.length > _messageCount) {
      _messageCount = conversation.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(isDelayed: true);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Notice banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Thời gian nhân viên trực tuyến phản hồi: 8:00 - 21:00 hàng ngày.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          
          // Conversation lists
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: _buildMessageListItems(conversation, myEmail),
            ),
          ),
          
          // Bottom input area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        style: const TextStyle(fontSize: 13.5),
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn để hỏi shop...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
