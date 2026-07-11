import 'dart:async';
import 'package:flutter/material.dart';

import '../models/message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._chatService);

  final ChatService _chatService;
  final List<Message> _allMessages = [];
  StreamSubscription<List<Message>>? _streamSubscription;

  List<Message> get allMessages => List.unmodifiable(_allMessages);

  Future<void> loadAllMessages() async {
    startListeningToMessages();
  }

  void startListeningToMessages() {
    if (_streamSubscription != null) return;
    _streamSubscription = _chatService.getMessagesStream().listen((messagesList) async {
      _allMessages.clear();
      _allMessages.addAll(messagesList);
      
      // Seed message if empty for demo purposes
      if (_allMessages.isEmpty) {
        final seed1 = Message(
          id: 'msg_seed_1',
          senderEmail: 'khachhang@test.com',
          receiverEmail: 'admin@chrono.com',
          content: 'Xin chào shop! Shop có mẫu Rolex Submariner còn hàng không ạ?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          isFromUser: true,
        );
        final seed2 = Message(
          id: 'msg_seed_2',
          senderEmail: 'admin@chrono.com',
          receiverEmail: 'khachhang@test.com',
          content: 'Dạ chào bạn, mẫu Rolex Submariner hiện đang còn hàng sẵn tại showroom 123 Nguyễn Văn Linh ạ.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
          isFromUser: false,
        );
        await _chatService.sendMessage(seed1);
        await _chatService.sendMessage(seed2);
      }
      
      notifyListeners();
    });
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
      if (m.senderEmail != 'admin@chrono.com' && m.senderEmail.isNotEmpty) {
        emails.add(m.senderEmail);
      }
      if (m.receiverEmail != 'admin@chrono.com' && m.receiverEmail.isNotEmpty) {
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

    await _chatService.sendMessage(newMsg);
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

    await _chatService.sendMessage(newMsg);
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

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
