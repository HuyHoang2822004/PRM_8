import 'package:flutter/material.dart';

import '../models/message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._chatService);

  final ChatService _chatService;
  final List<Message> messages = [];

  void loadMessages() {
    if (messages.isNotEmpty) return;
    messages.addAll([
      const Message(content: 'Xin chào shop!', isFromUser: true),
      const Message(content: 'Chào bạn! Cửa hàng Chrono Luxury xin chào. Bạn cần hỗ trợ gì ạ?', isFromUser: false),
    ]);
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    messages.add(Message(content: text.trim(), isFromUser: true));
    notifyListeners();
    
    // Simulate auto response from bot
    final reply = await _chatService.autoReply(text);
    messages.add(Message(content: reply, isFromUser: false));
    notifyListeners();
  }
}
