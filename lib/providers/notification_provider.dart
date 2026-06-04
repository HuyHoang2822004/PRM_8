import 'package:flutter/material.dart';

import '../models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> notifications = [];

  Future<void> loadNotifications() async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (notifications.isNotEmpty) return;
    notifications = [
      AppNotification(
        id: 1,
        title: '🔥 Siêu Ưu Đãi Hè - Chrono Luxury',
        body: 'Giảm giá lên đến 20% cho các dòng Casio và Citizen chính hãng. Mua ngay kẻo lỡ!',
        timeAgo: '2 giờ trước',
      ),
      AppNotification(
        id: 2,
        title: '📦 Đơn hàng đã được xác nhận',
        body: 'Chúc mừng! Đơn hàng của bạn đã được hệ thống Chrono duyệt thành công và đang chuyển cho đơn vị vận chuyển.',
        timeAgo: '1 ngày trước',
      ),
      AppNotification(
        id: 3,
        title: '✨ BST Rolex Submariner Mới',
        body: 'Rolex Submariner màu xanh lục cực hiếm đã cập bến cửa hàng 123 Nguyễn Văn Linh, Quận 7.',
        timeAgo: '3 ngày trước',
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
