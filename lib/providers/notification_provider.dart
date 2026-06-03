import 'package:flutter/material.dart';

import '../models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> notifications = [];

  Future<void> loadNotifications() async {
    await Future.delayed(const Duration(milliseconds: 250));
    notifications = [
      AppNotification(
        id: 1,
        title: '🔥 Summer Sale',
        body: '20% OFF',
        timeAgo: '2 hours ago',
      ),
      AppNotification(
        id: 2,
        title: '📦 Order Delivered',
        body: 'Yesterday',
        timeAgo: '1 day ago',
      ),
    ];
    notifyListeners();
  }

  void markAsRead(int id) {
    final target = notifications.where((n) => n.id == id);
    for (final item in target) {
      item.isRead = true;
    }
    notifyListeners();
  }
}
