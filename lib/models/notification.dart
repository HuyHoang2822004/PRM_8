class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
  });

  final int id;
  final String title;
  final String body;
  final String timeAgo;
  bool isRead;
}
