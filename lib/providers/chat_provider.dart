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
      const Message(content: 'Hello shop', isFromUser: true),
      const Message(content: 'Hi, how can I help you?', isFromUser: false),
    ]);
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    messages.add(Message(content: text.trim(), isFromUser: true));
    notifyListeners();
    final reply = await _chatService.autoReply();
    messages.add(Message(content: reply, isFromUser: false));
    notifyListeners();
  }
}
