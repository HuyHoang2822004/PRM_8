class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
    required this.type,
    this.relatedId,
  });

  final String id;
  final String title;
  final String body;
  final String timeAgo;
  bool isRead;
  final String type;
  final dynamic relatedId;
}
