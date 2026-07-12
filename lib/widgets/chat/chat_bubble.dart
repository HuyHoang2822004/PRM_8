import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isFromUser,
    this.timestamp,
  });

  final String message;
  final bool isFromUser;
  final DateTime? timestamp;

  @override
  Widget build(BuildContext context) {
    final align = isFromUser ? Alignment.centerRight : Alignment.centerLeft;
    
    final decoration = isFromUser
        ? const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          )
        : BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border, width: 1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          );

    final textStyle = TextStyle(
      color: isFromUser ? Colors.white : AppColors.textPrimary,
      fontSize: 14,
    );

    return Align(
      alignment: align,
      child: Column(
        crossAxisAlignment: isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: decoration,
            child: Text(message, style: textStyle),
          ),
          if (timestamp != null)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 6),
              child: Text(
                DateFormat('HH:mm - dd/MM/yyyy').format(timestamp!),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
