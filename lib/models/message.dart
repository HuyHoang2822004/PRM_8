class Message {
  const Message({
    required this.id,
    required this.senderEmail,
    required this.receiverEmail,
    required this.content,
    required this.timestamp,
    required this.isFromUser,
  });

  final String id;
  final String senderEmail;
  final String receiverEmail;
  final String content;
  final DateTime timestamp;
  final bool isFromUser;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isFromUser': isFromUser,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderEmail: json['senderEmail'] as String,
      receiverEmail: json['receiverEmail'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFromUser: json['isFromUser'] as bool? ?? true,
    );
  }
}
