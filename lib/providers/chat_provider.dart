import 'package:flutter/material.dart';

import '../models/message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._chatService);

  final ChatService _chatService;
  final List<Message> _allMessages = [];

  List<Message> get allMessages => List.unmodifiable(_allMessages);

  Future<void> loadAllMessages() async {
    final persisted = await _chatService.loadPersistedMessages();
    _allMessages.clear();
    _allMessages.addAll(persisted);
    
    // Seed message if empty for demo purposes
    if (_allMessages.isEmpty) {
      _allMessages.addAll([
        Message(
          id: 'msg_seed_1',
          senderEmail: 'khachhang@test.com',
          receiverEmail: 'admin@chrono.com',
          content: 'Xin chào shop! Shop có mẫu Rolex Submariner còn hàng không ạ?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          isFromUser: true,
        ),
        Message(
          id: 'msg_seed_2',
          senderEmail: 'admin@chrono.com',
          receiverEmail: 'khachhang@test.com',
          content: 'Dạ chào bạn, mẫu Rolex Submariner hiện đang còn hàng sẵn tại showroom 123 Nguyễn Văn Linh ạ.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
          isFromUser: false,
        ),
      ]);
      await _chatService.savePersistedMessages(_allMessages);
    }
    notifyListeners();
  }

  List<Message> getConversation(String customerEmail) {
    return _allMessages.where((m) {
      final isCustomerSender = m.senderEmail == customerEmail && m.receiverEmail == 'admin@chrono.com';
      final isCustomerReceiver = m.senderEmail == 'admin@chrono.com' && m.receiverEmail == customerEmail;
      return isCustomerSender || isCustomerReceiver;
    }).toList();
  }

  List<String> getActiveChats() {
    final Set<String> emails = {};
    for (final m in _allMessages) {
      if (m.senderEmail != 'admin@chrono.com') {
        emails.add(m.senderEmail);
      }
      if (m.receiverEmail != 'admin@chrono.com') {
        emails.add(m.receiverEmail);
      }
    }
    
    // Sort customer emails by their latest message timestamp
    final List<String> sortedEmails = emails.toList();
    sortedEmails.sort((a, b) {
      final latestA = _latestMessageTime(a);
      final latestB = _latestMessageTime(b);
      return latestB.compareTo(latestA);
    });
    return sortedEmails;
  }

  DateTime _latestMessageTime(String email) {
    final conv = getConversation(email);
    if (conv.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    return conv.last.timestamp;
  }

  Future<void> sendMessageFromCustomer(String customerEmail, String content) async {
    if (content.trim().isEmpty) return;
    
    final newMsg = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderEmail: customerEmail,
      receiverEmail: 'admin@chrono.com',
      content: content.trim(),
      timestamp: DateTime.now(),
      isFromUser: true,
    );

    _allMessages.add(newMsg);
    await _chatService.savePersistedMessages(_allMessages);
    notifyListeners();

    // Trigger auto reply
    final replyText = await _chatService.autoReply(content);
    final botMsg = Message(
      id: 'msg_bot_${DateTime.now().millisecondsSinceEpoch}',
      senderEmail: 'admin@chrono.com',
      receiverEmail: customerEmail,
      content: replyText,
      timestamp: DateTime.now(),
      isFromUser: false,
    );
    _allMessages.add(botMsg);
    await _chatService.savePersistedMessages(_allMessages);
    notifyListeners();
  }

  Future<void> sendMessageFromManager(String customerEmail, String content) async {
    if (content.trim().isEmpty) return;

    final newMsg = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderEmail: 'admin@chrono.com',
      receiverEmail: customerEmail,
      content: content.trim(),
      timestamp: DateTime.now(),
      isFromUser: false,
    );

    _allMessages.add(newMsg);
    await _chatService.savePersistedMessages(_allMessages);
    notifyListeners();
  }

  // Deprecated methods mapping to prevent breaks
  void loadMessages() {
    loadAllMessages();
  }

  List<Message> get messages {
    return _allMessages.where((m) => m.senderEmail == 'guest' || m.receiverEmail == 'guest').toList();
  }

  Future<void> sendMessage(String text) async {
    await sendMessageFromCustomer('guest', text);
  }
}
