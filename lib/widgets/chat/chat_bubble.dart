import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.isFromUser});

  final String message;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    final align = isFromUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isFromUser ? Colors.blue.shade100 : Colors.grey.shade200;
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(message),
      ),
    );
  }
}
